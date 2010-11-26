#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, re, sys, StringIO

# Import conditionally either regular xml support or lxml if present
try:
    from lxml import etree
except ImportError:
    import xml.etree.ElementTree as etree

import Ada, Directory, I18n, Dependency, AdaRule

# Prefix to use for the options
module_prefix = 'xslt'

# List of tuples (varname, default value, description string)
options = [
    ('styles', 
     '%(home)s%(file_separator)sADA_Styles%(file_separator)sDocbookProfile.xsl',
     I18n.get('xslt_style_file')),
    ('output_format', 'html', I18n.get('output_format')),
    ('extra_arguments', '', I18n.get('extra_arguments').format('Xsltproc')),
    ('languages', '%(locale)s', I18n.get('languages'))
    ]

documentation = {
    'en': """
  The rule performs the following tasks:

  1.- For each file in directory 'src_dir' with names 'files' the XSLT
  transformation is applied with the following options:

    1.1 The extra arguments in 'extra_arguments'

    1.2 The style files in styles as if they were all in imported in a
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

    # Prepare the style transformation
    styleFiles = directory.getWithDefault(target, 'styles')
    styleTransform = createStyleTransform(styleFiles.split())
    if styleTransform == None:
        print I18n.get('no_style_file')
        print pad + 'EE', target
        return

    # Create the dictionary of stylesheet parameters
    styleParams = createParameterDict(target, directory)

    doTransformations(styleFiles.split(), styleTransform, styleParams, 
                      toProcess, target, directory)

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

    # Split the languages and remember if the execution is multilingual
    languages = directory.getWithDefault(target, 'languages').split()
    multilingual = len(languages) > 1


    # Loop over all source files to process
    dstDir = directory.getWithDefault(target, 'dst_dir')
    for datafile in toProcess:
        # Loop over languages
        for language in languages:
            # If processing multilingual, create the appropriate suffix
            if multilingual:
                fileSuffix = '_' + language
            else:
                fileSuffix = ''

            # Derive the destination file name
            dstFile = os.path.splitext(os.path.basename(datafile))[0] + \
                fileSuffix + '.' + \
                directory.getWithDefault(target, 'output_format')
            dstFile = os.path.abspath(os.path.join(dstDir, dstFile))
            
            if not os.path.exists(dstFile):
                continue
            
            print I18n.get('removing').format(os.path.basename(dstFile))
            os.remove(dstFile)

    print pad + 'EE', target + '.clean'
    return

def createStyleTransform(styleList):
    """
    Function that given a list of style sheet files, prepares the style file to
    be processed. If more than one file is given, a StringIO is created with all
    of them imported. 
    """

    # Prepare style files (locate styles in ADA/ADA_Styles if needed
    styles = []
    for name in styleList:
        styles.append(AdaRule.locateFile(name))
        if styles[-1] == None:
            print I18n.get('file_not_found').format(name)
            sys.exit(1)

    # If no style is given, terminate
    if styles == []:
        return None

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

    # Parse style file, insert name resolver to consider ADA local styles,
    # expand includes and create transformation object
    styleParser = etree.XMLParser()
    styleParser.resolvers.add(AdaRule.StyleResolver())
    styleTree = etree.parse(styleFile, styleParser)
    styleTree.xinclude()
    styleTransform = etree.XSLT(styleTree)

    return styleTransform

def createParameterDict(target, directory):
    """
    Function that creates the dictionary with all the parameters required to
    apply the stylesheet.
    """

    # Create the dictionary of stylesheet parameters
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
    # Parse the dictionary given in extra_arguments and fold it
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

    return styleParams

def doTransformations(styles, styleTransform, styleParams, toProcess, 
                      target, directory, paramDict = [{}]):
    """
    Function that given a style transformation, a set of style parameters, a
    list of parameter dicitonaries, and a list of files to process, applies the
    transformation to every file, every local dictionary and every language.."""

    # Obtain languages and remember if the execution is multilingual
    languages = directory.getWithDefault(target, 'languages').split()
    multilingual = len(languages) > 1

    # Loop over all source files to process (processing one source file over
    # several languages gives us a huge speedup because the XML tree of the
    # source is built only once for all languages.
    dstDir = directory.getWithDefault(target, 'dst_dir')
    for datafile in toProcess:
        Ada.logDebug(target, directory, ' EXEC ' + datafile)
        
        # If file not found, terminate
        if not os.path.isfile(datafile):
            print I18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Variable holding the data tree to be processed. Used to recycle the
        # same tree through the paramDict and language iteration.
        dataTree = None
        
        # Loop over the param dictionaries
        for pdict in paramDict:
            # fold the values of pdict on styleParams, but in a way that they
            # can be reversed. 
            reverseDict = {}
            for (n, v) in pdict.items():
                reverseDict[n] = styleParams.get(n)

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
                dstFile = os.path.splitext(os.path.basename(datafile))[0] + \
                    fileSuffix + '.' + \
                    directory.getWithDefault(target, 'output_format')
                dstFile = os.path.abspath(os.path.join(dstDir, dstFile))
                
                # Apply style and store the result, get the data tree to recycle
                # it
                dataTree = singleStyleApplication(datafile, styles, 
                                                  styleTransform, styleParams,
                                                  dstFile, target, directory,
                                                  dataTree)
            # End of for language loop

            # Restore the original content of styleParam
            for (n, v) in reverseDict:
                if v == None:
                    # Remove the value from the dictionary
                    styleParams.pop(n)
                else:
                    # Replace the value by the old one
                    styleParams[n] = v

        # End of for param dict loop
    # End of for each file

def singleStyleApplication(datafile, styles, styleTransform, 
                           styleParams, dstFile, target, 
                           directory, dataTree = None):
    """
    Apply a transformation to a file with a dictionary
    """

    # Check for dependencies!
    Dependency.update(dstFile, 
                      set(styles + [datafile] + \
                              directory.option_files))
    
    # If the destination file is up to date, skip the execution
    if Dependency.isUpToDate(dstFile):
        print I18n.get('file_uptodate').format(os.path.basename(dstFile))
        return dataTree

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

    return dataTree

# Execution as script
if __name__ == "__main__":
    Execute(module_prefix, Directory.getDirectoryObject('.'))
