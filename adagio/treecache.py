#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Copyright (C) 2010 Carlos III University of Madrid
# This file is part of the Adagio: Agile Distributed Authoring Toolkit

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

# A dictionary storing XML trees and XSLTProcs. The values are pairs (a, b)
# where a is the tree without the includes expanded and b is the fully expanded
# tree.
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

    (simpleTree, expandedTree) = _createdTrees.get(theKey, (None, None))
    if expanded and expandedTree != None:
        # HIT
        return expandedTree
    if not expanded and simpleTree != None:
        # HIT
        return simpleTree

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
    _createdTrees[theKey] = (simpleTree, expandedTree)
    
    if expanded:
        return expandedTree
    
    return simpleTree

def findOrAddTransform(path):
    """
    Simple dictionary storing XSL Transforms. The key is the given path (which
    could be a string)
    """
    global _createdTransforms

    theKey = path
    if (type(path) != str) and (type(path) != unicode):
        theKey = path.getvalue()

    transform = _createdTransforms.get(theKey)
    if transform != None:
        # HIT
        adagio.logDebug('treecache', None, 'HIT: ' + str(path))
        return transform

    # Parse style file, insert name resolver to consider Adagio local styles,
    # expand includes and create transformation object
    styleParser = etree.XMLParser(load_dtd = True, no_network = True)
    styleParser.resolvers.add(rules.StyleResolver())
    try:
        transform = etree.parse(path, styleParser)
    except etree.XMLSyntaxError, e:
        print i18n.get('severe_parse_error').format(path)
        print str(e)
        sys.exit(1)

    transform.xinclude()
    transform = etree.XSLT(transform, access_control = _accessControl)
    _createdTransforms[theKey] = transform

    return transform
