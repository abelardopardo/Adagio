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
import os, re, sys, glob

import directory, i18n, adarule, xsltproc

# Prefix to use for the options
module_prefix = 'exam'

# List of tuples (varname, default value, description string)
options = [
    ('styles',
     '%(home)s%(file_separator)sADA_Styles%(file_separator)sExam.xsl',
     i18n.get('xslt_style_file')),
    ('output_format', 'html', i18n.get('output_format')),
    ('extra_arguments', '', i18n.get('extra_arguments').format('Xsltproc')),
    ('produce', 'regular', i18n.get('exercise_produce'))
    ]

documentation = {
    'en' : """
    Rule to typeset an exam from an XML file. The "files" are processed to
    render them as exams with the following versions:

    - One per language in "languages"
    - One per version in produce:
      * regular: regular version, no solution, no pguide
      * solution: regular version with the solution
      * pguide: regular version including solution AND professor guide
    """}

def Execute(target, directory):
    """
    Execute the rule in the given directory
    """

    # Get the files to process, if empty, terminate
    toProcess = rules.getFilesToProcess(target, directory)
    if toProcess == []:
        return

    # Prepare the style transformation
    styleFiles = directory.getProperty(target, 'styles')
    styleTransform = xsltproc.createStyleTransform(styleFiles.split())
    if styleTransform == None:
        print i18n.get('no_style_file')
        return

    # Create the dictionary of stylesheet parameters
    styleParams = xsltproc.createParameterDict(target, directory)

    # Create a list with the param dictionaries to use in the different versions
    # to be created.
    paramDict = []
    produceValues = set(directory.getProperty(target, 'produce').split())
    if 'regular' in produceValues:
        # Create the regular version, no additional parameters needed
        paramDict.append(({}, ''))
    if 'solution' in produceValues:
        paramDict.append(({'solutions.include.guide': "'yes'",
                           'ada.testquestions.include.solutions': "'yes'"},
                          '_solution'))
    if 'pguide' in produceValues:
        paramDict.append(({'solutions.include.guide': "'yes'",
                           'ada.testquestions.include.solutions': "'yes'",
                           'professorguide.include.guide': "'yes'",
                           'ada.testquestions.include.id': "'yes'",
                           'ada.testquestions.include.history': "'yes'"},
                          '_pguide'))

    # Apply all these transformations.
    xsltproc.doTransformations(styleFiles.split(), styleTransform, styleParams,
                               toProcess, target, directory, paramDict)

    return

def clean(target, directory):
    """
    Clean the files produced by this rule
    """

    adagio.logInfo(target, directory, 'Cleaning')

    # Get the files to process
    toProcess = rules.getFilesToProcess(target, directory)
    if toProcess == []:
        return

    suffixes = []
    produceValues = set(directory.getProperty(target, 'produce').split())
    if 'regular' in produceValues:
        # Delete the regular version
        suffixes.append('')
    if 'solution' in produceValues:
        # Delete the solution
        suffixes.append('_solution')
    if 'pguide' in produceValues:
        # Delete the professor guide
        suffixes.append('_pguide')

    xsltproc.doClean(target, directory, toProcess, suffixes)

    return

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, directory.getDirectoryObject('.'))
