#!/usr/bin/python
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
import os, re, sys, shutil, distutils.dir_util

# Import conditionally either regular xml support or lxml if present
try:
    from lxml import etree
except ImportError:
    import xml.etree.ElementTree as etree

import adagio, directory, i18n, dependency, rules

# Prefix to use for the options
module_prefix = 'copy'

# List of tuples (varname, default value, description string)
# The required options for this command are all contained in the defaults
options = []

documentation = {
    'en' : """
    Takes the "files" in "src_dir" and copies them to "dst_dir"
    """}

def Execute(rule, dirObj):
    """
    Execute the rule in the given directory
    """

    # Get the files to process, if empty, terminate
    toProcess = rules.getFilesToProcess(rule, dirObj)
    if toProcess == []:
        return

    # Perform the copy
    doCopy(rule, dirObj, toProcess,
           dirObj.getProperty(rule, 'src_dir'),
           dirObj.getProperty(rule, 'dst_dir'))

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
    doClean(rule, dirObj, toProcess,
            dirObj.getProperty(rule, 'src_dir'),
            dirObj.getProperty(rule, 'dst_dir'))

    return

def doCopy(rule, dirObj, toProcess, srcDir, dstDir):
    """
    Effectively perform the copy. The functionality is in this function because
    it is used also by the export rule.
    """

    # Identical source and destination, useless operation
    if os.path.abspath(srcDir) == os.path.abspath(dstDir):
        return

    # Loop over all source files to process
    for datafile in toProcess:

        # Remember if the source is a directory
        isDirectory = os.path.isdir(datafile)

        adagio.logDebug(rule, dirObj, ' EXEC ' + datafile)

        # If source is not found, terminate
        if not os.path.exists(datafile):
            print i18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Remove the srcDir prefix
        dstFile = datafile.replace(srcDir, '', 1)
        # If the result has a slash (could be a directory to copy or a file with
        # a directory path), remove it
        if dstFile[0] == '/':
            dstFile = dstFile[1:]

        # Derive the destination file name
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

        # Check for dependencies!
        try:
            sources = set([datafile])
            sources.update(dirObj.option_files)
            dependency.update(dstFile, sources)
        except etree.XMLSyntaxError, e:
            print i18n.get('severe_parse_error').format(fName)
            print str(e)
            sys.exit(1)

        # If the destination file is up to date, skip the execution
        if (not isDirectory) and dependency.isUpToDate(dstFile):
            print i18n.get('file_uptodate').format(os.path.basename(dstFile))
            continue

        # Proceed with the execution of copy
        print i18n.get('copying').format(os.path.basename(dstFile))

        # Copying the file/dir
        adagio.logDebug(rule, dirObj, 'Copy ' + datafile + ' ' +
                     dstFile)

        if os.path.isdir(datafile):
            # Copy source tree to dst tree
            distutils.dir_util.copy_tree(datafile, dstFile)
        else:
            # It is a regular file, make sure the dirs leading to it are created
            dirPrefix = os.path.dirname(dstFile)
            if not os.path.exists(dirPrefix):
                os.makedirs(dirPrefix)

            # Proceed wih the copy
            shutil.copyfile(datafile, dstFile)

        # Update the dependencies of the newly created file
        if not isDirectory:
            try:
                dependency.update(dstFile)
            except etree.XMLSyntaxError, e:
                print i18n.get('severe_parse_error').format(fName)
                print str(e)
                sys.exit(1)

def doClean(rule, dirObj, toProcess, srcDir, dstDir):
    """
    Function to execute the core of the clean operation. It is in its own
    function because it is used also by the export rule.
    """

    # Identical source and destination, useless operation
    if os.path.abspath(srcDir) == os.path.abspath(dstDir):
        return

    for datafile in toProcess:

        adagio.logDebug(rule, dirObj, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.exists(datafile):
            print i18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Remove the srcDir prefix
        dstFile = datafile.replace(srcDir, '', 1)
        # If the result has a slash, remove it
        if dstFile[0] == '/':
            dstFile = dstFile[1:]
        # Derive the destination file name
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

        # If file is not there, bypass
        if not os.path.exists(dstFile):
            continue

        # Proceed with the cleaning (dump the file name being deleted)
        rules.remove(dstFile)
