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
import os, re, sys

import adagio, directory, i18n, rules

# Prefix to use for the options
module_prefix = 'convert'

documentation = {
    'en' : """
  Uses the "convert" program to scale images. The value of "geometry" is treated
  as a space separated list of geometries of the form heightxwidth. Each file in
  "files" is then scaled for every value in geometry. Furthermore, the value in
  "crop_option" can be used to crop the image. "extra_arguments" are passed
  directly to convert. Convert is thus invoked as:

  convert -scale [geometry] [convert_option] [extra_args]
          input.xxx output_geometry.xxx

    """}

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'convert', i18n.get('name_of_executable')),
    ('geometry', '', i18n.get('convert_geometry')),
    ('crop_option', '', i18n.get('convert_crop_option')),
    ('extra_arguments', '', i18n.get('extra_arguments').format('Convert'))
    ]

has_executable = rules.which(next(b for (a, b, c) in options if a == 'exec'))

def Execute(rule, dirObj):
    """
    Execute the rule in the given directory
    """

    global has_executable

    # If the executable is not present, notify and terminate
    if not has_executable:
        print i18n.get('no_executable').format(options['exec'])
        if dirObj.options.get(rule, 'partial') == '0':
            sys.exit(1)
        return

    # Get the files to process, if empty, terminate
    toProcess = rules.getFilesToProcess(rule, dirObj)
    if toProcess == []:
        adagio.logDebug(rule, dirObj, i18n.get('no_file_to_process'))
        return

    # Get geometry
    geometries = dirObj.getProperty(rule, 'geometry').split()
    if geometries == []:
        print i18n.get('no_var_value').format('geometry')
        return

    # Loop over all source files to process
    executable = dirObj.getProperty(rule, 'exec')
    extraArgs = dirObj.getProperty(rule, 'extra_arguments')
    convertCrop = dirObj.getProperty(rule, 'crop_option')
    dstDir = dirObj.getProperty(rule, 'dst_dir')
    for datafile in toProcess:
        adagio.logDebug(rule, dirObj, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print i18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Loop over formats
        for geometry in geometries:
            # Derive the destination file name
            (fn, ext) = os.path.splitext(os.path.basename(datafile))
            dstFile = fn + '_' + geometry + ext
            dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

            # Creat the command to execute (slightly non-optimal, because the
            # following function might NOT execute the process due to
            # dependencies
            command = [executable, '-scale', geometry]
            command.extend(convertCrop.split())
            command.extend(extraArgs.split())
            command.append(datafile)
            command.append(dstFile)

            # Perform the execution
            rules.doExecution(rule, dirObj, command, datafile, dstFile,
                                adagio.userLog)

    return

def clean(rule, dirObj):
    """
    Clean the files produced by this rule
    """

    adagio.logInfo(rule, dirObj, 'Cleaning')

    # Get the files to process
    toProcess = rules.getFilesToProcess(rule, dirObj)
    if toProcess == []:
        return

    # Get geometry
    geometries = dirObj.getProperty(rule, 'geometry').split()
    if geometries == []:
        print i18n.get('no_var_value').format('geometry')
        return

    # Loop over all the source files
    dstDir = dirObj.getProperty(rule, 'dst_dir')
    for datafile in toProcess:

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print i18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Loop over formats
        for geometry in geometries:
            # Derive the destination file name
            (fn, ext) = os.path.splitext(os.path.basename(datafile))
            dstFile = fn + '_' + geometry + ext
            dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

            if not os.path.exists(dstFile):
                continue

            rules.remove(dstFile)

    return
