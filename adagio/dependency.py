#!/usr/bin/env python
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
import os, sys, datetime, subprocess, re, time, atexit

# Import conditionally either regular xml support or lxml if present
try:
    from lxml import etree
except ImportError:
    import xml.etree.ElementTree as etree

import adagio, rules, i18n, treecache

# The graph is stored with the following data structures:
#
# Node indeces are integers.
#
# __FileNameToNodeIDX: Dictionary with (fileName -> nodeIndex) pairs
# __IDXToName: Inverse mapping of the previous dictionary
# __NodeDate: Array storing index -> date pairs
# __NodeOutEdges: Array of sets with the outgoing edges
#
__FileNameToNodeIDX = {}
__IDXToName = []
__NodeDate = []
__NodeOutEdges = []

# Some regular expressions for matching includes in LaTeX files:
_re_latex_comment = re.compile(r'(?<!\\)#|^#')
_re_latex_include = re.compile(r'\\include[ ]*\{([^\}]+)\}')
_re_latex_input = re.compile(r'\\input[ ]*\{([^\}]+)\}')
_re_latex_graphics = re.compile((r'\\includegraphics[ ]*(?:\[[^\]]*\])?[ ]*'
                                 r'\{([^\}]+)\}'))

def flushData():
    global __FileNameToNodeIDX
    global __IDXToName
    global __NodeDate
    global __NodeOutEdges

    __FileNameToNodeIDX = {}
    __IDXToName = []
    __NodeDate = []
    __NodeOutEdges = []
    return

#
# Flush data upon exit
#
atexit.register(flushData)

def addNode(fileName, baseDir = None):
    """
    Given a fileName creates (if needed) the node in the graph. It adds a new
    entry to the FileNameToIDX dictionary, the reverse info in IDXToName,
    appends its st_mtime to NodeDate and an empty set to the adjancency
    lists.

    If baseDir is set, this directory name is used for expanding
    relative paths while parsing dependencies. Useful for LaTeX, for
    example. If not set, relative file names take as base the location
    of fileName.

    Returns the node index of the given file
    """
    global __FileNameToNodeIDX
    global __IDXToName
    global __NodeDate
    global __NodeOutEdges


    # Make fileName absolute
    fileName = os.path.abspath(fileName)

    # Search first to see if it is there
    nodeIdx = __FileNameToNodeIDX.get(fileName)

    # If node does not exist create it
    if nodeIdx == None:
        nodeIdx = len(__FileNameToNodeIDX)
        __FileNameToNodeIDX[fileName] = nodeIdx
        __IDXToName.append(fileName)
        __NodeOutEdges.append(set({}))

        # If the file exists, store the mtime, if not, zero.
        if os.path.exists(fileName):
            __NodeDate.append(os.path.getmtime(fileName))

            # If the extension is xml or xsl, traverse the includes/imports
            ext = os.path.splitext(fileName)[1]
            if ext == '.xml' or ext == '.xsl':
                x = getIncludes(fileName)
                update(nodeIdx, x)
            elif ext == '.tex':
                if baseDir is None:
                    baseDir = os.path.dirname(fileName)
                x = getIncludesLatex(fileName, baseDir)
                update(nodeIdx, x, baseDir)
        else:
            __NodeDate.append(0)

    # Return the index associated with the given file
    return nodeIdx

def update(dst, srcSet = None, baseDir=None):
    """
    Modifies the graph to reflect the addition of edges from each of the
    elements in srcSet to dst. If srcSet is empty it only updates the date of
    dst with the st_mtime value and propagates the result.

    If baseDir is set, this directory name is used for expanding
    relative paths while parsing dependencies. Useful for LaTeX, for
    example. If not set, relative file names take as base the location
    of fileName.

    Returns the index of the destination node
    """
    global __FileNameToNodeIDX
    global __IDXToName
    global __NodeDate
    global __NodeOutEdges

    if srcSet == None:
	srcSet = set([])

    # If a string is given, translate to index
    if (type(dst) == str) or (type(dst) == unicode):
        dstIDX = addNode(dst, baseDir=baseDir)
    else:
        dstIDX = dst

    adagio.logDebug('dependency', None, dst)
    adagio.logDebug('dependency', None, srcSet)
    # Initialize the mark to the index and date of the destination
    moreRecentIDX = dstIDX

    # If the srcSet is empty, update dst with mtime
    if srcSet == set([]):
        moreRecentDate = os.path.getmtime(__IDXToName[dstIDX])
    else:
        moreRecentDate = __NodeDate[dstIDX]

    # Loop over the nodes in the source set
    for node in srcSet:
        if type(node) == str or type(node) == unicode:
            srcIDX = addNode(node, baseDir=baseDir)
        else:
            srcIDX = node

        # Add the edge to the adjacency set
        __NodeOutEdges[srcIDX].add(dstIDX)

        # If the new date is more recent, update point
        if __NodeDate[srcIDX] > moreRecentDate:
            moreRecentIDX = srcIDX
            moreRecentDate = __NodeDate[srcIDX]

    # If the modification needs to propagate go ahead
    if moreRecentDate > __NodeDate[dstIDX]:
        __NodeDate[dstIDX] = moreRecentDate
        for fanoutIDX in __NodeOutEdges[dstIDX]:
            update(fanoutIDX, set([dstIDX]), baseDir=baseDir)

    return dstIDX

