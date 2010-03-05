#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, logging, I18n

import Ada, Directory

# Prefix to use for the options
rule_prefix = 'xslt'

# Dictionary {varname: (default value (if any), description) }
options = {
    'exec': ('xsltproc', I18n.get('name_of_executable')),
    'debug_level': ('${ada.debug_level}', I18n.get('rule_debug_level')),
    'src_dir': ('${ada.basedir}', I18n.get('rule_src_dir')),
    'dst_dir': ('${ada.basedir}', I18n.get('rule_dst_dir')),
    'style_file': ('${ada.home}/ADA_Styles/DocbookProfile.xsl',
                   I18n.get('xslt_style_file')),
    'output_format': ('html', I18n.get('output_format')),
    'extra_arguments': (None, I18n.get('xslt_extra_arguments')),
    'files': (None, I18n.get('files_to_process')),
    'merge_styles': (None, I18n.get('xslt_merge_styles')),
    'profile_lang': ('${ada.locale}', I18n.get('xslt_profile_lang')),
    'multilingual': (False, I18n.get('xslt_multilingual'))
    }

def checkCatalogs():
    """
    Check if the catalogs are in place and add the proper net option for xsltproc
    """

    if not (os.path.exists(os.path.join(Ada.options.get('home')[0], 'DTDs',
                                        'catalog'))):
        logging.error('WARNING: ' +
                      os.path.join(ada_home, 'DTDs', 'catalog') +
                      ' does not exist')
        print """*************** WARNING ***************

    Your system does not appear to have the file /etc/xml/catalog properly
    installed. This catalog file is used to find the DTDs and Schemas required
    to process Docbook documents. You either have this definitions inserted
    manually in the file ${ada.home}/DTDs/catalog.template, or the processing of
    the stylesheets will be extremelly slow (because all the imported style
    sheets are fetched from the net).

    ****************************************"""
        options['net_option'] = ('', I18n.get('xslt_net_option'))
    else:
        options['net_option'] = ('--nonet', I18n.get('xslt_net_option'))

def showOptions(directory):
    """
    Show the documentation about the different values in the properties
    """

    for (a, (b, c)) in options.items():
        print '* ' + a + ' (Value: ' + str(directory.get(rule_prefix + '.' + a)) + ')'
        print '  ' + str(c)

def execute():
    """
    Perform the computation with the given symbols
    """
    pass

# Execution as script
if __name__ == "__main__":
    d = Directory.Directory()

    showOptions(d)
