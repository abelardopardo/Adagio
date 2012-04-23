#!/usr/bin/env python
# -*- coding: UTF-8 -*-#
#
# Copyright (C) 2010 Carlos III University of Madrid
# This file is part of Adagio: Agile Distributed Authoring Integrated Toolkit

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

import adagio, directory, i18n, dependency, properties, treecache

# Prefix to use for the options
module_prefix = 'gotodir'

# List of tuples (varname, default value, description string)
options = [
    ('export_dst', '', i18n.get('export_dst')),
    ('files_included_from', '', i18n.get('export_rules')),
    ('rules', '', i18n.get('export_rules'))
    ]

documentation = {
    'en' : """
    The execution of the "rules" is invoked in every directory in "files".

    If the value "exports_dst" is given, it overrides the value of
    export.dst_dir in the remote directory.
    """}

def Execute(rule, dirObj, pad = None):
    """
    Execute the rule in the given directory
    """

    if pad == 'None':
        pad = ''

    (toProcess, remoteRules,
     optionsToSet, newExportDir) = prepareRule(rule, dirObj)

    # Loop over each directory
    for dirName in toProcess:
        adagio.logInfo(rule, dirObj, 'RECUR: ' + dirName)
        if not os.path.isdir(dirName):
            print i18n.get('not_a_directory').format(dirName)
            sys.exit(1)
        remoteDir = directory.getDirectoryObject(dirName, optionsToSet)
        remoteDir.Execute(remoteRules, pad + '  ')

    return

def clean(rule, dirObj, deepClean = False, pad = None):
    """
    Clean the files produced by this rule
    """

    global module_prefix

    if pad == None:
        pad = ''

    adagio.logInfo(rule, dirObj, 'Cleaning')

    (toProcess, remoteRules,
     optionsToSet, newExportDir) = prepareRule(rule, dirObj)

    # When cleaning, rules should be executed in reversed order
    remoteRules.reverse()

    if deepClean:
        # If the clean is deep, attach .clean suffix to all remote rules
        remoteRules = [x + '.deepclean'
                         for x in remoteRules
                         if not re.match('(.+\.)?help$', x) and \
                             not re.match('(.+\.)?vars$', x)and \
                             not re.match('(.+\.)?clean$', x)]

        # If no rule is obtained, deep clean, means simply execute the clean
        # rule
        if remoteRules == []:
            remoteRules = ['deepclean']
    else:
        # If the clean is not deep, the execution only propagates to those rules
        # of type export and if the newExportDir is this directory (to clean the
        # current directory only). Otherwise, the rule is simply ignored.
        if newExportDir != dirObj.current_dir:
            return

        remoteRules = [x + '.clean'  for x in remoteRules
                         if x.startswith('export')]

    adagio.logInfo(rule, dirObj,
                'Remote Rules = ' + ' '.join(remoteRules))

    # Loop over each directory
    for dirName in toProcess:

        adagio.logInfo(rule, dirObj, 'RECUR: ' + dirName)
        remoteObj = directory.getDirectoryObject(dirName, optionsToSet)

        # If the clean is not deep and there is no given remote rules, we need
        # to select those that start with 'export'
        if (not deepClean) and (remoteRules == []):
            remoteRules = [x + '.clean' for x in remoteObj.rule_list
                             if re.match('^export(\..+)?$',
                                         properties.expandAlias(x,
                                                                remoteObj.alias))]

        # If remoteRules empty, there is nothing to process in the remote
        # directory.
        if remoteRules == []:
            continue

        # Execute the remote rules
        remoteObj.Execute(remoteRules, pad + '  ')

    return

def prepareRule(rule, dirObj):
    """
    Obtain the directories to process, calculate the options to set in the
    remote execution and obtain the remote rules.

    Return:

    (list of dirs to process, remote rules, options to set in the remote exec)
    """

    # Get the directories to process from the files option
    toProcess = []
    for srcDir in dirObj.getProperty(rule, 'files').split():
        newDirs = glob.glob(srcDir)
        if newDirs == []:
            print i18n.get('file_not_found').format(srcDir)
            sys.exit(1)
        toProcess.extend(glob.glob(srcDir))

    # Add the files included in files_included_from
    filesIncluded = \
        obtainXincludes(dirObj.getProperty(rule, 'files_included_from').split())

    # The list of dirs is extended with a set to avoid duplications
    toProcess.extend(set(map(lambda x: os.path.dirname(x), filesIncluded)))

    # If there are no files to process stop
    if toProcess == []:
        adagio.logDebug(rule, dirObj, i18n.get('no_file_to_process'))
        return (toProcess, [], None, '')

    # Translate all paths to absolute paths
    toProcess = map(lambda x: os.path.abspath(x), toProcess)

    # Rules to execute in the remote directory
    remoteRules = dirObj.getProperty(rule, 'rules').split()

    # Create the option dict for the remote directories
    optionsToSet = []
    newExportDir = dirObj.getProperty(rule, 'export_dst')
    if newExportDir != '':
        # If a new dst_dir has been specified, include the options to modify
        # that variable for each of the rules
        if remoteRules != []:
            # If there are some given rules, use them
            optionsToSet = [x + ' dst_dir ' + newExportDir
                            for x in remoteRules if x.startswith('export')]
        else:
            # If no rule is given, leave the option in the export.dst_dir
            # to its default value default
            optionsToSet = ['export dst_dir ' + newExportDir]

    adagio.logInfo(rule, dirObj, 'NEW Options = ' + ', '.join(optionsToSet))

    return (toProcess, remoteRules, optionsToSet, newExportDir)

def obtainXincludes(files):
    """
    Obtain the files included using xinclude in the given file. Return a list
    with the absolute filenames
    """

    # Remember the old current directory because we are going to modify it
    old_cwd = os.getcwd()

    result = set([])
    for fileName in files:
        # We only accept absolute paths
        if not os.path.isabs(fileName):
            fileName = os.path.abspath(fileName)

        # Get the directory where the file is located and change cwd
        fDir = os.path.dirname(fileName)
	os.chdir(fDir)

        # Get the file parsed without expanding the xincludes
        root = treecache.findOrAddTree(fileName, False)

        # Path to locate the includes and dir of the given file
        includePath = '//{http://www.w3.org/2001/XInclude}include'

        # Obtain the included files
        includeFiles = \
            set([os.path.join(
                    x.attrib.get('{http://www.w3.org/XML/1998/namespace}base',
                                 ''),
                    x.attrib.get('href'))
                 for x in root.findall(includePath)
                 if x.attrib.get('href') != None and \
                     (x.attrib.get('parse') == None or
                      x.attrib.get('parse') == 'xml')])

        # Traverse all the include files
        for includeFile in includeFiles:
            # Locate the file applying Adagio search rules
            # locatedFile = dependency.locateFile(includeFile, [fDir])
            locatedFile = treecache.xml_resolver.resolve_file(includeFile)

            # If not found, notify and terminate
            if locatedFile == None:
                print i18n.get('file_not_found').format(includeFile)
                print i18n.get('included_from'), fileName
                sys.exit(1)

            if os.path.dirname(os.path.abspath(locatedFile)) == fDir:
                # If it is in the same dir, prepare to traverse
                files.append(locatedFile)
            else:
                # If in another dir, append to the result
                result.add(os.path.abspath(locatedFile))

    # restore the original cwd
    os.chdir(old_cwd)

    return result

