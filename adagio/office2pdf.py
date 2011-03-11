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
import os, re, sys

import adagio, directory, i18n, rules

# Prefix to use for the options
module_prefix = 'office2pdf'

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'soffice', i18n.get('name_of_executable')),
    ('extra_arguments', '', i18n.get('extra_arguments').format('OpenOffice'))
    ]

documentation = {
    'en' : """
    This target invokes OpenOffice to obtain a PDF version of the given
    files. It assumes that there is a Macro already installed with name
    SaveAsPDF.
    """}

has_executable = rules.which(next(b for (a, b, c) in options if a == 'exec'))

def Execute(target, dirObj):
    """
    Execute the rule in the given directory
    """

    global has_executable

    # If the executable is not present, notify and terminate
    if not has_executable:
        print i18n.get('no_executable').format(options['exec'])
        if dirObj.options.get(target, 'partial') == '0':
            sys.exit(1)
        return

    # Get the files to process, if empty, terminate
    toProcess = rules.getFilesToProcess(target, dirObj)
    if toProcess == []:
        adagio.logDebug(target, dirObj, i18n.get('no_file_to_process'))
        return

    # Loop over all source files to process
    executable = dirObj.getProperty(target, 'exec')
    extraArgs = dirObj.getProperty(target, 'extra_arguments')
    command = [executable, '-nologo', '-invisible', '-headless']
    command.extend(extraArgs.split())
    dstDir = dirObj.getProperty(target, 'src_dir')
    for datafile in toProcess:
        adagio.logDebug(target, dirObj, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print i18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstFileName = os.path.splitext(os.path.basename(datafile))[0] + \
            '.pdf'
        dstFile = os.path.abspath(os.path.join(dstDir, dstFileName))

        # Perform the execution
        command.append('macro:///Tools.MSToPDF.ConvertMSToPDF(' + datafile + ')')

        rules.doExecution(target, dirObj, command, datafile, dstFile,
                            stdout = adagio.userLog)
        command.pop(-1)

    # End of loop over all src files

    return

def clean(target, dirObj):
    """
    Clean the files produced by this rule
    """

    adagio.logInfo(target, dirObj, 'Cleaning')

    # Get the files to process
    toProcess = rules.getFilesToProcess(target, dirObj)
    if toProcess == []:
        return

    # Loop over all the source files
    dstDir = dirObj.getProperty(target, 'src_dir')
    for datafile in toProcess:

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print i18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstFile = os.path.splitext(os.path.basename(datafile))[0] + \
            '.pdf'
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

        if not os.path.exists(dstFile):
            continue

        rules.remove(dstFile)
