#!/usr/bin/env python
# -*- coding: UTF-8 -*-#
#
# Copyright (C) 2010 Carlos III University of Madrid
# This file is part of Adagio: Agile Distributed Authoring Integrated Toolkit

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor
# Boston, MA  02110-1301, USA.
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
import sys, os, copy, atexit
from lxml import etree

import adagio, rules, i18n

# Implement two dictionaries to store XML trees and XSLT transformations.
#
# The first dictionary stores values as:
# absolute path: (a, b, c)
# where the key is the path to a XML file, a is the XML tree without the
# includes expanded, b is the fully expanded tree and c is a timestamp to detect
# file changes.
#
# The second dictionary stores values as:
# absolute path: (a, b)
# where the key is the absolute path to a stylesheet, a is the StyleTransform
# object, and b is a timestampto detect file changes.
_createdTrees = {}

# Dictionary storing XSL transformations. The key is either the text of a
# StringIO or the absolute path given as parameter.
_createdTransforms = {}

# Object to control the type of accesses allowed when applying a
# transformation. The network is not allowed to detect anomalies in the catalogs
# and resolvers.
_accessControl = etree.XSLTAccessControl(read_network = False)

def flushData():
    """
    Flush both caches
    """
    global _createdTrees
    global _createdTransforms

    _createdTrees = {}
    _createdTransforms = {}
    return

#
# Flush data upon exit
#
atexit.register(flushData)

def findOrAddTree(path, expanded = True):
    """
    Check if the tree corresponding to the given path is in the dictionary, and
    if not, create it and assign it.  """
    
    global _createdTrees

    theKey = os.path.abspath(path)

    # Get the last modification time of the given file to detect changes
    ftime = os.path.getmtime(path)

    (simpleTree, expandedTree, tstamp) = _createdTrees.get(theKey, 
                                                           (None, None, None))

    if expanded and (expandedTree != None) and (ftime <= tstamp):
        # HIT
        return expandedTree
    if not expanded and (simpleTree != None) and (ftime <= tstamp):
        # HIT
        return simpleTree

    # If file changed from the last time, void the partial results
    if (tstamp != None) and (ftime > tstamp):
        simpleTree = None
        expandedTree = None
        
    # Missing tree
    if not expanded:
        # Create the simpleTree and update
        try:
            simpleTree = etree.parse(path, etree.XMLParser(load_dtd = True, 
                                                           no_network = True))
        except etree.XMLSyntaxError, e:
            print i18n.get('severe_parse_error').format(path)
            print str(e)
            sys.exit(1)

    if expanded:
        # Create the expandedTree (check if the simpleTree can be used
        if simpleTree != None:
            expandedTree = copy.deepcopy(simpleTree)
            try:
                expandedTree.xinclude()
            except (etree.XMLSyntaxError, etree.XIncludeError), e:
                print i18n.get('severe_parse_error').format(path)
                print str(e)
                sys.exit(1)
        else:
            try:
                expandedTree = etree.parse(path, 
                                           etree.XMLParser(load_dtd = True, 
                                                           no_network = True))
                expandedTree.xinclude()
            except (etree.XMLSyntaxError, etree.XIncludeError), e:
                print i18n.get('severe_parse_error').format(path)
                print str(e)
                sys.exit(1)

    # Update the cache
    _createdTrees[theKey] = (simpleTree, expandedTree, ftime)
    
    if expanded:
        return expandedTree
    
    return simpleTree

def findOrAddTransform(styleFile, styleList):
    """
    Simple dictionary storing XSL Transforms. The key is the given styleFile (which
    could be a string)
    """
    global _createdTransforms

    theKey = ' '.join(styleList)

    # Get the last modification time of the given file to detect changes
    ftime = max([os.path.getmtime(x) for x in styleList])

    (transform, tstamp) = _createdTransforms.get(theKey, (None, None))
    if (transform != None) and (ftime <= tstamp):
        # HIT
        adagio.logDebug('treecache', None, 'HIT: ' + str(styleFile))
        return transform

    # Parse style file, insert name resolver to consider Adagio local styles,
    # expand includes and create transformation object
    styleParser = etree.XMLParser(load_dtd = True, no_network = True)
    styleParser.resolvers.add(rules.StyleResolver())
    try:
        transform = etree.parse(styleFile, styleParser)
    except etree.XMLSyntaxError, e:
        print i18n.get('severe_parse_error').format(styleFile)
        print str(e)
        sys.exit(1)

    transform.xinclude()

    try:
        transform = etree.XSLT(transform, access_control = _accessControl)
    except Exception, e:
	print
        print i18n.get('error_in_xslt').format('\n'.join(styleList))
        print str(e)
        sys.exit(1)

    _createdTransforms[theKey] = (transform, ftime)

    return transform
