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

import Ada, Directory, I18n, AdaRule

# Prefix to use for the options
module_prefix = 'rsync'

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'rsync', I18n.get('name_of_executable')),
    ('src_dir', '', I18n.get('rsync_src_dir')),
    ('dst_dir', '', I18n.get('rsync_dst_dir')),
    ('extra_arguments', '', I18n.get('extra_arguments').format('Dblatex'))
    ]

documentation = {
    'en' : """

    Executes the rsync program to synchronize src_dir with dst_dir. The value of
    "files" is ignored.

    """}

has_executable = AdaRule.which(next(b for (a, b, c) in options if a == 'exec'))

def Execute(target, directory, pad = None):
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

    # If the executable is not present, notify and terminate
    if not has_executable:
        print I18n.get('no_executable').format(options['exec'])
        if directory.options.get(target, 'partial') == '0':
            sys.exit(1)
        return

    # Get the directories to synchronize, check if work is needed
    srcDir = directory.geWithDefault(target, 'src_dir')
    dstDir = directory.getWithDefault(target, 'dst_dir')
    if srcDir == '' or dstDir == '' or srcDir == dstDir:
        return

    # If source directory does not exist, terminate

    if pad == None:
	pad = ''

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target

    # Prepare the command to execute
    executable = directory.getWithDefault(target, 'exec')
    extraArgs = directory.getWithDefault(target, 'extra_arguments')

    commandPrefix = [executable, '-avz']
    commandPrefix.append(srcDir)
    commandPrefix.append(dstDir)

    Ada.logDebug(target, directory, ' EXEC ' + srcDir + ' ' + dstDir)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstFile = os.path.splitext(os.path.basename(datafile))[0] + \
            '.' + outputFormat
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))
                                                   
        # Add the output and input files to the command
        command = commandPrefix + ['-o', dstFile] + [datafile]

        # Perform the execution
        AdaRule.doExecution(target, directory, command, datafile, dstFile, 
                            Ada.userLog, Ada.userLog)

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

    # Loop over all source files to process
    dstDir = directory.getWithDefault(target, 'dst_dir')
    outputFormat = directory.getWithDefault(target, 'output_format')
    for datafile in toProcess:

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstFile = os.path.splitext(os.path.basename(datafile))[0] + \
            '.' + outputFormat
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))
                                                   
        if not os.path.exists(dstFile):
            continue

        AdaRule.remove(dstFile)

    print pad + 'EE', target + '.clean'
    return

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
