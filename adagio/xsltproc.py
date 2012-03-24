#!/usr/bin/env python
# -*- coding: UTF-8 -*-#
#
# Copyright (C) 2010 Carlos III University of Madrid
# This file is part of Adagio: Agile Distributed Authoring Integrated Toolkit

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor
# Boston, MA  02110-1301, USA.
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
import os, re, sys, StringIO, urllib
from lxml import etree

import adagio, directory, i18n, dependency, rules, treecache

# Prefix to use for the options
module_prefix = 'xslt'

# List of tuples (varname, default value, description string)
options = [
    ('styles',
     '%(home)s%(file_separator)sAdagio_Styles%(file_separator)sDocbookProfile.xsl',
     i18n.get('xslt_style_file')),
    ('output_format', 'html', i18n.get('output_format')),
    ('language_as', 'suffix', i18n.get('language_as')),
    ('extra_arguments', '', i18n.get('extra_arguments').format('Xsltproc'))
    ]

documentation = {
    'en': """
  This rule creates a style sheet with the files given in the variable "styles"
  (in the same order). This sheet is then applied to all the values in the
  "files" variable. This procedure is repeated as many times as values in the
  "languages" variable. 

  The result of these transformations are left in the directory specified by the
  variable "dst_dir" with the extension given in the variable
  "output_format". If there were more than one language to process, each
  resulting file has a suffix before the extension denoting the language.

  Example:

  [xslt]
  files = first.xml second.xml
  styles = style1.xsl style2.xsl
  languages = en es
  output_format = html

  The variable "extra_arguments" can be used to pass extra arguments at the
  transformation applied to the files. The format of this variable is:

  'name1': 'value1', 'name2': 'value2', ..., 'nameN': 'valueN'

  These definitions are identical to including in the stylesheet the
  definitions:

  <xsl:param name="name1">value1</xsl:param>
  <xsl:param name="name2">value2</xsl:param>
  ...
  <xsl:param name="nameN">valueN</xsl:param>
"""}

def Execute(rule, dirObj):
    """
    Execute the rule in the given directory
    """

    # Get the files to process, if empty, terminate
    toProcess = rules.getFilesToProcess(rule, dirObj)
    if toProcess == []:
        return

    # Prepare the style transformation
    styleFiles = dirObj.getProperty(rule, 'styles').split()
    styleTransform = createStyleTransform(styleFiles)
    if styleTransform == None:
        print i18n.get('no_style_file')
        return

    # Create the dictionary of stylesheet parameters
    styleParams = createParameterDict(rule, dirObj)

    doTransformations(styleFiles, styleTransform, styleParams,
                      toProcess, rule, dirObj)

    return

def clean(rule, dirObj):
    """
    Clean the files produced by this rule
    """

    adagio.logInfo(rule, dirObj, 'Cleaning')

    # Get the files to process
    toProcess = rules.getFilesToProcess(rule, dirObj)
    if toProcess == []:
        return

    doClean(rule, dirObj, toProcess)

    return

def createStyleTransform(styleList, srcDir = None):
    """
    Function that given a list of style sheet files, prepares the style file to
    be processed. If more than one file is given, a StringIO is created with all
    of them imported.
    """

    # Prepare style files (locate styles in HOME/Adagio_Styles if needed
    styles = []
    for name in styleList:
        styles.append(treecache.xml_resolver.resolve_file(name))
        # styles.append(dependency.locateFile(name, [srcDir]))
        if styles[-1] == None:
            print i18n.get('file_not_found').format(name)
            sys.exit(1)

    # If no style is given, terminate
    if styles == []:
        return None

    # If single, leave alone, if multiple, combine in a StringIO using imports
    if len(styles) == 1:
        styleFile = styles[0]
    else:
        result = StringIO.StringIO('''<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xi="http://www.w3.org/2001/XInclude" version="1.0"
  exclude-result-prefixes="xi">
''')
        result.seek(0, os.SEEK_END)
        for sFile in styles:
            result.write('''  <xsl:import href="file:''' + 
                         urllib.pathname2url(sFile) + 
                         '''"/>\n''')
        result.write('</xsl:stylesheet>')
        result.seek(0)
        styleFile = result
        adagio.logDebug('Xsltproc', None, 'Applying ' + styleFile.getvalue())

    # Get the transformation object
    return treecache.findOrAddTransform(styleFile, styles)

