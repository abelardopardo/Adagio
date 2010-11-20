#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, logging, re

import Ada, Directory, I18n

# Prefix to use for the options
module_prefix = '@PREFIX@'

# Set the logger for this module
logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger(module_prefix)

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'xsltproc', I18n.get('name_of_executable')),
    ('style_file', '%(home)s%(file_separator)sADA_Styles%(file_separator)sDocbookProfile.xsl',
                   I18n.get('xslt_style_file')),
    ('output_format', 'html', I18n.get('output_format')),
    ('extra_arguments', '', I18n.get('xslt_extra_arguments')),
    ('merge_styles', '', I18n.get('xslt_merge_styles')),
    ('languages', '%(locale)s', I18n.get('xslt_languages'))
    ]

documentation = {
    'en' : """
    @DESCRIBE HERE WHAT THIS RULE DOES@
    """}

def Execute(target, directory):
    """
    Execute the rule in the given directory
    """

    global module_prefix
    global documentation

    logger.info(module_prefix + ':' + target + ':' + directory.current_dir)

    # If requesting var dump, do it and finish
    if re.match('(.+\.)?dump', target):
        dumpOptions(directory)
        return

    # If requesting help, dump msg and terminate
    if re.match('(.+)?help', target):
        msg = documentation[directory.options.get(Ada.module_prefix, 'locale')]
        if msg != None:
            print I18n.get('doc_preamble').format(module_prefix)
            print msg
        else:
            print I18n.get('no_doc_for_rule').format(module_prefix)
        return

    return

def dumpOptions(directory):
    """
    Dump the value of the options affecting the computations
    """

    global options
    global module_prefix

    print I18n.get('var_preamble').format(module_prefix)

    for sn in directory.options.sections():
        if sn.startswith(module_prefix):
            for (on, ov) in sorted(directory.options.items(sn)):
                print ' -', module_prefix + '.' + on, '=', ov

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
