#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, logging, re, sys, StringIO, glob

# Import conditionally either regular xml support or lxml if present
try:
    from lxml import etree
except ImportError:
    import xml.etree.ElementTree as etree

import Ada, Directory, I18n, Dependency, AdaRule

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

def Execute(target, directory, pad = ''):
    """
    Execute the rule in the given directory
    """

    global module_prefix
    global documentation

    logger.info(module_prefix + ':' + target + ':' + directory.current_dir)

    # Print msg when beginning to execute target in dir
    dirMsg = target + directory.current_dir[(len(pad) + 2 + len(target)) - 80:]
    print pad + 'BB', dirMsg

    # Detect and execute "special" targets
    if AdaRule.processSpecialTargets(target, directory, documentation, 
                                     module_prefix):
        print pad + 'EE', dirMsg
        return

    # Get the XML files to process
    srcDir = directory.getWithDefault(target, 'src_dir')
    toProcess = []
    for srcFile in directory.getWithDefault(target, 'files').split():
        toProcess.extend(glob.glob(os.path.join(directory.current_dir, srcFile)))

    # If no files given to process, terminate
    if toProcess == []:
        print I18n.get('no_file_to_process')
        print pad + 'EE', target, dirMsg
        return

    # If requesting clean, remove files and terminate (target not meaninful if
    # there are no files to process
    if re.match('(.+)?clean', target):
        clean(target, directory)
        print pad + 'EE', target, dirMsg
        return

    # Prepare style files (locate styles in ADA/ADA_Styles if needed
    styles = []
    for name in directory.getWithDefault(target, 'style_files').split():
        styles.append(AdaRule.locateFile(name))
        if styles[-1] == None:
            print I18n.get('file_not_found').format(name)
            sys.exit(1)

    # If no style is given, terminate
    if styles == []:
        print I18n.get('no_style_file')
        print pad + 'EE', target, dirMsg
        return

    # If single, leave alone, if multiple, combine in a StringIO using imports
    if len(styles) == 1:
        styleFile = styles[0]
    else:
        result = StringIO.StringIO('''<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xi="http://www.w3.org/2001/XInclude" version="1.0"
  exclude-result-prefixes="xi">
''')
        result.seek(0, os.SEEK_END)
        for sFile in styles:
            result.write('''  <xsl:import href="file://''' + sFile + '''"/>\n''')
        result.write('</xsl:stylesheet>')
        result.seek(0)
        styleFile = result


    # Parse style file, expand includes and create transformation object
    styleParser = etree.XMLParser()
    styleParser.resolvers.add(AdaRule.StyleResolver())
    styleTree = etree.parse(styleFile, styleParser)
    styleTree.xinclude()
    styleTransform = etree.XSLT(styleTree)

    # Create dictionary with some stylesheet parameters
    styleParams = {}
    styleParams['ada.home'] =  "\'" + \
        directory.getWithDefault(Ada.module_prefix, 'home') + "\'"
    styleParams['basedir'] =  "\'" + \
        directory.getWithDefault(Ada.module_prefix, 'basedir') + "\'"
    styleParams['ada.project.home'] =  "\'" + \
        directory.getWithDefault(Ada.module_prefix, 'project_home') + "\'"
    styleParams['ada.current.datetime'] = "\'" + \
        directory.getWithDefault(Ada.module_prefix, 'current_datetime') + "\'"
    profileRevision = directory.getWithDefault(Ada.module_prefix, 
                                            'profile_revision')
    if profileRevision != '':
        styleParams['profile.revision'] = "\'" + profileRevision + "\'" 
    # Parse the given dictionary in extra_arguments and fold it
    try:
        extraDict = eval('{' + directory.getWithDefault(target,
                                                     'extra_arguments') +
                         '}')
        for (k, v) in extraDict.items():
            styleParams[k] = v
    except SyntaxError, e:
        print I18n.get('error_extra_args').format(target)
        print e
        sys.exit(1)

    # Split the languages and remember if the execution is multilingual
    languages = directory.getWithDefault(target, 'languages').split()
    multilingual = len(languages) > 1

    # Loop over all source files to process
    for datafile in toProcess:
        logger.debug(target + ' EXEC ' + datafile)
        
        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Variable holding the data tree to be processed. Used to recycle the
        # same tree through the language iteration.
        dataTree = None

        # Loop over languages
        for language in languages:
            # If processing multilingual, create the appropriate suffix
            if multilingual:
                fileSuffix = '_' + language

                # Insert the appropriate language parameters
                styleParams['profile.lang'] = "\'" + language + "\'"
                styleParams['l10n.gentext.language'] = "\'" + language + "\'"
            else:
                fileSuffix = ''

            # Derive the destination file name
            dstDir = directory.getWithDefault(target, 'dst_dir')
            dstFile = os.path.splitext(os.path.basename(datafile))[0] + \
                fileSuffix + '.' + \
                directory.getWithDefault(target, 'output_format')
            dstFile = os.path.abspath(os.path.join(dstDir, dstFile))
                                                   
            # Check for dependencies!
            Dependency.update(dstFile, 
                              set(styles + [datafile] + directory.option_files))
            
            # If the destination file is up to date, skip the execution
            if Dependency.isUpToDate(dstFile):
                print I18n.get('file_uptodate').format(os.path.basename(dstFile))
                continue

            # Proceed with the execution of xslt
            print I18n.get('producing').format(os.path.basename(dstFile))
            
            # Parse the data file if needed
            if dataTree == None:
                try:
                    dataTree = etree.parse(datafile)
                    dataTree.xinclude()
                except etree.XMLSyntaxError, e:
                    print I18n.get('severe_parse_error').format(datafile)
                    print e
                    sys.exit(0)
            
    
            # Apply the transformation
            try:
                result = styleTransform(dataTree, **styleParams)
            except etree.XSLTApplyError, e:
                print I18n.get('error_applying_xslt').format(target)
                print e
                sys.exit(1)
                

            # Write the result 
            result.write(dstFile, 
                         encoding = directory.getWithDefault(Ada.module_prefix,
                                                          'encoding'),
                         xml_declaration = True,
                         pretty_print = True)

            # Update the dependencies of the newly created file
            Dependency.update(dstFile)

    print pad + 'EE', target, dirMsg
    return

def clean(target, directory):
    """
    Clean the files produced by this rule
    """
    
    global module_prefix

    # Loop over all the required targets
    for target in AdaRule.getCleanTargets(target, directory, module_prefix):
        # Get the XML files to process
        srcDir = directory.getWithDefault(target, 'src_dir')
        toProcess = directory.getWithDefault(target, 'files').split()
        toProcess = map(lambda x: os.path.abspath(os.path.join(srcDir, x)), 
                        toProcess)

        # Split the languages and remember if the execution is multilingual
        languages = directory.getWithDefault(target, 'languages').split()
        multilingual = len(languages) > 1


        # Loop over languages
        for language in languages:
            # If processing multilingual, create the appropriate suffix
            if multilingual:
                fileSuffix = '_' + language
            else:
                fileSuffix = ''

            # Loop over all source files to process
            for datafile in toProcess:
            
                # Derive the destination file name
                dstDir = directory.getWithDefault(target, 'dst_dir')
                dstFile = os.path.splitext(os.path.basename(datafile))[0] + \
                    fileSuffix + '.' + \
                    directory.getWithDefault(target, 'output_format')
                dstFile = os.path.abspath(os.path.join(dstDir, dstFile))
            
                if not os.path.exists(dstFile):
                    continue
            
                print I18n.get('removing').format(os.path.basename(dstFile))
                os.remove(dstFile)
            
# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
