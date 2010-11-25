#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, re, sys, subprocess

import Ada, Directory, I18n, Dependency, AdaRule

# Prefix to use for the options
module_prefix = 'convert'

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'convert', I18n.get('name_of_executable')),
    ('output_format', 'png', I18n.get('output_format')),
    ('geometry', '', I18n.get('convert_geometry')),
    ('output_suffix', '', I18n.get('convert_output_suffix')),
    ('crop_option', '', I18n.get('convert_crop_option')),
    ('extra_arguments', '', I18n.get('extra_arguments').format('Convert'))
    ]

documentation = {
    'en' : """
    Uses the "convert" program scale images. The value of "geometry" is treated
    as a space separated list of geometries of the form hxw. Each file in
    "files" is then scaled for every value in geometry. Furthermore, the value
    in "crop_option" can be used to crop the image. "extra_arguments" are passed
    directly to convert. Convert is thus invoked as:

    convert -scale [geometry] [convert_option] [extra_args] 
            input.xxx output_geometry.xxx

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

    # Get geometry
    geometries = directory.getWithDefault(target, 'geometry').split()
    if geometries == []:
        print I18n.get('no_var_value').format('geometry')
        print pad + 'EE', target
        return

    # Loop over all source files to process
    executable = directory.getWithDefault(target, 'exec')
    extraArgs = directory.getWithDefault(target, 'extra_arguments')
    convertCrop = directory.getWithDefault(target, 'crop_option')
    for datafile in toProcess:
        Ada.logDebug(target, directory, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Loop over formats
        for geometry in geometries:
            # Derive the destination file name
            dstDir = directory.getWithDefault(target, 'dst_dir')
            (fn, ext) = os.path.splitext(os.path.basename(datafile))
            dstFile = fn + '_' + geometry + ext
            dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

            # Check for dependencies!
            Dependency.update(dstFile, set([datafile] + directory.option_files))

            # If the destination file is up to date, skip the execution
            if Dependency.isUpToDate(dstFile):
                print I18n.get('file_uptodate').format(os.path.basename(dstFile))
                continue

            # Proceed with the execution of xslt
            print I18n.get('producing').format(os.path.basename(dstFile))

            command = [executable, '-scale', geometry]
            command.extend(convertCrop.split())
            command.extend(extraArgs.split())
            command.append(datafile)
            command.append(dstFile)

            Ada.logDebug(target, directory, 'Popen: ' + ' '.join(command))
            try:
                pass
                pr = subprocess.Popen(command, stdout = Ada.userLog)
                pr.wait()
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

    # Get geometry
    geometries = directory.getWithDefault(target, 'geometry').split()
    if geometries == []:
        print I18n.get('no_var_value').format('geometry')
        print pad + 'EE', target
        return

    # Loop over all the source files
    for datafile in toProcess:

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Loop over formats
        for geometry in geometries:
            # Derive the destination file name
            dstDir = directory.getWithDefault(target, 'dst_dir')
            (fn, ext) = os.path.splitext(os.path.basename(datafile))
            dstFile = fn + '_' + geometry + ext
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
