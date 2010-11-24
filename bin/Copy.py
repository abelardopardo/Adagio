#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, re, sys, glob, shutil

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
        clean(target, directory)
        print pad + 'EE', target
        return

    # Get the files to process
    srcDir = directory.getWithDefault(target, 'src_dir')
    toProcess = []
    for srcFile in directory.getWithDefault(target, 'files').split():
        toProcess.extend(glob.glob(os.path.join(srcDir, srcFile)))

    # If no files given to process, terminate
    if toProcess == []:
        print I18n.get('no_file_to_process')
        print pad + 'EE', target
        return

    # Loop over all source files to process
    for datafile in toProcess:

        Ada.logDebug(target_prefix, directory, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstDir = directory.getWithDefault(target, 'dst_dir')
        dstFile = os.path.abspath(os.path.join(dstDir, 
                                               os.path.basename(datafile)))

        # Check for dependencies!
        Dependency.update(dstFile, set([datafile] + directory.option_files))
        
        # If the destination file is up to date, skip the execution
        if Dependency.isUpToDate(dstFile):
            print I18n.get('file_uptodate').format(os.path.basename(dstFile))
            continue

        # Proceed with the execution of xslt
        print I18n.get('producing').format(os.path.basename(dstFile))

        # Copying the file
        Ada.logDebug(target_prefix, directory, 'Copy ' + datafile + ' ' + 
                     dstFile)
        shutil.copyfile(datafile, dstFile)

        # Update the dependencies of the newly created file
        Dependency.update(dstFile)

    print pad + 'EE', target
    return

def clean(target, directory):
    """
    Clean the files produced by this rule
    """
    
    Ada.logInfo(target, directory, 'Cleaning')

    # Remove the .clean suffix
    target_prefix = re.sub('\.clean$', '', target)

    # Get the files to process
    srcDir = directory.getWithDefault(target_prefix, 'src_dir')
    toProcess = []
    for srcFile in directory.getWithDefault(target_prefix, 'files').split():
        toProcess.extend(glob.glob(os.path.join(srcDir, srcFile)))

    # If no files given to process, terminate
    if toProcess == []:
        print I18n.get('no_file_to_process')
        print pad + 'EE', target
        return

    # Loop over all source files to process
    for datafile in toProcess:

        Ada.logDebug(target_prefix, directory, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstDir = directory.getWithDefault(target_prefix, 'dst_dir')
        dstFile = os.path.abspath(os.path.join(dstDir, 
                                               os.path.basename(datafile)))

        # If file is not there, bypass
        if not os.path.exists(dstFile):
            continue

        # Proceed with the cleaning
        print I18n.get('removing').format(os.path.basename(dstFile))
        os.remove(dstFile)

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
