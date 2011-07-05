#!/usr/bin/env python
# -*- coding: UTF-8 -*-#
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

# Prefix to use for the options
module_prefix = 'xfig'

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'fig2dev', i18n.get('name_of_executable')),
    ('output_format', 'png', i18n.get('output_format')),
    ('extra_arguments', '', i18n.get('extra_arguments').format('Fig2dev'))
    ]

documentation = {
    'en' : """
    Executes fig2dev to translate *.fig figures to the given "output_format" of
    all the "files".
    """}

has_executable = ''

def Execute(rule, dirObj):
    """
    Execute the rule in the given directory
    """

    global has_executable

    if has_executable == '':
	has_executable = adagio.findExecutable(next(b for (a, b, c) in options \
                                                      if a == 'exec'))

    # If the executable is not present, notify and terminate
    if not has_executable:
        program = next(b for (a, b, c) in options if a == 'exec')
        print i18n.get('no_executable').format(program)
        if dirObj.options.get(rule, 'partial') == '0':
            sys.exit(1)
        return

    # Get the files to process, if empty, terminate
    toProcess = rules.getFilesToProcess(rule, dirObj)
    if toProcess == []:
        return

    # Prepare the command to execute
    executable = dirObj.getProperty(rule, 'exec')
    dstDir = dirObj.getProperty(rule, 'dst_dir')
    outputFormat = dirObj.getProperty(rule, 'output_format')
    if outputFormat == '':
        print i18n.get('empty_output_format').format(rule)
        sys.exit(1)

    # Loop over all source files to process
    for datafile in toProcess:
        adagio.logDebug(rule, dirObj, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print i18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstFile = os.path.splitext(os.path.basename(datafile))[0] + \
            '.' + outputFormat
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

        # Add the input file to the command
        command = [executable, '-L', outputFormat]
        command.extend(dirObj.getProperty(rule,
                                                'extra_arguments').split())
        command.extend([datafile, dstFile])

        # Perform the execution
        rules.doExecution(rule, dirObj, command, datafile, dstFile,
                            adagio.userLog, adagio.userLog)

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

    dstDir = dirObj.getProperty(rule, 'dst_dir')
    outputFormat = dirObj.getProperty(rule, 'output_format')
    if outputFormat == '':
        print i18n.get('empty_output_format').format(rule)
        sys.exit(1)

    # Loop over all source files to process
    for datafile in toProcess:

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print i18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstFile = os.path.splitext(os.path.basename(datafile))[0] + \
            '.' + outputFormat
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

        if not os.path.exists(dstFile):
            continue

        rules.remove(dstFile)

    return
