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

import directory, i18n, dependency, adarule, properties, treecache

# Prefix to use for the options
module_prefix = 'gotodir'

# List of tuples (varname, default value, description string)
options = [
    ('export_dst', '', i18n.get('export_dst')),
    ('files_included_from', '', i18n.get('export_targets')),
    ('targets', '', i18n.get('export_targets'))
    ]

documentation = {
    'en' : """
    The execution of the "targets" is invoked in every directory in "files".

    If the value "exports_dst" is given, it overrides the value of
    export.dst_dir in the remote directory.
    """}

def Execute(target, directory, pad = None):
    """
    Execute the rule in the given directory
    """

    if pad == 'None':
        pad = ''

    (toProcess, remoteTargets,
     optionsToSet, newExportDir) = prepareTarget(target,directory)

    # Loop over each directory
    for dirName in toProcess:
        Ada.logInfo(target, directory, 'RECUR: ' + dirName)
        dirObj = directory.getDirectoryObject(dirName, optionsToSet)
        dirObj.Execute(remoteTargets, pad + '  ')

    return

def clean(target, directory, deepClean = False, pad = None):
    """
    Clean the files produced by this rule
    """

    global module_prefix

    if pad == None:
        pad = ''

    Ada.logInfo(target, directory, 'Cleaning')

    (toProcess, remoteTargets,
     optionsToSet, newExportDir) = prepareTarget(target,
                                                 directory)

    # When cleaning, targets should be executed in reversed order
    remoteTargets.reverse()

    if deepClean:
        # If the clean is deep, attach .clean suffix to all remote targets
        remoteTargets = [x + '.deepclean'
                         for x in remoteTargets
                         if not re.match('(.+\.)?help$', x) and \
                             not re.match('(.+\.)?clean$', x) and \
                             not re.match('(.+\.)?dumphelp$', x) and \
                             not re.match('(.+\.)?helpdump$', x)]

        # If no rule is obtained, deep clean, means simply execute the clean
        # rule
        if remoteTargets == []:
            remoteTargets = ['deepclean']
    else:
        # If the clean is not deep, the target only propagates to those targets
        # of type export and if the newExportDir is this directory (to clean the
        # current directory only). Otherwise, the target is simply ignore.
        if newExportDir != directory.current_dir:
            return

        remoteTargets = [x + '.clean'  for x in remoteTargets
                         if x.startswith('export')]

    Ada.logInfo(target, directory,
                'Remote Targets = ' + ' '.join(remoteTargets))

    # Loop over each directory
    for dirName in toProcess:

        Ada.logInfo(target, directory, 'RECUR: ' + dirName)
        dirObj = directory.getDirectoryObject(dirName, optionsToSet)

        # If the clean is not deep and there is no given remote targets, we need
        # to select as targets those that start with 'export'
        if (not deepClean) and (remoteTargets == []):
            remoteTargets = [x + '.clean' for x in dirObj.section_list
                             if re.match('^export(\..+)?$',
                                         properties.expandAlias(x,
                                                                dirObj.alias))]

        # Execute the remote targets
        dirObj.Execute(remoteTargets, pad + '  ')

    return

def prepareTarget(target, directory):
    """
    Obtain the directories to process, calculate the optiost to set in the
    remote execution and obtain the remote targets.

    Return:

    (list of dirs to process, remote targets, options to set in the remote exec)
    """

    # Get the directories to process from the files option
    toProcess = []
    for srcDir in directory.getProperty(target, 'files').split():
        newDirs = glob.glob(srcDir)
        if newDirs == []:
            print i18n.get('file_not_found').format(srcDir)
            sys.exit(1)
        toProcess.extend(glob.glob(srcDir))

    # Add the files included in files_included_from
    filesIncluded = \
        obtainXincludes(directory.getProperty(target,
                                              'files_included_from').split())

    # The list of dirs is extended with a set to avoid duplications
    toProcess.extend(set(map(lambda x: os.path.dirname(x), filesIncluded)))

    # If there are no files to process stop
    if toProcess == []:
        Ada.logDebug(target, directory, i18n.get('no_file_to_process'))
        return (toProcess, [], None, '')

    # Translate all paths to absolute paths
    toProcess = map(lambda x: os.path.abspath(x), toProcess)

    # Targets to execute in the remote directory
    remoteTargets = directory.getProperty(target, 'targets').split()

    # Create the option dict for the remote directories
    optionsToSet = []
    newExportDir = directory.getProperty(target, 'export_dst')
    if newExportDir != '':
        # If a new dst_dir has been specified, include the options to modify
        # that variable for each of the targets
        if remoteTargets != []:
            # If there are some targets given, use them
            optionsToSet = [x + ' dst_dir ' + newExportDir
                            for x in remoteTargets if x.startswith('export')]
        else:
            # If no target is given, leave the option in the export.dst_dir
            # default
            optionsToSet = ['export dst_dir ' + newExportDir]

    Ada.logInfo(target, directory, 'NEW Options = ' + ', '.join(optionsToSet))

    return (toProcess, remoteTargets, optionsToSet, newExportDir)

def obtainXincludes(files):
    """
    Obtain the files included using xinclude in the given file. Return a list
    with the absolute filenames
    """

    result = set([])
    for fileName in files:
        # We only accept absolute paths
        if not os.path.isabs(fileName):
            fileName = os.path.abspath(fileName)

        # Get the directory where the file is located
        fDir = os.path.dirname(fileName)

        # Get the file parsed without expanding the xincludes
        root = treecache.findOrAddTree(fileName, False)

        # Path to locate the includes and dir of the given file
        includePath = '//{http://www.w3.org/2001/XInclude}include'

        # Obtain the included files
        includeFiles = \
            set([os.path.join(
                    x.attrib.get('{http://www.w3.org/XML/1998/namespace}base',
                                 ''),
                    x.attrib.get('href'))
                 for x in root.findall(includePath)
                 if x.attrib.get('href') != None])

        # Traverse all the include files
        for includeFile in includeFiles:
            # Locate the file applying ADA search rules
            locatedFile = AdaRule.locateFile(includeFile, fDir)

            # If not found, notify and terminate
            if locatedFile == None:
                print i18n.get('file_not_found').format(includeFile)
                print i18n.get('included_from'), fileName
                sys.exit(1)

            if os.path.dirname(os.path.abspath(locatedFile)) == fDir:
                # If it is in the same dir, prepare to traverse
                files.append(locatedFile)
            else:
                # If in another dir, append to the result
                result.add(os.path.abspath(locatedFile))

    return result

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, directory.getDirectoryObject('.'))
