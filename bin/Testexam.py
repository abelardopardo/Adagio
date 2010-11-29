#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, re, sys, glob

try:
    from lxml import etree
except ImportError:
    import xml.etree.ElementTree as etree

import Ada, Directory, I18n, AdaRule, Xsltproc, TestShuffle, Dependency

# Prefix to use for the options
module_prefix = 'testexam'

# List of tuples (varname, default value, description string)
options = [
    ('styles', 
     '%(home)s%(file_separator)sADA_Styles%(file_separator)sExam.xsl',
     I18n.get('xslt_style_file')),
    ('output_format', 'html', I18n.get('output_format')),
    ('extra_arguments', '', I18n.get('extra_arguments').format('Xsltproc')),
    ('produce', 'regular', I18n.get('exercise_produce')),
    ('languages', '%(locale)s', I18n.get('languages'))
    ]

documentation = {
    'en' : """
    Rule to typeset a test exam from an XML file. The "files" are processed to
    render them as test exams with the following versions:

    - One per language in "languages"
    - One per version in produce:
      * regular: regular version, no solution, no pguide
      * solution: regular version with the solution
      * pguide: regular version including solution AND professor guide
    """}

def Execute(target, directory, pad = ''):
    """
    Execute the rule in the given directory
    """

    global module_prefix
    global documentation

    Ada.logInfo(target, directory, 'Enter ' + directory.current_dir)

    # Detect and execute "special" targets
    if AdaRule.specialTargets(target, directory, documentation, 
                                     module_prefix, clean, pad):
        return

    # Get the files to process, if empty, terminate
    toProcess = AdaRule.getFilesToProcess(target, directory)
    if toProcess == []:
        return

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target

    # Every source file given is processed to know how many permutations will be
    # rawFiles contains the list of files produced that need to be processed
    rawFiles = doShuffle(toProcess, directory)

    # Prepare the style transformation
    styleFiles = directory.getWithDefault(target, 'styles')
    styleTransform = Xsltproc.createStyleTransform(styleFiles.split())
    if styleTransform == None:
        print I18n.get('no_style_file')
        print pad + 'EE', target
        return

    # Create the dictionary of stylesheet parameters
    styleParams = Xsltproc.createParameterDict(target, directory)
    
    # Create a list with the param dictionaries to use in the different versions
    # to be created.
    paramDict = []
    produceValues = set(directory.getWithDefault(target, 'produce').split())
    if 'regular' in produceValues:
        # Create the regular version, no additional parameters needed
        paramDict.append(({}, ''))
    if 'solution' in produceValues:
        paramDict.append(({'solutions.include.guide': 'yes',
                           'ada.testquestions.include.solutions': 'yes'}, 
                          '_solution'))
    if 'pguide' in produceValues:
        paramDict.append(({'solutions.include.guide': 'yes',
                           'ada.testquestions.include.solutions': 'yes',
                           'professorguide.include.guide': 'yes',
                           'ada.testquestions.include.id': 'yes',
                           'ada.testquestions.include.history': 'yes'},
                          '_pguide'))

    # Apply all these transformations.
    Xsltproc.doTransformations(styleFiles.split(), styleTransform, styleParams, 
                               rawFiles, target, directory, paramDict)

    print pad + 'EE', target
    return

def clean(target, directory, pad):
    """
    Clean the files produced by this rule
    """
    
    Ada.logInfo(target, directory, 'Cleaning')

    # Get the files to process
    toProcess = AdaRule.getFilesToProcess(target, directory)
    if toProcess == []:
        return

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target + '.clean'

    rawFiles = []
    for fname in toProcess:
        # Get the result files
        resultFiles = doGetShuffledFiles(fname)
        
        # Accumulate the list
        rawFiles.extend(resultFiles)

    suffixes = []
    produceValues = set(directory.getWithDefault(target, 'produce').split())
    if 'regular' in produceValues:
        # Delete the regular version
        suffixes.append('')
    if 'solution' in produceValues:
        # Delete the solution
        suffixes.append('_solution')
    if 'pguide' in produceValues:
        # Delete the professor guide
        suffixes.append('_pguide')

    Xsltproc.doClean(target, directory, rawFiles, suffixes)

    # Clean also the produced files
    map(lambda x: AdaRule.remove(x), rawFiles)

    print pad + 'EE', target + '.clean'
    return

def doShuffle(toProcess, directory):
    # Every source file given is processed to know how many permutations will be
    # produced.
    rawFiles = []
    for fname in toProcess:
        # Get the result files
        resultFiles = doGetShuffledFiles(fname)
        
        # Accumulate the list
        rawFiles.extend(resultFiles)

        # Update the dependencies (apply update to all elements in resultFiles)
        map(lambda x: Dependency.update(x, 
                                        set([fname] + directory.option_files)),
            resultFiles)

        # If all the permutation files are up to date, no need to process
        if reduce(lambda x, y: x and y, 
                  [Dependency.isUpToDate(x) for x in resultFiles]):
            print I18n.get('testexam_no_shuffle_required').format(fname)
            continue
        
        print I18n.get('testexam_shuffling').format(fname)
        TestShuffle.main(fname, Ada.userLog)

    return rawFiles

def doGetShuffledFiles(fname):
    """
    Function that given an XML file, checks the presence of productnumber
    elements in the section info and returns the names of the files which will
    contain the permutations.
    """
    try:
        sourceTree = etree.parse(fname)
        sourceTree.xinclude()
    except etree.XMLSyntaxError, e:
        print I18n.get('severe_parse_error').format(fname)
        sys.exit(1)
    root = sourceTree.getroot()

    # Get the number of 'productnumber' elements. If none, set it to 1
    sectionInfo = root.find('sectioninfo')
    n = 1
    if sectionInfo != None:
        pnumbers = sectionInfo.findall('productnumber')
        if pnumbers != None:
            n = len(pnumbers)
        
    # Create the raw files that will be produced
    (h, t) = os.path.splitext(fname)
    return map(lambda x: h + '_' + str(x) + t, range(1, n + 1))

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
