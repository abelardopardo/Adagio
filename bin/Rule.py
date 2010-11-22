#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, logging, re, sys

import Ada, Directory, I18n, Dependency, AdaRule

# Prefix to use for the options
module_prefix = '@PREFIX@'

# Set the logger for this module
logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger(module_prefix)

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

    logger.info(module_prefix + ':' + target + ':' + directory.current_dir)

    dirMsg = directory.current_dir[(len(pad) + 2 + len(target)) - 80:]
    print pad + 'BB', target, dirMsg

    # Check if the requested target is "special"
    if AdaRule.processSpecialTargets(target, directory, documentation, 
                                     module_prefix):
        print pad + 'EE', target, dirMsg
        return

    # If requesting clean, remove files and terminate
    if re.match('(.+)?clean', target):
        clean(target, directory)
        print pad + 'EE', target, dirMsg
        return


    print pad + 'EE', target, dirMsg
    return

def clean(target, directory):
    """
    Clean the files produced by this rule
    """
    pass

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
