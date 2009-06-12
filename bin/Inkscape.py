#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, logging, sys, re, subprocess
import Ada, Directory, AdaRule

# Global variables for the rule
executable = 'inkscape'
debug = 0
src_dir = ''
dst_dir = ''
output_format = 'png'
expanded_files = []

def process(currentDir, command = 'run'):
    """Function that executes a specific rule within the module"""

    global debug
    global src_dir
    global dst_dir
    global output_format
    global expanded_files

    # Initialize vars to default values for this directory
    textValue = currentDir['inkscape.debug.level']
    if textValue != '':
        debug = int(currentDir['ada.debug.level'])

    src_dir = currentDir['inkscape.src.dir']
    if src_dir == '':
        src_dir = currentDir.path

    dst_dir = currentDir['inkscape.src.dir']
    if dst_dir == '':
        dst_dir = currentDir.path

    textValue = currentDir['inkscape.output.format']
    if textValue != '':
        output_format = textValue

    # Special case of dump rule to execute even when inkscape is not enabled
    if command == 'dump':
        dump(currentDir)
        return

    # Expand the given files to see if there is anything to be done
    expanded_files = AdaRule.expandExistingFiles(src_dir, currentDir['inkscape.files'])

    logging.debug('Inkscape: Expanded files ' + str(expanded_files))

    # If the rule is not enabled, finish execution
    if expanded_files == []:
        logging.info('Inkscape: Rule not enabled')
        return

    logging.debug('BG Inkscape(' + command + ') ' + currentDir.path)

    if command == 'run':
        run(currentDir)
    elif command == 'clean':
        clean(currentDir)
    else:
        Ada.infoMessage('Inkscape: Command ' + command + ' not implemented')

    logging.debug('EN Inkscape(' + command + ') ' + currentDir.path)

def run(currentDir):
    global executable
    global dst_dir
    global output_format
    global expanded_files

    # Check first if the executable is available. If not, send warning
    if not AdaRule.isProgramAvailable(executable):
        Ada.infoMessage('WARNING: Inkscape files to process, but no executable found')
        Ada.infoMessage('         Review variable inkscape.files or install inkscape')
        return

    # Create the destination directory
    if (dst_dir != '') and (not os.path.exists(dst_dir)):
        logging.debug('Inkscape: creating directory ' + dst_dir)
        os.mkdir(dst_dir)

    # Loop over all the source filenames
    for fName in expanded_files:
        # Map source filename to dst filename
        dstFile = re.sub('(.*)\.svg', '\\1.' + output_format, fName)

        # If dstFilename exists and is more recent, skip the target
        if os.path.exists(dstFile) and \
                (os.stat(dstFile).st_mtime > os.stat(fName).st_mtime):
            logging.debug('Inkscape: no need to process ' + fName)
            continue

        logging.debug('Inkscape: Processing ' + fName)

        # Execute inkscape
        retcode = subprocess.call([executable, '--export-' + output_format,
                                   dstFile, fName], stdout=open('build.out', 'a'))

        if retcode != 0:
            raise TypeError, 'Error processing ' + srcFile + ' with inkscape'

def clean(currentDir):
    global expanded_files
    global output_format

    filesToDelete = [re.sub('(.*)\.svg', '\\1.' + output_format, fName) \
                         for fName in expanded_files]

    logging.debug('Inkscape cleanin: ' + str(filesToDelete))

#     for name in filesToDelete:
#         os.remove(name)

def dump(currentDir):
    global executable
    global debug
    global src_dir
    global dst_dir
    global output_format

    print 'Inkscape'
    print '  executable = ' + executable
    print '  debug = ' + str(debug)
    print '  src_dir = ' + src_dir
    print '  dst_dir = ' + dst_dir
    print '  output_format = ' + output_format
    print '  files = ' + currentDir['inkscape.files']
    pass

################################################################################

if __name__ == "__main__":
    Ada.initialize()

    # Process the command given as first parameter if any
    command = 'run'
    if (len(sys.argv) >= 2) and (sys.argv[1] != ''):
        command = sys.argv[1]

    process(Directory.Directory(os.getcwd()), command)