def createParameterDict(rule, dirObj):
    """
    Function that creates the dictionary with all the parameters required to
    apply the stylesheet.
    """

    # Create the dictionary of stylesheet parameters
    styleParams = {}
    styleParams['adagio.home'] =  "\'" + \
        dirObj.getProperty(adagio.module_prefix, 'home') + "\'"
    styleParams['basedir'] =  "\'" + \
        dirObj.getProperty(adagio.module_prefix, 'basedir') + "\'"

    # Calculate adagio.project.home as a relative path with respect to the
    # project home
    relProjectHome = os.path.relpath(dirObj.getProperty(adagio.module_prefix,
                                                              'project_home'),
                                     dirObj.current_dir)

    # Attach always the slash at the end to allow the stylesheets to assume it
    # and that way, they work in the case of an empty path.
    relProjectHome = urllib.pathname2url(relProjectHome) + '/'

    # If the project home is the current one, return the empty string
    if relProjectHome == './':
        relProjectHome = ''

    adagio.logDebug('Xsltproc', None, 'adagio.project.home ' + relProjectHome)
    styleParams['adagio.project.home'] =  "\'" + relProjectHome + "\'"

    styleParams['adagio.current.datetime'] = "\'" + \
        dirObj.getProperty(adagio.module_prefix, 'current_datetime') + "\'"
    profileRevision = dirObj.getProperty(adagio.module_prefix,
                                            'enabled_profiles').split()
    if profileRevision != []:
        styleParams['profile.revision'] = "\'" + \
            ';'.join(profileRevision) + "\'"

    # Parse the dictionary given in extra_arguments and fold it
    try:
        extraDict = eval('{' + dirObj.getProperty(rule,
                                                     'extra_arguments') +
                         '}')
        for (k, v) in extraDict.items():
            if hasattr(etree.XSLT, 'strparam'):
                # Valid beyond version 2.2 of lxml
                styleParams[k] = etree.XSLT.strparam(str(v))
            else:
                # If v has quotes, too bad...
                styleParams[k] = '"' + str(v) + '"'
    except SyntaxError, e:
        print i18n.get('error_extra_args').format(rule + '.extra_arguments')
        print str(e)
        sys.exit(1)

    adagio.logInfo(rule, dirObj, 'StyleParmas: ' + str(styleParams))
    return styleParams

def doTransformations(styles, styleTransform, styleParams, toProcess,
                      rule, dirObj, paramDict = None):
    """
    Function that given a style transformation, a set of style parameters, a
    list of pairs (parameter dicitonaries, suffix), and a list of files to
    process, applies the transformation to every file, every local dictionary
    and every language.."""

    if paramDict == None:
	paramDict = [({}, '')]

    # Obtain languages and language prefix/suffix.
    languages = dirObj.getProperty(rule, 'languages').split()
    language_as = dirObj.getProperty(rule, 'language_as').split()

    # If languages is empty, insert an empty string to force one execution
    if languages == []:
        languages = ['']

    # Remember if the execution is multilingual
    multilingual = len(languages) > 1

    # Make sure the given styles are absolute paths
    styles = map(lambda x: os.path.abspath(x), styles)

    # Obtain the file extension to use
    outputFormat = processOuputFormat(rule, dirObj)

    # Loop over all source files to process (processing one source file over
    # several languages gives us a huge speedup because the XML tree of the
    # source is built only once for all languages.
    dstDir = dirObj.getProperty(rule, 'dst_dir')
    for datafile in toProcess:
        adagio.logDebug(rule, dirObj, ' EXEC ' + datafile)

        # If file not found, terminate
        if not os.path.isfile(datafile):
            print i18n.get('file_not_found').format(datafile)
            sys.exit(1)

        # Variable holding the data tree to be processed. Used to recycle the
        # same tree through the paramDict and language iteration.
        dataTree = None

        # Loop over the param dictionaries
        for (pdict, psuffix) in paramDict:
            # fold the values of pdict on styleParams, but in a way that they
            # can be reversed.
            reverseDict = {}
            for (n, v) in pdict.items():
                reverseDict[n] = styleParams.get(n)
                styleParams[n] = v

            # Loop over languages
            for language in languages:
                # If processing multilingual, create the appropriate suffix
                lang_name = ''
                if multilingual:
                    if language_as == 'suffix':
                        lang_name = language + '_'
                    else:
                        lang_name = '_' + language

                # Insert the appropriate language parameters
                styleParams['profile.lang'] = "\'" + language + "\'"
                styleParams['l10n.gentext.language'] = "\'" + language + "\'"

                # Derive the destination file name
                if language_as == 'suffix':
                    dstFile = lang_name + \
                        os.path.splitext(os.path.basename(datafile))[0] + \
                        psuffix + outputFormat
                else:
                    dstFile = os.path.splitext(os.path.basename(datafile))[0] \
                        + lang_name + psuffix + outputFormat

                dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

                # Apply style and store the result, get the data tree to recycle
                # it
                dataTree = singleStyleApplication(datafile, styles,
                                                  styleTransform, styleParams,
                                                  dstFile, rule, dirObj,
                                                  dataTree)
            # End of for language loop

            # Restore the original content of styleParam
            for (n, v) in reverseDict.items():
                if v == None:
                    # Remove the value from the dictionary
                    styleParams.pop(n, None)
                else:
                    # Replace the value by the old one
                    styleParams[n] = v

        # End of for param dict loop
    # End of for each file

