#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Copyright (C) 2010 Carlos III University of Madrid
# This file is part of the ADA: Agile Distributed Authoring Toolkit

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

import Ada, Directory, I18n, AdaRule, Xsltproc

# Prefix to use for the options
module_prefix = 'exam'

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
    Rule to typeset an exam from an XML file. The "files" are processed to
    render them as exams with the following versions:

    - One per language in "languages"
    - One per version in produce:
      * regular: regular version, no solution, no pguide
      * solution: regular version with the solution
      * pguide: regular version including solution AND professor guide
    """}

def Execute(target, directory, pad = None):
    """
    Execute the rule in the given directory
    """

    global module_prefix
    global documentation

    Ada.logInfo(target, directory, 'Enter ' + directory.current_dir)

    # Detect and execute "special" targets
    if AdaRule.specialTargets(target, directory, module_prefix, clean, pad):
        return

    # Get the files to process, if empty, terminate
    toProcess = AdaRule.getFilesToProcess(target, directory)
    if toProcess == []:
        return

    if pad == None:
	pad = ''

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target

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
    Xsltproc.doTransformations(styleFiles.split(), styleTransform, styleParams,
                               toProcess, target, directory, paramDict)

    print pad + 'EE', target
    return

def clean(target, directory, pad = None):
    """
    Clean the files produced by this rule
    """

    Ada.logInfo(target, directory, 'Cleaning')

    # Get the files to process
    toProcess = AdaRule.getFilesToProcess(target, directory)
    if toProcess == []:
        return

    if pad == None:
	pad = ''

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target + '.clean'

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

    Xsltproc.doClean(target, directory, toProcess, suffixes)

    print pad + 'EE', target + '.clean'
    return

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
