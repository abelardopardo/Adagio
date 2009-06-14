#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, logging, sys, re, subprocess
import Ada, Directory, AdaRule, Dependency

# Global variables for the rule
executable = 'xsltproc'
debug = 0
src_dir = ''
dst_dir = ''
style_file = os.path.join(Ada.ada_home, 'ADA_Styles', 'DocbookProfile.xsl')
output_format = '.html'
extra_args = ''
expanded_files = []
expanded_multilingual_files = []
mergestyles_style_file = os.path.join(Ada.ada_home, 'ADA_Styles', 'Mergesheets.xsl')
# Space separated list of stylesheets to join
mergestyles_master_style = ''
profile_lang = ''
languages = ['es', 'en']

def process(currentDir, command = 'run'):

    global debug
    global src_dir
    global dst_dir
    global style_file
    global output_format
    global extra_args
    global expanded_files
    global expanded_multilingual_files
    global mergestyles_style_file
    global mergestyles_master_style
    global profile_lang

    # Initialize vars to default values for this directory
    textValue = currentDir['xsltproc.debug.level']
    if textValue != '':
        debug = int(currentDir['ada.debug.level'])

    src_dir = currentDir['xsltproc.src.dir']
    if src_dir == '':
        src_dir = currentDir.path

    dst_dir = currentDir['xsltproc.src.dir']
    if dst_dir == '':
        dst_dir = currentDir.path

    textValue = currentDir['xsltproc.style.file']
    if textValue != '':
        style_file = textValue

    textValue = currentDir['xsltproc.output.format']
    if textValue != '':
        output_format = textValue

    textValue = currentDir['xsltproc.extra.args']
    if textValue != '':
        extra_args = textValue

    textValue = currentDir['xsltproc.mergestyles.style.file']
    if textValue != '':
        mergestyles_style_file = textValue

    textValue = currentDir['mergestyles.master.style']
    if textValue != '':
        mergestyles_master_style = textValue

    textValue = currentDir['xsltproc.profile.lang']
    if textValue != '':
        profile_lang = textValue

    textValue = currentDir['xsltproc.languages']
    if textValue != '':
        profile_lang = textValue.split()

    # Special case of dump rule to execute even when xsltproc is not enabled
    if command == 'dump':
        dump(currentDir)
        return

    # Expand the given files to see if there is anything to be done
    expanded_files = AdaRule.expandExistingFiles(src_dir, currentDir['xsltproc.files'])
    expanded_multilingual_files = \
        AdaRule.expandExistingFiles(src_dir,
                                    currentDir['xsltproc.multilingual.files'])

    logging.debug('Xsltproc: Expanded files ' + str(expanded_files))
    logging.debug('Xsltproc: Expanded mult. files ' + str(expanded_multilingual_files))

    # If the rule is not enabled, finish execution
    if (expanded_files == []) and (expanded_multilingual_files == []):
        logging.info('Xsltproc: Rule not enabled')
        return

    logging.debug('BG Xsltproc(' + command + ') ' + currentDir.path)

    if command == 'run':
        run(currentDir)
    elif command == 'clean':
        clean(currentDir)
    else:
        Ada.infoMessage('Xsltproc: Command ' + command + ' not implemented')

    logging.debug('EN Xsltproc(' + command + ') ' + currentDir.path)

