#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Copyright (C) 2008 Carlos III University of Madrid
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
import os, re, sys, shutil

# Import conditionally either regular xml support or lxml if present
try:
    from lxml import etree
except ImportError:
    import xml.etree.ElementTree as etree

import Ada, Directory, I18n, Dependency, AdaRule

# Prefix to use for the options
module_prefix = 'copy'

# List of tuples (varname, default value, description string)
# The required options for this command are all contained in the defaults
options = []

documentation = {
    'en' : """
    Takes the "files" in "src_dir" and copies them to "dst_dir"
    """}

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

    # Get the files to process, if empty, terminate
    toProcess = AdaRule.getFilesToProcess(target, directory)
    if toProcess == []:
        return

    if pad == None:
	pad = ''

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target

    # Perform the copy
    doCopy(target, directory, toProcess, directory.getWithDefault(target,
                                                                  'dst_dir')
)

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
    doClean(target, directory, toProcess,
            directory.getWithDefault(target, 'dst_dir'))

    print pad + 'EE', target + '.clean'
    return

def doCopy(target, directory, toProcess, dstDir):
    """
    Effectively perform the copy. The functionality is in this function because
    it is used also by the Export rule.
    """
    # Loop over all source files to process
    for datafile in toProcess:

        Ada.logDebug(target, directory, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # What happens if DSTDIR does not exist. ¿Create?
        # If file not found, terminate
        if not os.path.isdir(dstDir):
            print I18n.get('file_not_found').format(dstDir)
            sys.exit(1)

        # Derive the destination file name
        dstFile = os.path.abspath(os.path.join(dstDir,
                                               os.path.basename(datafile)))

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

        # Proceed with the execution of xslt
        print I18n.get('producing').format(os.path.basename(dstFile))

        # Copying the file
        Ada.logDebug(target, directory, 'Copy ' + datafile + ' ' +
                     dstFile)
        shutil.copyfile(datafile, dstFile)

        # Update the dependencies of the newly created file
        try:
            Dependency.update(dstFile)
        except etree.XMLSyntaxError, e:
            print I18n.get('severe_parse_error').format(fName)
            print e
            sys.exit(1)

def doClean(target, directory, toProcess, dstDir):
    """
    Function to execute the core of the clean operation. It is in its own
    function because it is used also by the Export rule.
    """

    for datafile in toProcess:
        Ada.logDebug(target, directory, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstFile = os.path.abspath(os.path.join(dstDir,
                                               os.path.basename(datafile)))

        # If file is not there, bypass
        if not os.path.exists(dstFile):
            continue

        # Proceed with the cleaning (dump the file name being deleted)
        AdaRule.remove(dstFile)

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
