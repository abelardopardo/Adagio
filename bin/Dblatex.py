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
module_prefix = 'dblatex'

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'dblatex', I18n.get('name_of_executable')),
    ('output_format', 'pdf', I18n.get('output_format')),
    ('extra_arguments', '', I18n.get('extra_arguments').format('Dblatex')),
    ('extra_xslt_arguments', '', I18n.get('extra_arguments').format('Xsltproc')),
    ('compliant_mode', '0', I18n.get('').format('Xsltproc'))
    ]

documentation = {
    'en' : """

    Executes dblatex over the given "files" in the "src_dir" and produce the
    result in the "dst_dir". The "output_format" is passed directly as option -t
    to the program. Extra arguments and extra xslt arguments are also passed to
    the program.

    """}

has_executable = AdaRule.which(next(b for (a, b, c) in options if a == 'exec'))

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

    # If the executable is not present, notify and terminate
    if not has_executable:
        print I18n.get('no_executable').format(options['exec'])
        if directory.options.get(target, 'partial') == '0':
            sys.exit(1)
        return

    # Get the files to process, if empty, terminate
    toProcess = AdaRule.getFilesToProcess(target, directory)
    if toProcess == []:
        return

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target

    # Prepare the command to execute
    executable = directory.getWithDefault(target, 'exec')
    dstDir = directory.getWithDefault(target, 'dst_dir')
    outputFormat = directory.getWithDefault(target, 'output_format')
    if directory.getWithDefault(target, 'compliant_mode') == '1':
        compliantOptions = \
            '-P doc.collab.show=0 -P latex.output.revhistory=0'.split()
    else:
        compliantOptions = []
    extraArgs = directory.getWithDefault(target, 'extra_arguments')
    extraXsltArgs = directory.getWithDefault(target, 
                                             'extra_xslt_arguments').split()
    extraXsltArgs = reduce(lambda x, y: x + ['-x', y], extraXsltArgs, [])

    commandPrefix = [executable, '-t', outputFormat]
    commandPrefix.extend(compliantOptions)
    commandPrefix.extend(extraXsltArgs)
    commandPrefix.extend(extraArgs.split())

    # Loop over all source files to process
    for datafile in toProcess:
        Ada.logDebug(target, directory, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstFile = os.path.splitext(os.path.basename(datafile))[0] + \
            '.' + outputFormat
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))
                                                   
        # Check for dependencies!
        Dependency.update(dstFile, set([datafile] + directory.option_files))
            
        # If the destination file is up to date, skip the execution
        if Dependency.isUpToDate(dstFile):
            print I18n.get('file_uptodate').format(os.path.basename(dstFile))
            continue

        # Proceed with the execution of xslt
        print I18n.get('producing').format(os.path.basename(dstFile))

        command = commandPrefix + ['-o', dstFile] + [datafile]
        Ada.logDebug(target, directory, 'Popen: ' + ' '.join(command))
        try:
            pr = subprocess.Popen(command, stdout = Ada.userLog,
                                  stderr = Ada.userLog)
            pr.wait()
            print 'AAA', pr.returncode
        except:
            print I18n.get('severe_exec_error').format(executable)
            print I18n.get('exec_line').format(' '.join(command))
            sys.exit(1)

        # Update the dependencies of the newly created file
        Dependency.update(dstFile)

    print pad + 'EE', target
    return

def clean(target, directory, pad):
    """
    Clean the files produced by this rule
    """
    
    Ada.logInfo(target, directory, 'Cleaning')

    # Get the files to process
    toProcess = AdaRule.getFilesToProcess(target, directory)
    if toProcess == []:
        return

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target + '.clean'

    # Loop over all source files to process
    dstDir = directory.getWithDefault(target, 'dst_dir')
    outputFormat = directory.getWithDefault(target, 'output_format')
    for datafile in toProcess:

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstFile = os.path.splitext(os.path.basename(datafile))[0] + \
            '.' + outputFormat
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
