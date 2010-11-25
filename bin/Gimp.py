#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, re, sys, glob, subprocess

import Ada, Directory, I18n, Dependency, AdaRule

# Prefix to use for the options
module_prefix = 'gimp'

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'gimp', I18n.get('name_of_executable')),
    ('script', '%(home)s%(file_separator)sbin%(file_separator)sxcftopng.scm', 
     I18n.get('gimp_script')),
    ('extra_arguments', '', I18n.get('extra_arguments').format('Inkscape'))
    ]

documentation = {
    'en' : """
    All files *.xcf in the current directory are transformed to *.png.

    The script is a program written in Lisp that is passed as GIMP input. There
    is no possibility to choose the source files, all *.xcf are processed, and
    the destination directory is the same as the source directory. The
    transformation will only change the file extension.
    """}

def Execute(target, directory, pad = ''):
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

    # Get the files to process (all *.xcf in the current directory)
    toProcess = glob.glob(os.path.join(directory.current_dir, '*.xcf'))
    if toProcess == []:
        Ada.logDebug(target, directory, I18n.get('no_file_to_process'))
        return

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target

    scriptFileName = directory.getWithDefault(target, 'script')
    if not os.path.isfile(scriptFileName):
        print I18n.get('file_not_found').format(scriptFileName)
        sys.exit(1)
    scriptFile = open(scriptFileName, 'r')

    # Loop over the source files to see if an execution is needed
    dstFiles = []
    for datafile in toProcess:
        Ada.logDebug(target, directory, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstDir = directory.getWithDefault(target, 'src_dir')
        dstFile = os.path.splitext(os.path.basename(datafile))[0] + '.png'
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

        # Check for dependencies!
        Dependency.update(dstFile, set([datafile] + directory.option_files))

        # If the destination file is up to date, skip the execution
        if Dependency.isUpToDate(dstFile):
            print I18n.get('file_uptodate').format(os.path.basename(dstFile))
            continue

        # Remember the files to produce
        dstFiles.append(dstFile)

    # If the execution is needed
    if dstFiles != []:
        executable = directory.getWithDefault(target, 'exec')
        extraArgs = directory.getWithDefault(target, 'extra_arguments')

        # Proceed with the execution
        fnames = ' '.join([os.path.basename(x) for x in dstFiles])
        print I18n.get('producing').format(os.path.basename(fnames))

        command = [executable, '--no-data', '--no-fonts', '--no-interface', 
                   '-b', '-']
        Ada.logDebug(target, directory, 'Popen: ' + ' '.join(command))
        try:
            pr = subprocess.Popen(command, stdin = scriptFile, 
                                  stdout = Ada.userLog)
            pr.wait()
        except:
            print I18n.get('severe_exec_error').format(executable)
            print I18n.get('exec_line').format(' '.join(command))
            sys.exit(1)
        

        # Update the dependencies of the newly created files
        map(lambda x: Dependency.update(x), dstFiles)

    print pad + 'EE', target
    return

def clean(target, directory, pad):
    """
    Clean the files produced by this rule
    """
    
    Ada.logInfo(target, directory, 'Cleaning')

    # Get the files to process
    toProcess = glob.glob(os.path.join(directory.current_dir, '*.xcf'))
    if toProcess == []:
        Ada.logDebug(target, directory, I18n.get('no_file_to_process'))
        return

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target + '.clean'

    # Loop over the source files to see if an execution is needed
    dstFiles = []
    for datafile in toProcess:

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstDir = directory.getWithDefault(target, 'src_dir')
        dstFile = os.path.splitext(os.path.basename(datafile))[0] + '.png'
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

        if not os.path.exists(dstFile):
            continue

        print I18n.get('removing').format(os.path.basename(dstFile))
        os.remove(dstFile)

    print pad + 'EE', target + '.clean'
    return
    
# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
