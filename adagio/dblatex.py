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
import os, sys, glob

import directory, i18n, adarule

# Prefix to use for the options
module_prefix = 'dblatex'

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'dblatex', i18n.get('name_of_executable')),
    ('output_format', 'pdf', i18n.get('output_format')),
    ('extra_arguments', '', i18n.get('extra_arguments').format('Dblatex')),
    ('extra_xslt_arguments', '', i18n.get('extra_arguments').format('Xsltproc')),
    ('compliant_mode', '0', i18n.get('').format('Xsltproc'))
    ]

documentation = {
    'en' : """

    Executes dblatex over the given "files" in the "src_dir" and produce the
    result in the "dst_dir". The "output_format" is passed directly as option -t
    to the program. Extra arguments and extra xslt arguments are also passed to
    the program.

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

    # Get the files to process, if empty, terminate
    toProcess = rules.getFilesToProcess(target, directory)
    if toProcess == []:
        return

    executable = directory.getProperty(target, 'exec')
    outputFormat = directory.getProperty(target, 'output_format')
    if not outputFormat in set(['tex', 'dvi', 'ps', 'pdf']):
        print i18n.get('program_incorrect_format').format(executable,
                                                          outputFormat)
        sys.exit(1)

    # Prepare the command to execute
    dstDir = directory.getProperty(target, 'dst_dir')
    if directory.getProperty(target, 'compliant_mode') == '1':
        compliantOptions = \
            '-P doc.collab.show=0 -P latex.output.revhistory=0'.split()
    else:
        compliantOptions = []

    extraArgs = directory.getProperty(target, 'extra_arguments')
    extraXsltArgs = directory.getProperty(target,
                                             'extra_xslt_arguments').split()
    extraXsltArgs = reduce(lambda x, y: x + ['-x', y], extraXsltArgs, [])

    commandPrefix = [executable, '-t', outputFormat]
    commandPrefix.extend(compliantOptions)
    commandPrefix.extend(extraXsltArgs)
    commandPrefix.extend(extraArgs.split())

    # Loop over all source files to process
    for datafile in toProcess:
        adagio.logDebug(target, directory, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print i18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstFile = os.path.splitext(os.path.basename(datafile))[0] + \
            '.' + outputFormat
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

        # Add the output and input files to the command
        command = commandPrefix + ['-o', dstFile] + [datafile]

        # Perform the execution
        rules.doExecution(target, directory, command, datafile, dstFile,
                            adagio.userLog, adagio.userLog)

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

    # Loop over all source files to process
    dstDir = directory.getProperty(target, 'dst_dir')
    outputFormat = directory.getProperty(target, 'output_format')
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

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, directory.getDirectoryObject('.'))
