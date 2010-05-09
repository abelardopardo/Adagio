#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, logging, I18n

import Ada, Directory, Properties

# Prefix to use for the options
rule_prefix = 'xslt'

# Set the logger for this module
logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger('ada.' + rule_prefix)

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

    'languages': ('${ada.locale}', I18n.get('xslt_languages')),
    }

documentation = """

    1.- If 'merge_styles' is given, a new style file is created in which the
    files in 'merge_style' are combined with the file in 'style_file'. If no
    value is given in 'merge_styles', no temporal file is created and
    'style_file' is applied directly.

    2.- For each file in directory 'src_dir' with names 'files' the 'exec'
    program is invoked given the following options:

        2.1 The extra arguments in 'extra_arguments'
        2.2 The style file created in step 1
        2.3 The source file

        2.4 The option to produce the output file in the 'dst_dir' by replacing
        the extension of the source file by the value given in 'output_format'

    3.- Step 2 is repeated with as many languages as given in 'languages'

    Some status messages are printed depending on the 'debug_level'
    """

def checkCatalogs():
    """
    Check if the catalogs are in place and add the proper net option for xsltproc
    """
    ada_home = Ada.options.get('home')[0]
    if not (os.path.exists(os.path.join(ada_home, 'DTDs', 'catalog'))):
        logging.warning(os.path.join(ada_home, 'DTDs', 'catalog') +
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

def Execute(target, directory):
    """
    Perform the computation with the given symbols
    """

    logging.info('EXEC ' + target + ' in ' + directory.current_dir)

    # If the target is special, execute and terminate
    if Properties.reservedTargets(target, directory, rule_prefix, options):
        return

    return

# Execution as script
if __name__ == "__main__":
    d = Directory.Directory()

    Properties.reservedTargets(rule_prefix + '._show_options', d, options)
