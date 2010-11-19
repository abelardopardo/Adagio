#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, logging, I18n

import Directory

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

documentation = """
    """

def Execute(target, directory):
    """
    Perform the computation with the given symbols
    """
    pass

# Execution as script
if __name__ == "__main__":
    pass
