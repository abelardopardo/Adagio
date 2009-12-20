#!/usr/bin/python
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#

import os, logging, sys, datetime, subprocess, re, time

# Import conditionally either regular xml support or lxml if present
try:
    from lxml import etree
except ImportError:
    import xml.etree.ElementTree as etree

import Ada, AdaRule

# The graph is stored as three data structures:
#
# __FileNameToNodeIDX: Dictionary with (fileName -> nodeIndex) pairs
# __NodeDate: Inverse mapping of the previous dictionary
# __NodeDate: Array storing index -> date pairs
# __NodeOutEdges: Array of sets with the outgoing edges
#
__FileNameToNodeIDX = {}
__IDXToName = []
__NodeDate = []
__NodeOutEdges = []

__includeList = []

def addNode(fileName, traverse = False):
    """
    Given a fileName it created (if needed) the node in the graph. It simply
    adds a new entry to the FileNameToIDX dictionary and appends its st_mtime
    date to the date list and an empty list to the adjancency lists.
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
        __NodeDate.append(os.path.getmtime(fileName))

        # If the extension is xml or xsl, traverse the includes/imports
        ext = os.path.splitext(fileName)[1]
        if ext == '.xml' or ext == '.xsl':
            # This function already inserts the node in the graph
            traverseXML(fileName)

    return nodeIdx

def update(dst, srcSet = set([])):
    """
    Modifies the graph to reflect the addition of an edge from each of the
    elements in srcSet to dst. If srcSet is empty it only updates the date of
    dst with the st_mtime value and propagates the result.

    Returns the index of the destination node
    """
    global __FileNameToNodeIDX
    global __IDXToName
    global __NodeDate
    global __NodeOutEdges

    # If a string is given, translate to index
    if type(dst) == str:
        dstIDX = addNode(dst, True)
    else:
        dstIDX = dst

    # Initialize the mark to the index and date of the destination
    moreRecentIDX = dstIDX

    # If the srcSet is empty, update dst with mtime
    if srcSet == set([]):
        moreRecentDate = os.path.getmtime(__IDXToName[dstIDX])
    else:
        moreRecentDate = __NodeDate[dstIDX]

    for node in srcSet:
        if type(node) == str:
            srcIDX = addNode(node, True)
        else:
            srcIDX = node

        # Add the edge to the adjacency set
        __NodeOutEdges[srcIDX].add(dstIDX)

        # If the new date is more recent, update point
        if __NodeDate[srcIDX] > moreRecentDate:
            moreRecentIDX = srcIDX
            moreRecentDate = __NodeDate[srcIDX]

    # If the modification needs to propagate go ahead
    if moreRecentDate > __NodeDate[moreRecentIDX]:
        __NodeDate[moreRecentIDX] = moreRecentDate
        for fanoutIDX in __NodeOutEdges[srcIDX]:
            update(fanoutIDX, [dstIDX])

    return dstIDX

def traverseXML(fileName):
    """Given an XML file, detects import, include files and traverses
    recursively"""
    global __FileNameToNodeIDX
    global __IDXToName
    global __NodeDate
    global __NodeOutEdges

    # Make fileName absolute
    fileName = os.path.abspath(fileName)

    # If the file does not exist, return
    if not os.path.exists(fileName):
        print 'Dependency: ' + fileName + ' does not exist'
        return

    # Search first to see if it is there
    nodeIdx = __FileNameToNodeIDX.get(fileName)

    # If node is already in the graph, return
#     if nodeIdx != None:
#         print 'Dependency: ' + fileName + ' HIT.'
#         return

    # Get the set of included files
    includes = getIncludes(fileName)

    # Update the graph with respect to these data
    update(nodeIdx, includes)

    return

def getIncludes(fName):
    """
    Get the xsl:import, xsl:include and xi:include in a file

    returns the set of absolute files that are included
    """

    # Turn the name into absolute path and get the directory part
    fName = os.path.abspath(fName)
    fDir = os.path.dirname(fName)

    # Parse the document and initialize the result to the empty set
    root = etree.parse(fName)
    result = set([])

    allIncludes = \
         set(root.findall('//{http://www.w3.org/1999/XSL/Transform}import')) | \
         set(root.findall('//{http://www.w3.org/1999/XSL/Transform}include')) | \
         set(root.findall('//{http://www.w3.org/2001/XInclude}include'))

# This is the equivalent xpath expression, but if included, the package is only
# compatible if lxml is installed.

#     root.xpath('/descendant::*[self::xi:include or self::xsl:import or \
#                                self::xsl:include]',
#                namespaces={'xi' : 'http://www.w3.org/2001/XInclude',
#                            'xsl' : 'http://www.w3.org/1999/XSL/Transform'})

    # Loop over all the includes, and imports of XML and XSL
    for element in allIncludes:
        if 'href' in element.attrib:
            hrefValue = element.attrib['href']
            hrefAbs = os.path.abspath(os.path.join(fDir, hrefValue))
            if not os.path.exists(hrefAbs):
                hrefAbs = os.path.abspath(os.path.join(Ada.ada_home, \
                                                       'ADA_Styles', \
                                                       hrefValue))
            if os.path.exists(hrefAbs):
                result.add(hrefAbs)
            else:
                print 'Warning file ' + hrefAbs + ' not found.'

    allRSS = set(root.findall('//{http://www.w3.org/1999/xhtml}rss'))

#     root.xpath('/descendant::html:rss',
#                namespaces={'html' : \
#                            'http://www.w3.org/1999/xhtml'})

    # Loop over all the rss elements in the HTML namespace
    for element in allRSS:
        if 'file' in element.attrib:
            result.add(os.path.abspath(os.path.join(fDir,
                                                    element.attrib['file'])))

    # Return the result set
    return result

def isUpToDate(fileName, src = set([])):
    """
    Returns true if the st_mtime of a file is more recent than the date in the
    graph
    """
    global __FileNameToNodeIDX
    global __NodeDate

    # If the file is not present, it is definetively, not up to date
    if not os.path.exists(fileName):
        return False

    idx = __FileNameToNodeIDX.get(fileName)

    # File not in the graph, update graph
    if idx == None:
        update(fileName, src)
        idx = __FileNameToNodeIDX.get(fileName)

    return (os.path.getmtime(fileName) >= __NodeDate[idx])

def dumpGraph():
    global __FileNameToNodeIDX
    global __IDXToName
    global __NodeDate
    global __NodeOutEdges

    for n in range(0, len(__IDXToName)):
        print '[' + str(n) + ']' +  __IDXToName[n] + ' ' + str(__NodeDate[n])
        print '  ' + ' '.join([str(m) for m in __NodeOutEdges[n]])

################################################################################


if __name__ == "__main__":

    Ada.initialize()

    if len(sys.argv) > 2:
        otherFiles = set(sys.argv[2:])
    else:
        otherFiles = set({})

    lap = time.time()
    l = isUpToDate(sys.argv[1], otherFiles)
    print "Time: " + str(time.time() - lap)
    print l
    lap = time.time()
    l = isUpToDate(sys.argv[1], otherFiles)
    print "Time: " + str(time.time() - lap)
    print l
    # dumpGraph()
