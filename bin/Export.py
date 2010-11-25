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
module_prefix = 'export'

# List of tuples (varname, default value, description string)
options = [
    ('date_format', 'yyyy/MM/dd HH:mm:ss', I18n.get()),
    ('begin', '', I18n.get()),
    ('end', '', I18n.get()),
    ('open', '', I18n.get()),
    ('profile_revision', '', I18n.get())
    ]

documentation = {
    'en' : """
    This rule copies the "files" in "src_dir" to "dst_dir" if ALL the following
    conditions are satisfied:

    - "begin" is empty or the current time is greater than "begin"
    - "end" is empty or the current time is less than "end"
    - "open" is empty, or "True" (case insensitive)
    - "profile_revision" is empty or contains %(profile_revision)s


    The default values of these variables are:
    - begin : ''
    - end : ''
    - open : ''
    - profile_revision : ''

    So, in principle, if an export section is defined without touching these
    variables, it is performing the export.
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

    # Get the files to process, if empty, terminate
    toProcess = AdaRule.getFilesToProcess(target, directory)
    if toProcess == []:
        return

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target

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

    print 'Not implemented yet'
    sys.exit(1)

    print pad + 'EE', target + '.clean'
    return

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
