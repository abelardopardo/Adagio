#!/usr/bin/env python
# -*- coding: utf-8 -*-#
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
import os, sys, glob

import directory, i18n, rules

import adagio

# Prefix to use for the options
module_prefix = 'latex'

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'latex', i18n.get('name_of_executable')),
    ('output_format', 'pdf', i18n.get('output_format')),
    ('extra_arguments', '', i18n.get('extra_arguments').format('LaTeX'))
    ]

documentation = {
    'en' : """
    Executes LaTeX with the given extra arguments over "files".
    """}

has_executable = ''

def Execute(rule, dirObj):
    """
    Execute the rule in the given directory
    """

    global has_executable

    if has_executable == '':
	has_executable = adagio.findExecutable(rule, dirObj)

    # If the executable is not present, notify and terminate
    if not has_executable:
        print i18n.get('no_executable').format(dirObj.options.get(rule, 'exec'))
        if dirObj.options.get(rule, 'partial') == '0':
            sys.exit(1)
        return

    # Get the files to process, if empty, terminate
    toProcess = rules.getFilesToProcess(rule, dirObj)
    if toProcess == []:
        return

    executable = dirObj.getProperty(rule, 'exec')
    outputFormat = dirObj.getProperty(rule, 'output_format')
    if not outputFormat in set(['dvi', 'pdf', 'dvipdf']):
        print i18n.get('program_incorrect_format').format(executable,
                                                          outputFormat)
        sys.exit(1)

    # Prepare the command to execute
    dstDir = dirObj.getProperty(rule, 'dst_dir')
    commandPrefix = [executable, '-output-directory=' + dstDir,
                     '-interaction=nonstopmode']
    if outputFormat != 'dvipdf':
        commandPrefix.append('-output-format=' + outputFormat)
    commandPrefix.extend(dirObj.getProperty(rule,
                                                  'extra_arguments').split())

    # Loop over all source files to process
    for datafile in toProcess:
        adagio.logDebug(rule, dirObj, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print i18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        baseName = os.path.splitext(os.path.basename(datafile))[0]
        if outputFormat != 'dvipdf':
            dstFile = baseName + '.' + outputFormat
        else:
            dstFile = baseName + '.dvi'
            pdfFile = baseName + '.pdf'
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

        # Add the input file to the command
        command = commandPrefix + [datafile]

        # Perform the execution
        rules.doExecution(rule, dirObj, command, datafile, dstFile,
                            adagio.userLog)
        if outputFormat == 'dvipdf':
            rules.doExecution(rule, dirObj, ['dvipdf', dstFile], datafile,
                              pdfFile, adagio.userLog)
    return

def clean(rule, dirObj):
    """
    Clean the files produced by this rule
    """

    adagio.logInfo(rule, dirObj, 'Cleaning')

    # Get the files to process
    toProcess = rules.getFilesToProcess(rule, dirObj)
    if toProcess == []:
        return

    # Loop over all source files to process
    dstDir = dirObj.getProperty(rule, 'dst_dir')
    outputFormat = dirObj.getProperty(rule, 'output_format')
    for datafile in toProcess:

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print i18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstPrefix = os.path.splitext(os.path.basename(datafile))[0]
        dstPrefix = os.path.join(dstDir, dstPrefix)

        extensionsToClean = ['out', 'aux', 'log', 'bbl', 'blg', 'idx',
                             'ilg', 'ind', 'lof', 'lot', 'toc']
        if outputFormat != 'dvipdf':
            extensionsToClean.append(outputFormat)
        else:
            extensionsToClean.append('dvi')
            extensionsToClean.append('pdf')

        for fmt in extensionsToClean:
            dstFile = dstPrefix + '.' + fmt

            if not os.path.exists(dstFile):
                continue

            rules.remove(dstFile)

    return
