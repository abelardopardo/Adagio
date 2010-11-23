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
module_prefix = '@PREFIX@'

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'xsltproc', I18n.get('name_of_executable')),
    ('output_format', 'html', I18n.get('output_format')),
    ('languages', '%(locale)s', I18n.get('xslt_languages'))
    ]

documentation = {
    'en' : """
    @DESCRIBE HERE WHAT THIS RULE DOES@
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


    print pad + 'EE', target
    return

def clean(target, directory):
    """
    Clean the files produced by this rule
    """
    
    Ada.logInfo(target, directory, 'Cleaning')

    # Remove the .clean suffix
    target = re.sub('\.clean$', '', target)


# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