def singleStyleApplication(datafile, styles, styleTransform,
                           styleParams, dstFile, rule,
                           dirObj, dataTree = None):
    """
    Apply a transformation to a file with a dictionary
    """

    # Check for dependencies!
    sources = set(styles + [datafile])
    sources.update(dirObj.option_files)
    dependency.update(dstFile, sources)

    # If the destination file is up to date, skip the execution
    if dependency.isUpToDate(dstFile):
        print i18n.get('file_uptodate').format(os.path.basename(dstFile))
        return dataTree

    # Proceed with the execution of xslt
    print i18n.get('producing').format(os.path.basename(dstFile))

    # Parse the data file if needed
    if dataTree == None:
        adagio.logInfo(rule, dirObj, 'Parsing ' + datafile)
        dataTree = treecache.findOrAddTree(datafile, True)

    # Apply the transformation
    xsltprocEquivalent(rule, dirObj, styleParams, datafile, dstFile)
    try:
        result = styleTransform(dataTree, **styleParams)
    except etree.XSLTApplyError, e:
	print
        print i18n.get('error_applying_xslt').format('\n'.join(styles),
                                                     datafile, rule)
	print 'Error:', str(e)
        sys.exit(1)

    # If there is no result (it could be because the stylesheet has no match)
    # notify the user
    if result.getroot() == None:
        print i18n.get('xslt_empty_result')
        return dataTree

    # Write the result
    result.write(dstFile,
                 encoding = dirObj.getProperty(adagio.module_prefix,
                                                  'encoding'),
                 xml_declaration = True,
                 pretty_print = True)

    # Update the dependencies of the newly created file
    try:
        dependency.update(dstFile)
    except etree.XMLSyntaxError, e:
        print i18n.get('severe_parse_error').format(fName)
        print str(e)
        sys.exit(1)

    return dataTree

def doClean(rule, dirObj, toProcess, suffixes = None):
    """
    Function to perform the cleanin step
    """

    if suffixes == None:
	suffixes = ['']

    # Split the languages and remember if the execution is multilingual
    languages = dirObj.getProperty(rule, 'languages').split()
    language_as = dirObj.getProperty(rule, 'language_as').split()

    # If languages is empty, insert an empty string to force one execution
    if languages == []:
        languages = ['']
    multilingual = len(languages) > 1

    # Obtain the file extension to use
    outputFormat = processOuputFormat(rule, dirObj)

    # Loop over all source files to process
    dstDir = dirObj.getProperty(rule, 'dst_dir')
    for datafile in toProcess:

        # Loop over the different suffixes
        for psuffix in suffixes:

            # Loop over languages
            for language in languages:
                # If processing multilingual, create the appropriate suffix
                lang_name = ''
                if multilingual:
                    if language_as == 'suffix':
                        lang_name = '_' + language
                    else:
                        lang_name = language + '_'

                # Derive the destination file name
                if language_as == 'suffix':
                    dstFile = os.path.splitext(os.path.basename(datafile))[0] + \
                        lang_name + psuffix + outputFormat
                else:
                    dstFile = lang_name + \
                        os.path.splitext(os.path.basename(datafile))[0] + \
                        psuffix + outputFormat
                dstFile = os.path.abspath(os.path.join(dstDir, dstFile))

                if not os.path.exists(dstFile):
                    continue

                rules.remove(dstFile)

def xsltprocEquivalent(rule, dirObj, styleParams, datafile, dstFile):
    """
    Dump the xsltproc command line equivalent to the given transformation for
    debugging purposes
    """
    msg = 'xsltproc --xinclude'
    for (a, b) in styleParams.items():
        msg += ' --stringparam ' + '"' + str(a) + '" ' + str(b)

    msg += ' -o ' + dstFile
    msg += ' STYLE.xsl'
    msg += ' ' + datafile

    adagio.logDebug(rule, dirObj, 'XSLTPROC: ' + msg)

def processOuputFormat(rule, dirObj):
    """
    Process output_format option. If it does not include a dot, it is inserted
    as first character. Otherwise, it is left untouched. That way, if the user
    sets the value to 'html', a file with the extension '.html' is created, but
    if the value is '_myversion.xml', the file is generated with a suffix and an
    extension without problems.
    """
    outputFormat = dirObj.getProperty(rule, 'output_format')
    if outputFormat.find('.') == -1:
        outputFormat = '.' + outputFormat
    return outputFormat