def run(currentDir):
    global executable
    global dst_dir
    global output_format
    global style_sheet
    global mergestyles_master_style
    global expanded_files
    global expanded_multilingual_files

    # Check first if the executable is available. If not, send warning
    if not AdaRule.isProgramAvailable(executable):
        Ada.infoMessage('WARNING: Xsltproc files to process, but no executable found')
        Ada.infoMessage('         Review variable xsltproc.files or install xsltproc')
        raise TypeError

    # Create the destination directory
    if (dst_dir != '') and (not os.path.exists(dst_dir)):
        logging.debug('Xsltproc: creating directory ' + dst_dir)
        os.mkdir(dst_dir)

    # Merge stylesheets if needed
    final_style_sheet = style_file
    if mergestyles_master_style != '':
        final_style_sheet = mergeStyleSheets(style_file,
                                             mergestyles_master_style.split())

    if not os.path.exists(final_style_sheet):
        logging.info('Xsltproc: File ' + final_style_sheet + ' not found')
        raise TypeError, 'File ' + fileName + ' not found'

    logging.debug('Xsltproc: Applying style ' + final_style_sheet)

    # Get the time stamp for the stylesheet
    styleStamp = Dependency.getMtime(final_style_sheet)

    # Loop over all the regular filenames and apply the stylesheet
    for fileName in expanded_files:

        # Make sure both style and source files exist
        if not os.path.exist(fileName):
            logging.info('Xsltproc: File ' + fileName + ' not found')
            raise TypeError, 'File ' + fileName + ' not found'

        # Calculate the output filename
        outputFileName = re.sub('(.*)\.xml', '\\1' + output_format, fileName)

        logging.debug('Xsltproc: Checking dep. for ' + styleStamp +
                      ' ' + fileName + ' ' + outputFileName)

    # Loop over all the multilingual filenames
    for fileName in expanded_multilingual_files:
        pass

def clean(currentDir):
    pass

def dump(currentDir):
    global executable
    global debug
    global src_dir
    global dst_dir
    global style_file
    global output_format
    global extra_args
    global mergestyles_style_file
    global mergestyles_master_style
    global profile_lang

    print 'Xsltproc'
    print '  executable = ' + executable
    print '  debug = ' + str(debug)
    print '  src_dir = ' + src_dir
    print '  dst_dir = ' + dst_dir
    print '  style_file = ' + style_file
    print '  output_format = ' + output_format
    print '  extra_args = ' + extra_args
    print '  mergestyles_style_file = ' + mergestyles_style_file
    print '  mergestyles_master_style = ' + mergestyles_master_style
    print '  profile_lang = ' + profile.lang
    print '  files = ' + currentDir['xsltproc.files']
    print '  multilingual_files = ' + currentDir['xsltproc.multilingual.files']

def mergeStyleSheets(mainFile, filesToMerge):
    logging.debug('Xsltproc: Merging ' + mainFile + ' with ' + str(filesToMerge))

    # Calculate the resulting style file (absolute path + filename + suffix)
    newName = re.sub('(.*)\.x.l', '\\1_ADA_MERGED_STYLE.xsl',
                     os.path.split(mainFile)[1])
    newName = os.path.abspath(newName)

    # Pass the main File by the catalog filter
    absMainFile = AdaRule.locateSheet(mainFile)

    # Pass the rest of files by the same filter
    filesToMerge = map(AdaRule.locateSheet, filesToMerge)

    # If the style file does not exist, or Properties.txt was modified, refresh
    if (not os.path.exists(newName)) or \
            (os.stat(newName).st_mtime < os.stat('Properties.txt').st_mtime):
        merged = open(newName, 'w')
        merged.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        merged.write('<xsl:stylesheet ')
        merged.write('xmlns:xsl="http://www.w3.org/1999/XSL/Transform"\n')
        merged.write('  xmlns="http://www.w3.org/1999/xhtml"\n')
        merged.write('  xmlns:xi="http://www.w3.org/2001/XInclude" version="1.0"\n')
        merged.write('  exclude-result-prefixes="xi">\n')

        # Import the main file first
        merged.write('  <xsl:import href="' + absMainFile + '"/>\n')

        # Loop over the given filenames
        for sName in filesToMerge:
            merged.write('  <xsl:import href="' + sName + '"/>\n')

        merged.write('</xsl:stylesheet>\n')
        merged.close()

        # Update the mtime in the dependency graph
        Dependency.updateMtime(newName, os.stat(newName).st_mtime)

    return newName

################################################################################

if __name__ == "__main__":
    Ada.initialize()

    # Process the command given as first parameter if any
    command = 'run'
    if (len(sys.argv) >= 2) and (sys.argv[1] != ''):
        command = sys.argv[1]

    process(Directory.Directory(os.getcwd()), command)
