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

import Ada, Directory, I18n, AdaRule

# Prefix to use for the options
module_prefix = 'script'

# List of tuples (varname, default value, description string)
options = [
    ('build_function', 'main', I18n.get('build_function_name')),
    ('clean_function', 'clean', I18n.get('clean_function_name')),
    ]

documentation = {
    'en' : """

    Executes either the main or clean function of the python scripts given in
    "files". The invocation passes as only parameter a dictionary with all the
    values of all the options.
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

    # Drop the extensions of the script files
    toProcess = map(lambda x: os.path.splitext(x)[0], toProcess)

    if pad == None:
	pad = ''

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target

    # Get the function to execute
    functionName = directory.getWithDefault(target, 'build_function')

    # Execute the 'main' function
    executeFunction(toProcess, target, directory, functionName)

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

    # Drop the extensions of the script files
    toProcess = map(lambda x: os.path.splitext(x)[0], toProcess)

    if pad == None:
	pad = ''

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target + '.clean'

    # Get the function to execute
    functionName = directory.getWithDefault(target, 'clean_function')

    # Execute the 'main' function
    executeFunction(toProcess, target, directory, functionName)

    print pad + 'EE', target + '.clean'
    return

def executeFunction(toProcess, target, directory, functionName):
    """
    Execute the given function of the module
    """

    # Translate all the options in the directory to a dictionary
    scriptOptions = {}
    for sname in directory.options.sections():
        for (on, ov) in directory.options.items(sname):
            scriptOptions[sname + '.' + on] = ov
    # Fold now the default values as well
    for (on, ov) in directory.options.defaults().items():
        scriptOptions[on] = ov

    # Loop over the given source files
    for datafile in toProcess:
        Ada.logDebug(target, directory, ' EXEC ' + datafile)

        (head, tail) = os.path.split(datafile)

        # Add the source directory to the path to fetch python modules
        sys.path.insert(0, head)

        try:
            module = __import__(tail, fromlist=[])
        except ImportError, e:
            print I18n.get('import_error').format(tail)
            print e
            sys.exit(1)

        # If the file of the import is not what is expected, notify and
        # terminate.
        if not module.__file__.startswith(head):
            print I18n.get('import_collision').format(datafile)
            sys.exit(1)

        # If the import has been successfull, go ahead and execute the main
        try:
            getattr(sys.modules[tail], functionName)(scriptOptions)
        except AttributeError, e:
            print I18n.get('function_error').format(functionName)
            print e
            sys.exit(1)

        # Restore path the way it was at the beginning of the script
        sys.path.pop(0)

    # End for each datafile 

    return

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
