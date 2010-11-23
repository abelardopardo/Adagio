#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
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

def Execute(target, directory, pad = ''):
    """
    Execute the rule in the given directory
    """

    global module_prefix
    global documentation

    # If it is a generic target, add the prefix
    target_prefix = target.split('.')[0]
    if target_prefix != module_prefix:
        target = module_prefix + '.' + target
        target_prefix = module_prefix

    Ada.logInfo(target_prefix, directory, 'Enter ' + directory.current_dir)

    # Detect and execute "special" targets
    if AdaRule.processSpecialTargets(target, directory, documentation, 
                                     module_prefix):
        return

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target

    # If requesting clean, remove files and terminate
    if re.match('(.+)?clean', target):
        clean(target, directory, pad)
        print pad + 'EE', target
        return

    # Get the directories to process
    toProcess = []
    for srcDir in directory.getWithDefault(target, 'files').split():
        toProcess.extend(glob.glob(srcDir))

    # If no files given to process, terminate
    if toProcess == []:
        print I18n.get('no_dir_to_process')
        print pad + 'EE', target
        return

    # Get option to set in the remote directory
    optionsToSet = []
    newExportDir = directory.getWithDefault(target, 'export_dst')
    if newExportDir != '':
        optionsToSet = ['export dst_dir ' + newExportDir]
    Ada.logInfo(target_prefix, directory, 'NEW export.dst_dir = ' + newExportDir)

    # Targets to execute in the remote directory
    remoteTargets = directory.getWithDefault(target, 'targets').split()

    # Loop over each directory
    for dirName in toProcess:

        Ada.logInfo(target_prefix, directory, 'RECUR: ' + dirName)

        dirObj = Directory.getDirectoryObject(dirName, optionsToSet)
        dirObj.Execute(remoteTargets, pad + '  ')

    print pad + 'EE', target
    return

def clean(target, directory, pad):
    """
    Clean the files produced by this rule
    """
    
    global module_prefix

    Ada.logInfo(target, directory, 'Cleaning')

    # Remove the .clean suffix
    target_prefix = re.sub('\.clean$', '', target)

    # Get the directories to process
    toProcess = []
    for srcDir in directory.getWithDefault(target_prefix, 'files').split():
        toProcess.extend(glob.glob(srcDir))

    # If no files given to process, terminate
    if toProcess == []:
        print I18n.get('no_dir_to_process')
        print pad + 'EE', target
        return

    # Get option to set in the remote directory
    optionsToSet = []
    newExportDir = directory.getWithDefault(target_prefix, 'export_dst')
    if newExportDir != '':
        optionsToSet = ['export dst_dir ' + newExportDir]
    Ada.logInfo(target_prefix, directory, 'NEW export.dst_dir = ' + newExportDir)

    # Targets to execute in the remote directory
    givenRemoteTargets = directory.getWithDefault(target_prefix, 
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
        print I18n.get('no_targets_to_clean').format(target_prefix)
        return
        
    Ada.logInfo(target_prefix, directory, 
                'Remote Targets = ' + ' '.join(remoteTargets))

    # Loop over each directory
    for dirName in toProcess:

        Ada.logInfo(target_prefix, directory, 'RECUR: ' + dirName)

        dirObj = Directory.getDirectoryObject(dirName, optionsToSet)
        dirObj.Execute(remoteTargets, pad + '  ')

    
# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
