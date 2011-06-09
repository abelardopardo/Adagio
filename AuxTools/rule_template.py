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

import adagio, directory, i18n, dependency, rules

# Prefix to use for the options
module_prefix = '@PREFIX@'

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'xsltproc', I18n.get('name_of_executable')),
    ('output_format', 'html', I18n.get('output_format'))
    ]

documentation = {
    'en' : """
    @DESCRIBE HERE WHAT THIS RULE DOES@
    """}

has_executable = rules.which(next(b for (a, b, c) in options if a == 'exec'))

def Execute(rule, directory):
    """
    Execute the rule in the given directory
    """

    global has_executable

    # If the executable is not present, notify and terminate
    if not has_executable:
        print I18n.get('no_executable').format(options['exec'])
        if directory.options.get(rule, 'partial') == '0':
            sys.exit(1)
        return

    # Get the files to process, if empty, terminate
    toProcess = rules.getFilesToProcess(rule, directory)
    if toProcess == []:
        return

    executable = directory.getProperty(rule, 'exec')
    outputFormat = directory.getProperty(rule, 'output_format')
    if not outputFormat in set([]):
        print I18n.get('program_incorrect_format').format(executable, 
                                                          outputFormat)
        sys.exit(1)

    # Prepare the command to execute
    return

def clean(rule, directory):
    """
    Clean the files produced by this rule
    """
    
    adagio.logInfo(rule, directory, 'Cleaning')

    # Get the files to process
    toProcess = rules.getFilesToProcess(rule, directory)
    if toProcess == []:
        return

    print 'Not implemented yet'
    sys.exit(1)

    return

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
