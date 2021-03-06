#!/usr/bin/env python
# -*- coding: UTF-8 -*-#
#
# Copyright (C) 2010 Carlos III University of Madrid
# This file is part of Adagio: Agile Distributed Authoring Integrated Toolkit
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor
# Boston, MA  02110-1301, USA.
#
# Class to shuffle the QandA elements of a DocBook XML file. The main usage of
# this class is to create different versions of an exam in which questions are
# labeled with the QandA elements of Docbook. The resulting files contain the
# same questions but randomly shuffled. The program also prints the
# correspondence between the questions of the generated shuffled files.
#
# @author Abelardo Pardo (abel@it.uc3m.es)
#
# Copyright: This file was created at the Carlos III University of Madrid.
# Carlos III University of Madrid makes no warranty about the suitability of
# this software for any purpose. It is presented on an AS IS basis.
#
# Import conditionally either regular xml support or lxml if present
import os, copy, sys, time, random, re

try:
    from lxml import etree
except ImportError:
    import xml.etree.ElementTree as etree

import treecache

def main(sourceFile, pout = None):
    """
    Function that given a Docbook file containing a quandaset with a set of
    quandadivs creates as many permutations as specified in a specific element
    within the document.
    
    Returns the number of permutations created (zero means error)
    """

    if pout == None:
	pout = sys.stdout

    # For notifying steps through stdout
    stepCount = 1

    print >> pout, 'Step', stepCount, 'Check file permissions'
    stepCount += 1

    # If the given file is not present, return.
    if not os.path.isfile(sourceFile):
        print >> pout, 'File', sourceFile, 'cannot be accessed.'
        return 0

    print >> pout, 'Step', stepCount, 'Create the XML document manager'
    stepCount += 1
    
    # Parse the source tree.
    sourceTree = treecache.findOrAddTree(sourceFile, True)
    root = sourceTree.getroot()

    # Get all product numbers from the source document (they are the seeds)
    seedList = []
    sectionInfo = root.find("sectioninfo")
    if sectionInfo != None:
        pnumbers = sectionInfo.findall("productnumber")
        if pnumbers != None:
            for pnumber in pnumbers:
                seedList.append(copy.deepcopy(pnumber))
        print >> pout, 'Step', stepCount, 'Read', len(pnumbers), \
            'seeds in document.'
        stepCount += 1
    
    print >> pout, 'Step', stepCount, 'Fetch the qandadiv elements to shuffle'
    stepCount += 1
    
    # If no product number is given, create one for shuffling
    if seedList == []:
        pnumber = etree.Element('productnumber')
        pnumber.text = str(int(time.time()))
        seedList.append(pnumber)

    qandaset = root.find('qandaset')
    if qandaset == None:
        print >> pout, 'No element qandaset found under root'
        return 0

    qandadivs = qandaset.findall('qandadiv')
    if qandadivs == []:
        print >> pout, 'No qandadiv elements found. Nothing to shuffle.'
        return 0
    
    print >> pout, 'Step', stepCount, 'Creating hash for', len(qandadivs), \
        'qandadivs'

    # Create a dictionary with all the qandaentries hashed by the index
    # (starting at 1
    originalOrder = []
    for qandadiv in qandadivs:
        # Get all the entries
        qandaentries = qandadiv.findall('qandaentry')
        # If there is more than one, means several questions inside the same div
        if len(qandaentries) > 1:
            originalOrder.extend(qandaentries)
        # Only one question in the qandadiv
        else:
            originalOrder.append(qandadiv)
    
    # Dump all the IDs being processed
    print >> pout, 'IDs: ',
    for el in originalOrder:
        if el.tag == 'qandadiv':
            print >> pout, el.get('id'),
        else:
            p = el.getparent()
            idStr = p.get('id')
            if idStr == None:
                print 'Anomaly while shuffling. Quandadiv with no id attribute'
                print etree.tostring(p)
                sys.exit(1)
            print >> pout, idStr + '_' + str(p.findall('qandaentry').index(el)),
    print >> pout

    print >> pout, 'Step', stepCount, 'Create the permutation vectors'

    # Loop over the elements in the seedList
    permutations = []
    index = 1
    for seedElement in seedList:
        permutation = []
        result = copy.deepcopy(root)
        
        seed = long(seedElement.text)
        random.seed(seed)

        # Set the status and replace section info
        result.set("id", "AdaShuffle")
        result.set('status', str(seed))
        sectionInfo = etree.Element('sectioninfo')
        sectionInfo.extend(seedElement)
        result.insert(0, sectionInfo)

        # Get the qandadivs
        qandaset = result.find('qandaset')
        qandadivs = qandaset.findall('qandadiv')
        size = len(list(qandadivs))
        
        # Create a list with all the qandaentries in the given order
        originalOrder = []
        for qandadiv in qandadivs:
            # Get all the entries
            originalOrder.extend(qandadiv.findall('qandaentry'))
    
        # Remove the qandadivs (this is to replace them by a shuffled version)
        # There is something wrong with this function! It bombs out in some cases
        # ABEL: FIX
        map(lambda x: qandaset.remove(x), qandadivs)
        

        # Get a list representing a permutation of the indices of the list
        random.shuffle(qandadivs)

        # Reattach the qandadivs
        qandaset.extend(qandadivs)

        # Traverse the qandadivs and shuffle those with more than one
        # qandaentry. We need to preserve their positions within the quandadiv.
        for qandadiv in qandadivs:
            if len(qandadiv.findall('qandaentry')) == 1:
                continue

            # Shuffle the qandaentries inside the qandadiv
            qandaentries = qandadiv.findall('qandaentry')

            # Get the indeces of the qandaentries in the qandadiv
            children = qandadiv.getchildren()
            indeces = [children.index(x) for x in qandaentries]

            # Remove the qandaentries from the qandadiv
            map(lambda x: qandadiv.remove(x), qandaentries)

            for idx in range(0, len(indeces)):
                entry = qandaentries.pop(random.randint(0, len(qandaentries) - 1))
                qandadiv.insert(indeces[idx], entry)
                
        result = etree.ElementTree(result)
        (head, tail) = os.path.splitext(sourceFile)
        result.write(head + '_' + str(index) + tail,
                     encoding = 'UTF-8', xml_declaration = True, 
                     pretty_print = True)

        # Get again the qandadivs to dump the permutation array
        qandadivs = qandaset.findall('qandadiv')
        print >> pout, 'V00:',
        for qandadiv in qandadivs:
            for qandaentry in qandadiv.findall('qandaentry'):
                print >> pout, originalOrder.index(qandaentry),
        print >> pout

        index += 1

    return len(seedList)

# Execution as script
if __name__ == "__main__":
    main(sys.argv[1])
    
