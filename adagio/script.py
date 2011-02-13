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
import os, re, sys, glob, codecs

import directory, i18n, rules

# Prefix to use for the options
module_prefix = 'script'

# List of tuples (varname, default value, description string)
options = [
    ('build_function', 'main', i18n.get('build_function_name')),
    ('clean_function', 'clean', i18n.get('clean_function_name')),
    ('stdin', '', i18n.get('script_input_file')),
    ('stdout', '', i18n.get('script_output_file')),
    ('stderr', '', i18n.get('script_error_file')),
    ('arguments', '', i18n.get('script_arguments'))
    ]

documentation = {
    'en' : """

    Executes "build_function" (or "clean_function" when processing target
    "clean") of the scripts given in "files". The invocation of the script can
    be done redirecting stdin, stdout and/or stderr to the corresponding
    variables (they are assumed to be files) and the script is invoked with the
    given arguments.
    """}

def Execute(target, dirObj):
    """
    Execute the rule in the given directory
    """

    prepareExecution(target, dirObj, 'build_function')

    return
def clean(target, dirObj):
    """
    Clean the files produced by this rule
    """
    
    adagio.logInfo(target, dirObj, 'Cleaning')

    prepareExecution(target, dirObj, 'clean_function')

    return

def prepareExecution(target, dirObj, functionOption):
    """
    Redirect stdin, stdout, stderr + set argv to new values.
    """

    # Get the files to process, if empty, terminate
    toProcess = rules.getFilesToProcess(target, dirObj)
    if toProcess == []:
        return

    # Drop the extensions of the script files
    toProcess = map(lambda x: os.path.splitext(x)[0], toProcess)

    # Get the function to execute
    functionName = dirObj.getProperty(target, functionOption)

    # Modify input/output/error channels
    oldStdin = sys.stdin
    oldStdout = sys.stdout
    oldStderr = sys.stderr
    newStdin = dirObj.getProperty(target, 'stdin')
    newStdout = dirObj.getProperty(target, 'stdout')
    newStderr = dirObj.getProperty(target, 'stderr')
    if newStdin != '':
        if not os.path.exists(newStdin):
            print i18n.get('file_not_found').format(newStdin)
            sys.exit(1)
        sys.stdin = codecs.open(newStdin, 'r')
    if newStdout != '':
        sys.stdout = codecs.open(newStdout, 'w')
    if newStderr != '':
        sys.stderr = codecs.open(newStderr, 'w')
        
    # Execute the 'main' function
    executeFunction(toProcess, target, dirObj, functionName)

    # Restore
    sys.stdin = oldStdin
    sys.stdout = oldStdout
    sys.stderr = oldStderr

    return


def executeFunction(toProcess, target, dirObj, functionName):
    """
    Execute the given function of the module
    """

    # Translate all the options in the directory to a dictionary
    scriptOptions = {}
    for sname in dirObj.options.sections():
        for (on, ov) in dirObj.options.items(sname):
            scriptOptions[sname + '.' + on] = ov
    # Fold now the default values as well
    for (on, ov) in dirObj.options.defaults().items():
        scriptOptions[on] = ov

    # Loop over the given source files
    for datafile in toProcess:
        adagio.logDebug(target, dirObj, ' EXEC ' + datafile)

        (head, tail) = os.path.split(datafile)

        # Add the source directory to the path to fetch python modules
        sys.path.insert(0, head)

        try:
            module = __import__(tail, fromlist=[])
        except ImportError, e:
            print i18n.get('import_error').format(tail)
            print str(e)
            sys.exit(1)

        # If the file of the import is not what is expected, notify and
        # terminate.
        if not module.__file__.startswith(head):
            print i18n.get('import_collision').format(datafile)
            sys.exit(1)

        # Replace argv
        oldArgv = sys.argv
        newArgv = dirObj.getProperty(target, 'arguments')
        if newArgv != '':
            sys.argv = [datafile] + newArgv.split() 

        # If the import has been successfull, go ahead and execute the main
        try:
            getattr(sys.modules[tail], functionName)(scriptOptions)
        except AttributeError, e:
            print i18n.get('function_error').format(functionName)
            print str(e)
            sys.exit(1)

        # Restore tye sys.argv
        sys.argv = oldArgv

        # Restore path the way it was at the beginning of the script
        sys.path.pop(0)

    # End for each datafile 

    return
