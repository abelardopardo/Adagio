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

import Ada, Directory, I18n, Dependency, AdaRule

# Prefix to use for the options
module_prefix = 'gimp'

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'gimp', I18n.get('name_of_executable')),
    ('script', '%(home)s%(file_separator)sbin%(file_separator)sxcftopng.scm', 
     I18n.get('gimp_script')),
    ('extra_arguments', '', I18n.get('extra_arguments').format('Inkscape'))
    ]

documentation = {
    'en' : """
    All files *.xcf in the current directory are transformed to *.png.

    The script is a program written in Lisp that is passed as GIMP input. There
    is no possibility to choose the source files, all *.xcf are processed, and
    the destination directory is the same as the source directory. The
    transformation will only change the file extension.
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
    if AdaRule.specialTargets(target, directory, module_prefix, clean, pad):
        return

    # If the executable is not present, notify and terminate
    if not has_executable:
        print I18n.get('no_executable').format(options['exec'])
        if directory.options.get(target, 'partial') == '0':
            sys.exit(1)
        return

    # Get the files to process (all *.xcf in the current directory)
    toProcess = glob.glob(os.path.join(directory.current_dir, '*.xcf'))
    if toProcess == []:
        Ada.logDebug(target, directory, I18n.get('no_file_to_process'))
        return

    if pad == None:
	pad = ''

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target

    scriptFileName = directory.getWithDefault(target, 'script')
    if not os.path.isfile(scriptFileName):
        print I18n.get('file_not_found').format(scriptFileName)
        sys.exit(1)
    scriptFile = open(scriptFileName, 'r')

    # Loop over the source files to see if an execution is needed
    dstFiles = []
    dstDir = directory.getWithDefault(target, 'src_dir')
    for datafile in toProcess:
        Ada.logDebug(target, directory, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstFile = os.path.splitext(os.path.basename(datafile))[0] + '.png'
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

        # Check for dependencies!
        try:
            sources = set([datafile])
            sources.update(directory.option_files)
            Dependency.update(dstFile, sources)
        except etree.XMLSyntaxError, e:
            print I18n.get('severe_parse_error').format(fName)
            print e
            sys.exit(1)

        # If the destination file is up to date, skip the execution
        if Dependency.isUpToDate(dstFile):
            print I18n.get('file_uptodate').format(os.path.basename(dstFile))
            continue

        # Remember the files to produce
        dstFiles.append(dstFile)

    # If the execution is needed
    if dstFiles != []:
        executable = directory.getWithDefault(target, 'exec')
        extraArgs = directory.getWithDefault(target, 'extra_arguments')

        # Proceed with the execution
        fnames = ' '.join([os.path.basename(x) for x in dstFiles])
        print I18n.get('producing').format(os.path.basename(fnames))

        command = [executable, '--no-data', '--no-fonts', '--no-interface', 
                   '-b', '-']

        AdaRule.doExecution(target, directory, command, None, None,
                            stdout = Ada.userLog, stdin = scriptFile)

        # If dstFile does not exist, something went wrong
        if next((x for x in dstFiles if not os.path.exists(x)), None):
            print I18n.get('severe_exec_error').format(executable)
            sys.exit(1)

        # Update the dependencies of the newly created files
        try:
            map(lambda x: Dependency.update(x), dstFiles)
        except etree.XMLSyntaxError, e:
            print I18n.get('severe_parse_error').format(fName)
            print e
            sys.exit(1)

    print pad + 'EE', target
    return

def clean(target, directory, pad = None):
    """
    Clean the files produced by this rule
    """
    
    Ada.logInfo(target, directory, 'Cleaning')

    # Get the files to process
    toProcess = glob.glob(os.path.join(directory.current_dir, '*.xcf'))
    if toProcess == []:
        Ada.logDebug(target, directory, I18n.get('no_file_to_process'))
        return

    if pad == None:
	pad = ''

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target + '.clean'

    # Loop over the source files to see if an execution is needed
    dstFiles = []
    dstDir = directory.getWithDefault(target, 'src_dir')
    for datafile in toProcess:

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstFile = os.path.splitext(os.path.basename(datafile))[0] + '.png'
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

        if not os.path.exists(dstFile):
            continue

        AdaRule.remove(dstFile)

    print pad + 'EE', target + '.clean'
    return
    
# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
