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
import os, re, sys, glob

import adagio, directory, i18n, rules

# Prefix to use for the options
module_prefix = 'rsync'

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'rsync', i18n.get('name_of_executable')),
    ('src_dir', '', i18n.get('rsync_src_dir')),
    ('dst_dir', '', i18n.get('rsync_dst_dir')),
    ('extra_arguments', '', i18n.get('extra_arguments').format('Dblatex'))
    ]

documentation = {
    'en' : """

    Executes the rsync program to synchronize src_dir with dst_dir. The value of
    "files" is ignored.

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
        program = next(b for (a, b, c) in options if a == 'exec')
        print i18n.get('no_executable').format(program)
        if dirObj.options.get(rule, 'partial') == '0':
            sys.exit(1)
        return

    # Get the directories to synchronize, check if work is needed
    srcDir = dirObj.getProperty(rule, 'src_dir')
    dstDir = dirObj.getProperty(rule, 'dst_dir')
    if srcDir == '' or dstDir == '' or srcDir == dstDir:
        return

    # If source directory does not exist, terminate
    if not os.path.isdir(srcDir):
        print i18n.get('not_a_directory')
        sys.exit(1)

    # Prepare the command to execute
    executable = dirObj.getProperty(rule, 'exec')
    extraArgs = dirObj.getProperty(rule, 'extra_arguments')

    command = [executable, '-avz']
    command.append(srcDir)
    command.append(dstDir)

    adagio.logDebug(rule, dirObj, ' EXEC ' + srcDir + ' ' + dstDir)

    # Perform the execution
    rules.doExecution(rule, dirObj, command, srcDir, None,
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

    # Get the dstDir
    dstDir = dirObj.getProperty(rule, 'dst_dir')

    # If dist dir not found, terminate
    if not os.path.isdir(dstDir):
        print i18n.get('file_not_found').format(dstDir)
        sys.exit(1)

    # Delete the dst directory
    rules.remove(dstDir)

    return
