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
module_prefix = 'convert'

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'inkscape', I18n.get('name_of_executable')),
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

    # Get geometry
    geometries = directory.getWithDefault(target, 'geometry').split()
    if geometries == []:
        print I18n.get('no_var_value').format('geometry')
        print pad + 'EE', target
        return

    # Get the files to process
    srcDir = directory.getWithDefault(target, 'src_dir')
    toProcess = []
    for srcFile in directory.getWithDefault(target, 'files').split():
        toProcess.extend(glob.glob(os.path.join(directory.current_dir, srcFile)))

    # If no files given to process, terminate
    if toProcess == []:
        print I18n.get('no_file_to_process')
        print pad + 'EE', target
        return

    # Loop over all source files to process
    executable = directory.getWithDefault(target, 'exec')
    extraArgs = directory.getWithDefault(target, 'extra_arguments')
    convertCrop = directory.getWithDefault(target, 'crop_option')
    for datafile in toProcess:
        Ada.logDebug(target_prefix, directory, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Loop over formats
        for geometry in geometries:
            # Derive the destination file name
            dstDir = directory.getWithDefault(target, 'dst_dir')
            dstFile = os.path.splitext(os.path.basename(datafile))[0] + \
                '.' + format
WRONG!
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

            Ada.logDebug(target_prefix, directory, 'Popen: ' + ' '.join(command))
            try:
                pass
                # pr = subprocess.Popen(command, stdout = Ada.userLog)
                # pr.wait()
            except:
                print I18n.get('severe_exec_error').format(executable)
                print I18n.get('exec_line').format(' '.join(command))
                sys.exit(1)

            # Update the dependencies of the newly created file
            Dependency.update(dstFile)

    print pad + 'EE', target
    return

def clean(target, directory):
    """
    Clean the files produced by this rule
    """

    print 'BROKEN! Still in Inkscape format, Review'
    sys.exit(1)

    Ada.logInfo(target, directory, 'Cleaning')

    # Remove the .clean suffix
    target_prefix = re.sub('\.clean$', '', target)

    # Get the files to process
    srcDir = directory.getWithDefault(target_prefix, 'src_dir')
    toProcess = []
    for srcFile in directory.getWithDefault(target_prefix, 'files').split():
        toProcess.extend(glob.glob(os.path.join(directory.current_dir,
                                                srcFile)))

    # If no files given to process, terminate
    if toProcess == []:
        print I18n.get('no_file_to_process')
        return

    # Loop over all the source files
    for datafile in toProcess:

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Derive the destination file name
        dstDir = directory.getWithDefault(target_prefix, 'dst_dir')
        dstFile = os.path.splitext(os.path.basename(datafile))[0] + \
            '.' + format
        dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

        if not os.path.exists(dstFile):
            continue

        print I18n.get('removing').format(os.path.basename(dstFile))
        os.remove(dstFile)

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
