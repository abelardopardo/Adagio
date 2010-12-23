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

    if pad == 'None':
        pad = ''

    (toProcess, remoteTargets, 
     optionsToSet, newExportDir) = prepareTarget(target,directory)

    # Loop over each directory
    for dirName in toProcess:
        Ada.logInfo(target, directory, 'RECUR: ' + dirName)
        dirObj = Directory.getDirectoryObject(dirName, optionsToSet)
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

        # If no rule is obtained, clean, means simply execute the export.clean
        # rule (if nothing is defined, no action is taken)
        if remoteTargets == []:
            remoteTargets = ['export.clean']
        
    Ada.logInfo(target, directory, 
                'Remote Targets = ' + ' '.join(remoteTargets))

    # Loop over each directory
    for dirName in toProcess:

        Ada.logInfo(target, directory, 'RECUR: ' + dirName)

        dirObj = Directory.getDirectoryObject(dirName, optionsToSet)
        dirObj.Execute(remoteTargets, pad + '  ')

    return

def prepareTarget(target, directory):
    """
    Obtain the directories to process, calculate the optiost to set in the
    remote execution and obtain the remote targets.
    
    Return:

    (list of dirs to process, remote targets, options to set in the remote exec)
    """

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

    # Targets to execute in the remote directory
    remoteTargets = directory.getWithDefault(target, 'targets').split()

    # Get option to set in the remote directory
    optionsToSet = []
    newExportDir = directory.getWithDefault(target, 'export_dst')
    if newExportDir != '':
        # If a new dst_dir has been specified, include as options the
        # modification of that variable
        optionsToSet = [x + ' dst_dir ' + newExportDir 
                        for x in remoteTargets if x.startswith('export')]

    Ada.logInfo(target, directory, 'NEW Options = ' + ', '.join(optionsToSet))

    return (toProcess, remoteTargets, optionsToSet, newExportDir)

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
