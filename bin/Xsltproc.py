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
module_prefix = 'xslt'

# Set the logger for this module
logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger(module_prefix)

# List of tuples (varname, default value, description string)
options = [
    ('exec', 'xsltproc', I18n.get('name_of_executable')),
    ('style_files', '%(home)s%(file_separator)sADA_Styles%(file_separator)sDocbookProfile.xsl',
                   I18n.get('xslt_style_file')),
    ('output_format', 'html', I18n.get('output_format')),
    ('extra_arguments', '', I18n.get('xslt_extra_arguments')),
    ('languages', '%(locale)s', I18n.get('xslt_languages'))
    ]

# Old options no longer needed
#     ('merge_styles', '', I18n.get('xslt_merge_styles')),

documentation = {
    'en': """
  The rule performs the following tasks:

  1.- For each file in directory 'src_dir' with names 'files' the 'exec' program
  is invoked given the following options:

    1.1 The extra arguments in 'extra_arguments'

    1.2 The style files in style_files as if they were all in imported in a
    single file in the given order

    1.3 The source file

    1.4 The option to produce the output file in the 'dst_dir' by replacing the
    extension of the source file by the value given in 'output_format'

  2.- Step 1 is repeated with as many languages as given in 'languages'

  Some status messages are printed depending on the 'debug_level'
"""}

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
