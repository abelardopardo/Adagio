#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, logging, sys, datetime, subprocess, re, time
import Ada

#
# node info:
#
#  key: filename
#  fanout: list of files that depend on this one
#  date: last modification date (might have propagated from fanout)

graph = {}

def getMtime(item):
    """Return mtime stored in the graph, or fetch it from the system if not
    present. If file does not exist, return zero"""

    global graph

    logging.debug('Dependency: Getting ' + item)

    fileDate = 0
    try:
        (fanout, fileDate) = graph[item]
    except KeyError, e:
        # If the file exist, traverse its chain and return the maximum stamp
        logging.debug('Dependency: ' + item + ' not found.')

        if os.path.exists(item):
            fileDate = traverseXML(item)
        else:
            logging.debug('Dependency: ' + item + ' does not exist.')

    return fileDate

def getListMtime(list):
    """Return most recent mtime calculated with the previous method"""

    return max(map(getMtime, list))

def traverseXML(file):
    """Given an XML file, detects import, include files and traverses
    recursively"""

    global graph

    logging.debug('Dependency: Traversing ' + file)

    try:
        (fanout, fileDate) = graph[file]
        logging.debug('Dependency: ' + file + ' HIT.')
        return fileDate

    except KeyError, e:
        # The file is not part of the graph

        # If the file does not exist, return
        if not os.path.exists(file):
            logging.debug('Dependency: ' + file + ' does not exist (tr).')
            return 0

        logging.debug('Dependency: ' + file + ' New node.')

        # Insert empty element
        stamp = os.stat(file).st_mtime
        graph[file] = ([], stamp)

        # Get the list of included files
        logging.debug('Dependency: ' + file + ' Getting includes.')
        includes = getIncludes(file)
        maximum = stamp
        # Loop over all the files included and set the dependencies
        for fName in includes:
            # Traverse recursively
            includeStamp = traverseXML(fName)

            # Keep the maximum
            maximum = max(includeStamp, maximum)

            # Insert the dependency in the graph
            insertDependency(fName, file)

        # If the fanin has a larger stamp, refresh
        if maximum > stamp:
            graph[file] = ([], maximum)

        logging.debug('Dependency: ' + file + ' Done processing includes.')
    return maximum

def getIncludes(fName):
    """Parse XML/XSL file and obtain import/include URLs as a list of absolute
    paths. WARNING: This invocation is the true CPU hog! Almost 95% of the
    execution time goes creating and waiting for the result of the Popen."""

    includes = []

    # If file does not exist, return
    if not os.path.exists(fName):
        return includes

    # Execute the command
    cmd = subprocess.Popen(['xsltproc', '--path',
                            '.:' +
                            os.path.join(Ada.ada_home, 'ADA_Styles'),
                            '--nonet',
                            os.path.join(Ada.ada_home, 'ADA_Styles',
                                         'GetIncludes.xsl'),
                            fName],
                           stdout=subprocess.PIPE,
                           stderr=open('build.out', 'a'))
    # Wait for xsltproc to terminate
    cmd.wait()

    # Check if there has been any problem
    if cmd.returncode != 0:
        logging.info('Dependency: Error while processing ' + fName)
        raise TypeError, 'Dependency: Error while processing ' + fName

    # Loop over the output lines
    for line in cmd.stdout.readlines():
        # Remove the xpointer suffix
        line = re.sub('#xpointer.*$', '', line)

        # Accumulate the result
        fullPath = os.path.abspath(os.path.join(os.path.dirname(fName),
                                                line[:-1]))
        if includes.count(fullPath) == 0:
            includes.append(fullPath)

    return includes

def updateMtime(item, stamp):
    """Given the item, checks if the actual mtime is more recent than the stamp in
    the graph. If so, propagates the value through the fanout. If not in the
    graph, then there is no operation needed."""

    global graph

    try:
        itemInfo = graph[item]
        if stamp > itemInfo[1]:
            graph[item] = (itemInfo[0], stamp)

        # Iterate over the fanin
        for fanin in itemInfo[0]:
            updateMtime(fanin, stamp)

    except KeyError, e:
        # File is not in the graph, nothing to do
        return

# Dependencies are only needed if the stamps are refreshed at any time
def insertDependency(itemFrom, itemTo):
    """Function that introduces an edge stating that itemFrom depends on item
    itemTo"""

    global graph

    # Get the info for the two nodes
    fromInfo = graph[itemFrom]

    if fromInfo[0].count(itemTo) != 0:
        return

    # Insert destination file in fanout of source file
    fromInfo[0].append(itemTo)
    graph[itemFrom] = (fromInfo[0], fromInfo[1])

if __name__ == "__main__":
    Ada.initialize()
    lap = time.time()
    l = getMtime(sys.argv[1])
    print l
    print "Time: " + str(time.time() - lap)
    lap = time.time()
    l = getMtime(sys.argv[1])
    print l
    print "Time: " + str(time.time() - lap)
