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
import os, re, sys, glob

import Ada, Directory, I18n, Dependency, AdaRule

# Prefix to use for the options
module_prefix = 'gotodir'

# List of tuples (varname, default value, description string)
options = [
    ('export_dst', '', I18n.get('export_dst')),
    ('targets', '', I18n.get('export_targets'))
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

    global module_prefix
    global documentation

    Ada.logInfo(target, directory, 'Enter ' + directory.current_dir)

    # Detect and execute "special" targets
    if AdaRule.specialTargets(target, directory, documentation, 
                                     module_prefix, clean, pad):
        return

    # Get the directories to process, if none, terminate silently
    toProcess = []
    for srcDir in directory.getWithDefault(target, 'files').split():
        newDirs = glob.glob(srcDir)
        if newDirs == []:
            print I18n.get('file_not_found').format(srcDir)
            sys.exit(1)
        toProcess.extend(glob.glob(srcDir))
    if toProcess == []:
        Ada.logDebug(target, directory, I18n.get('no_file_to_process'))
        return

    # Translate all paths to absolute paths
    toProcess = map(lambda x: os.path.abspath(x), toProcess)

    if pad == None:
	pad = ''

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target

    # Get option to set in the remote directory
    optionsToSet = []
    newExportDir = directory.getWithDefault(target, 'export_dst')
    if newExportDir != '':
        optionsToSet = ['export dst_dir ' + newExportDir]
    Ada.logInfo(target, directory, 'NEW export.dst_dir = ' + newExportDir)

    # Targets to execute in the remote directory
    remoteTargets = directory.getWithDefault(target, 'targets').split()

    # Loop over each directory
    for dirName in toProcess:

        Ada.logInfo(target, directory, 'RECUR: ' + dirName)

        dirObj = Directory.getDirectoryObject(dirName, optionsToSet)
        dirObj.Execute(remoteTargets, pad + '  ')

    print pad + 'EE', target
    return

def clean(target, directory, pad = None):
    """
    Clean the files produced by this rule
    """
    
    global module_prefix

    Ada.logInfo(target, directory, 'Cleaning')

    # Get the directories to process
    toProcess = []
    for srcDir in directory.getWithDefault(target, 'files').split():
        toProcess.extend(glob.glob(srcDir))
    if toProcess == []:
        Ada.logDebug(target, directory, I18n.get('no_file_to_process'))
        return

    if pad == None:
	pad = ''

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target + '.clean'

    # Get option to set in the remote directory
    optionsToSet = []
    newExportDir = directory.getWithDefault(target, 'export_dst')
    if newExportDir != '':
        optionsToSet = ['export dst_dir ' + newExportDir]
    Ada.logInfo(target, directory, 'NEW export.dst_dir = ' + newExportDir)

    # Targets to execute in the remote directory
    givenRemoteTargets = directory.getWithDefault(target, 
                                                  'targets').split()
    remoteTargets = ['.'.join([x, 'clean']) \
                         for x in givenRemoteTargets \
                         if not re.match('(.+\.)?help$', x) and \
                         not re.match('(.+\.)?clean$', x) and \
                         not re.match('(.+\.)?dumphelp$', x) and \
                         not re.match('(.+\.)?helpdump$', x)]

    # If there is a remote target, but it is one of the special, do not perform
    # a recursive clean.
    if givenRemoteTargets != [] and remoteTargets == []:
        Ada.logInfo(target, directory, 'Special target in gotodir. Stop.')
        print I18n.get('no_targets_to_clean').format(target)
        return
        
    Ada.logInfo(target, directory, 
                'Remote Targets = ' + ' '.join(remoteTargets))

    # Loop over each directory
    for dirName in toProcess:

        Ada.logInfo(target, directory, 'RECUR: ' + dirName)

        dirObj = Directory.getDirectoryObject(dirName, optionsToSet)
        dirObj.Execute(remoteTargets, pad + '  ')

    print pad + 'EE', target + '.clean'
    return
    
# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
