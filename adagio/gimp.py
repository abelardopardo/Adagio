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

import directory, i18n, dependency, rules.

# Prefix to use for the options
module_prefix = 'gimp'

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'gimp', i18n.get('name_of_executable')),
    ('script', '%(home)s%(file_separator)sbin%(file_separator)sxcftopng.scm', 
     i18n.get('gimp_script')),
    ('extra_arguments', '', i18n.get('extra_arguments').format('Gimp'))
    ]

documentation = {
    'en' : """
    All files *.xcf in the current directory are transformed to *.png.

    The script is a program written in Lisp that is passed as GIMP input. There
    is no possibility to choose the source files, all *.xcf are processed, and
    the destination directory is the same as the source directory. The
    transformation will only change the file extension.
    """}

has_executable = rules.which(next(b for (a, b, c) in options if a == 'exec'))

def Execute(target, directory):
    """
    Execute the rule in the given directory
    """

    global has_executable

    # If the executable is not present, notify and terminate
    if not has_executable:
        print i18n.get('no_executable').format(options['exec'])
        if directory.options.get(target, 'partial') == '0':
            sys.exit(1)
        return

    # Get the files to process (all *.xcf in the current directory)
    toProcess = glob.glob(os.path.join(directory.current_dir, '*.xcf'))
    if toProcess == []:
        adagio.logDebug(target, directory, i18n.get('no_file_to_process'))
        return

    scriptFileName = directory.getProperty(target, 'script')
    if not os.path.isfile(scriptFileName):
        print i18n.get('file_not_found').format(scriptFileName)
        sys.exit(1)
    scriptFile = open(scriptFileName, 'r')

    # Loop over the source files to see if an execution is needed
    dstFiles = []
    dstDir = directory.getProperty(target, 'src_dir')
    for datafile in toProcess:
        adagio.logDebug(target, directory, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print i18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstFile = os.path.splitext(os.path.basename(datafile))[0] + '.png'
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

        # Check for dependencies!
        try:
            sources = set([datafile])
            sources.update(directory.option_files)
            dependency.update(dstFile, sources)
        except etree.XMLSyntaxError, e:
            print i18n.get('severe_parse_error').format(fName)
            print str(e)
            sys.exit(1)

        # If the destination file is up to date, skip the execution
        if dependency.isUpToDate(dstFile):
            print i18n.get('file_uptodate').format(os.path.basename(dstFile))
            continue

        # Remember the files to produce
        dstFiles.append(dstFile)

    # If the execution is needed
    if dstFiles != []:
        executable = directory.getProperty(target, 'exec')
        extraArgs = directory.getProperty(target, 'extra_arguments')

        # Proceed with the execution
        fnames = ' '.join([os.path.basename(x) for x in dstFiles])
        print i18n.get('producing').format(os.path.basename(fnames))

        command = [executable, '--no-data', '--no-fonts', '--no-interface', 
                   '-b', '-']

        rules.doExecution(target, directory, command, None, None,
                            stdout = adagio.userLog, stdin = scriptFile)

        # If dstFile does not exist, something went wrong
        if next((x for x in dstFiles if not os.path.exists(x)), None):
            print i18n.get('severe_exec_error').format(executable)
            sys.exit(1)

        # Update the dependencies of the newly created files
        try:
            map(lambda x: dependency.update(x), dstFiles)
        except etree.XMLSyntaxError, e:
            print i18n.get('severe_parse_error').format(fName)
            print str(e)
            sys.exit(1)

    return

def clean(target, directory):
    """
    Clean the files produced by this rule
    """
    
    adagio.logInfo(target, directory, 'Cleaning')

    # Get the files to process
    toProcess = glob.glob(os.path.join(directory.current_dir, '*.xcf'))
    if toProcess == []:
        adagio.logDebug(target, directory, i18n.get('no_file_to_process'))
        return

    # Loop over the source files to see if an execution is needed
    dstFiles = []
    dstDir = directory.getProperty(target, 'src_dir')
    for datafile in toProcess:

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print i18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstFile = os.path.splitext(os.path.basename(datafile))[0] + '.png'
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

        if not os.path.exists(dstFile):
            continue

        rules.remove(dstFile)

    return
    
# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, directory.getDirectoryObject('.'))
