#
# Copyright (C) 2008 Carlos III University of Madrid
# This file is part of the ADA: Agile Distributed Authoring Toolkit
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

def main(sourceFile):
    """
    Function that given a Docbook file containing a set of questions creates as
    many permutations as specified in a specific element within the
    document. The document is assumed to have a set of qandaentry elements.
    """

    stepCount = 1

    print 'Step', stepCount, 'Check file permissions'
    stepCount += 1

    if not os.path.isfile(sourceFile):
        print 'File', sourceFile, 'cannot be accessed.'
        return False

    print 'Step', stepCount, 'Create the XML document manager'
    stepCount += 1
    
    try:
        sourceTree = etree.parse(sourceFile)
        sourceTree.xinclude()
    except etree.XMLSyntaxError, e:
        print 'Error while parsing', sourceFile
        print e
        return False
    
    # Get the root and get/set the id
    root = sourceTree.getroot()
    rootId = root.get("id")
    if rootId == None:
        root.set("id", "AdaShuffle")

    # Get all product numbers from the source document
    seedList = []
    sectionInfo = root.find("sectioninfo")
    if sectionInfo != None:
        pnumbers = sectionInfo.findall("productnumber")
        if pnumbers != None:
            for pnumber in pnumbers:
                seedList.append(copy.deepcopy(pnumber))
        print 'Step', stepCount, 'Read', len(pnumbers), 'seeds in document.'
        stepCount += 1
    
    print 'Step', stepCount, 'Fetch the qandadiv elements to shuffle'
    stepCount += 1
    
    # If no product number is given, create one for shuffling
    if seedList == []:
        pnumber = etree.Element('productnumber')
        pnumber.text = int(time.time())
        seedList.append(pnumber)

    qandaset = root.find('qandaset')
    if qandaset == None:
        print 'No element qandaset found under root'
        return False

    qandadivs = qandaset.findall('qandadiv')
    if qandadivs == []:
        print 'No qandadiv elements found. Nothing to shuffle.'
        return False
    
    print 'Step', stepCount, 'Creating hash for', len(qandadivs), 'qandadivs'

    # Create a dictionary with all the qandaentries hashed by the index
    # (starting at 1
    qandadivIndex = []
    for qandadiv in qandadivs:
        # Get all the entries
        qandaentries = qandadiv.findall('qandaentry')
        # If there is more than one, means several questions inside the same div
        if len(qandaentries) > 1:
            qandadivIndex.extend(qandaentries)
        # Only one question in the qandadiv
        else:
            qandadivIndex.append(qandadiv)
    
    # Dump all the IDs being processed
    print 'IDs: ',
    for el in qandadivIndex:
        if el.tag == 'qandadiv':
            print el.get('id'),
        else:
            p = el.getparent()
            print p.get('id') + '_' + str(p.findall('qandaentry').index(el)),

    print 'Step', stepCount, 'Create the permutation vectors'

    permutations = []
    index = 1
    for seedElement in seedList:
        permutation = []
        result = copy.deepcopy(root)

        seed = long(seedElement.text)
        random.seed(seed)

        # Set the status and replace section info
        result.set('status', str(seed))
        sectionInfo = etree.Element('sectioninfo')
        sectionInfo.extend(seedElement)
        result.insert(0, sectionInfo)

        # Get the qandadivs
        qandaset = result.find('qandaset')
        qandadivs = qandaset.findall('qandadiv')
        size = len(list(qandadivs))
        
        # Remove the qandadivs (this is to replace them by a shuffled version)
        map(lambda x: qandaset.remove(x), qandadivs)

        # Get a list representing a permutation of the indices of the list
        random.shuffle(qandadivs)

        # Reattach the qandadivs
        qandaset.extend(qandadivs)

        # Traverse the qandadivs and shuffle those with more than one qandaentry
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

            print 'AAA', qandaentries
            for idx in range(0, len(indeces)):
                entry = qandaentries.pop(random.randint(0, len(qandaentries) - 1))
                print 'Insert in', indeces[idx], entry
                qandadiv.insert(indeces[idx], entry)
                
        result = etree.ElementTree(result)
        result.write(re.sub('\.xml$', '_' + str(index) + '.xml', sourceFile),
                     encoding = 'UTF-8', xml_declaration = True, 
                     pretty_print = True)
        index += 1
    # End of loop for seedElement in seedList
    print 'Step', stepCount, 'Dumping all permutations'
    print


def dmpPermutations(permutations, idxA, idxB):
    pass

# Execution as script
if __name__ == "__main__":
    main(sys.argv[1])
    
