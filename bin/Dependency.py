#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, logging, sys, datetime

#
# node info:
#
#  key: filename
#  fanout: list of files that depend on this one
#  date: last modification date (might have propagated from fanout)

graph = {}

def isMoreRecent(item, date):
    # If not in the graph, return
    try:
        (fanout, fileDate) = graph[item]
    except KeyError, e:
        return False

    return fileDate > date

def isMoreRecent(itemList):

    for item in itemList:
        if isMoreRecent(item):
            return True
    return False

def insertFile(item):
    try:
        (fanout, date) = graph[item]
    except KeyError, e:
        stamp = os.stat(item).st_mtime
        graph[item] = ([], stamp)
        return ([], stamp)
    return (fanout, date)

def propagateDate(item, newDate):
    """Function that given the item and a newDate, if the given date is more
    recent than the item date, it modifies it and propagates the date to all
    elements in the fanout"""

    # Lookup the element
    itemInfo = graph[item]

    # If date is more recent modify and propagate
    if newDate > itemInfo[1]:
        graph[item] = (itemInfo[0], newDate)
        for itemOut in itemInfo[0]:
            propagateDate(itemOut, newDate)

def insertDependency(itemFrom, itemTo):
    """Function that introduces an edge stating that itemFrom depends on item
    itemTo"""

    # Get the info for the two nodes
    fromInfo = insertFile(itemFrom)
    toInfo = insertFile(itemTo)

    if fromInfo[0].count(itemTo) != 0:
        return

    # Insert destination fil in fanout of source file
    fromInfo[0].append(itemTo)
    graph[itemFrom] = (fromInfo[0], fromInfo[1])

    # Update date in destination file if needed
    if fromInfo[1] > toInfo[1]:
        graph[itemTo] = (toInfo[0], fromInfo[1])
        # Propagate modification time
        for itemOut in toInfo[0]:
            propagateDate(itemOut, toInfo[1])

if __name__ == "__main__":
    insertDependency(os.path.abspath('Crap'),
                     os.path.abspath('Another'))
    print graph