def getIncludes(fName):
    """
    Get the xsl:import, xsl:include and xi:include in an XML file

    returns the set of absolute files that are included/imported
    """

    # Turn the name into absolute path and get the directory part
    fName = os.path.abspath(fName)
    fDir = os.path.dirname(fName)

    # Parse the document and initialize the result to the empty set
    root = treecache.findOrAddTree(fName, False)
    result = set([])

    allIncludes = \
         set(root.findall('//{http://www.w3.org/1999/XSL/Transform}import')) | \
         set(root.findall('//{http://www.w3.org/1999/XSL/Transform}include')) | \
         set(root.findall('//{http://www.w3.org/2001/XInclude}include'))

# This is the equivalent xpath expression, but if used, the package is only
# compatible if lxml is installed.

#     root.xpath('/descendant::*[self::xi:include or self::xsl:import or \
#                                self::xsl:include]',
#                namespaces={'xi' : 'http://www.w3.org/2001/XInclude',
#                            'xsl' : 'http://www.w3.org/1999/XSL/Transform'})

    # Loop over all the includes, and imports of XML and XSL
    for element in [e for e in allIncludes if 'href' in e.attrib]:
        hrefValue = \
            treecache.xml_resolver.resolve_file(element.attrib.get('href'))

        if hrefValue != None:
            result.add(hrefValue)

    allRSS = set(root.findall('//{http://www.w3.org/1999/xhtml}rss'))

#     root.xpath('/descendant::html:rss',
#                namespaces={'html' : \
#                            'http://www.w3.org/1999/xhtml'})

    # Loop over all the rss elements in the HTML namespace
    for element in [e for e in allRSS if 'file' in e.attrib]:
        result.add(os.path.abspath(os.path.join(fDir,
                                                element.attrib['file'])))

    # Return the result set
    return result

def getIncludesLatex(fName, baseDir):
    """
    Get resources included with \input or \include in a LaTeX file

    returns the set of absolute files that are included
    """

    # Turn the name into absolute path and get the directory part
    fName = os.path.abspath(fName)

    # Parse the document and look for \input and \include
    result = set()
    file_ = open(fName, 'r')
    for line in file_:
        # First, remove comments
        match = _re_latex_comment.search(line)
        if match is not None:
            line = line[:match.start()]
        # Look for input and include commands
        for include in (_re_latex_include.findall(line)
                        + _re_latex_input.findall(line)):
            if not include.endswith('.tex'):
                include = include + '.tex'
            result.add(os.path.abspath(os.path.join(baseDir, include)))
        for graphic in _re_latex_graphics.findall(line):
            result.add(os.path.abspath(os.path.join(baseDir, graphic)))
    file_.close()

    # Return the result set
    return result

def isUpToDate(fileName):
    """
    Returns true if the st_mtime of a file is more recent than the date in the
    graph
    """
    global __FileNameToNodeIDX
    global __NodeDate

    # If the file is not present, it is definetively, not up to date
    if not os.path.exists(fileName):
        return False

    return (os.path.getmtime(fileName) >= __NodeDate[addNode(fileName)])

# def locateFile(fileName, paths = None):
#     """Search an stylesheet in the dirs in local Adagio dirs"""
#
#
#    # No check is done for URLs, the error will pop up sometime later
#    if fileName.startswith('http'):
#        return fileName
#
#    if paths == None:
#        paths = [os.getcwd()]
#
#    absName = os.path.abspath(os.path.join(paths[0], fileName))
#
#    # If it exists in the given dir, return
#    if os.path.exists(absName):
#        return absName
#
#    localAdagioStyle = os.path.join(adagio.home, 'Adagio_Styles', fileName)
#
#    if os.path.exists(localAdagioStyle):
#        return os.path.abspath(localAdagioStyle)
#
#    return None

def dumpGraph():
    global __FileNameToNodeIDX
    global __IDXToName
    global __NodeDate
    global __NodeOutEdges

    pref = os.path.commonprefix(__IDXToName)

    for n in range(0, len(__IDXToName)):
        print str(__NodeDate[n]), __IDXToName[n], '[' + str(n) + ']'
        print '  ' + ' '.join([str(m) for m in __NodeOutEdges[n]])

################################################################################

if __name__ == "__main__":

    update(sys.argv[1], set(sys.argv[2:]))
    
    if isUpToDate(sys.argv[1]):
        print sys.argv[1], 'is up to date'
    else:
        print sys.argv[1], 'is NOT up to date'

    dumpGraph()

