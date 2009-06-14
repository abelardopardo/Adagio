#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, logging, sys, getopt, datetime
import Directory, Properties, AdaRule

ada_home = ''

def main():
    """
    The script accepts the following options:

      -d num: Debugging level. Used to set the severity level in a
              logging object. Possible values are:

              CRITICAL  	50
              ERROR 	        40
              WARNING 	        30
              INFO 	        20
              DEBUG 	        10
              NOTSET 	         0
    """

    # Basic initialization
    initialize()

    #######################################################################
    #
    # OPTIONS
    #
    #######################################################################
    commands = []
    optionVarNames = [
        'debug']

    try:
        opts, commands = getopt.getopt(sys.argv[1:],
                                       "d:",
                                       [])
    except getopt.GetoptError, e:
        print e.msg
        print AdaProcessor.__doc__
        sys.exit(2)

    # Parse the options
    for optstr, value in opts:
        if optstr == "-d":
            Directory.globalVariables['ada.debug.level'] = value
            logging.basicConfig(level=int(value))


    #######################################################################
    #
    # MAIN PROCESSING
    #
    #######################################################################
    logging.info('Start ADA processing ' + str(commands))

    # Remember the initial directory
    initialDir = os.getcwd()

    # Create the initial list of directories to process
    dirsToProcess = [ (initialDir, '') ]
    executionChain = {}
    index = 0
    while index < len(dirsToProcess):
        # Get the first dir in the list to process
        currentDir, exportDst = dirsToProcess[index]

        # Move to the next element
        index = index + 1;

        logging.info('Processing ' + currentDir + ' ' + exportDst)

        # Move to the actual dir
        logging.info('INFO: Switching to ' + currentDir)
        os.chdir(currentDir)

        if executionChain.has_key(currentDir):
            currentDirInfo = executionChain[currentDir]
            currentDirInfo.appendExportDst(exportDst)
        else:
            # Create the Directory object for the new dir
            currentDirInfo = Directory.Directory(currentDir, exportDst)

            # Store it in the execution Chain
            executionChain[currentDir] = currentDirInfo

            # Obtain the dirs to recur with dst given
            logging.info('INFO: Obtaining recursive dirs')
            recursiveDirs = currentDirInfo.getSubrecursiveDirs()

            # Append dirs to dirsToProcess
            dirsToProcess.extend([ (dirName, currentDir)
                                   for dirName in recursiveDirs
                                   if dirsToProcess.count((dirName, currentDir)) == 0])

            # Obtain dirs to recur with no dst
            recursiveDirsNodst = currentDirInfo.getSubrecursiveDirsNodst();

            # Loop over the non repeated ones to
            # Append dirs to dirsToProcess
            dirsToProcess.extend([(dirName, '') for dirName in recursiveDirsNodst
                                  if dirsToProcess.count((dirName, '')) == 0])

    # Reverse the dirsToProcess to have the right execution order
    dirsToProcess.reverse()

    AdaRule.executeRuleChain(dirsToProcess, executionChain, commands)

def isCorrectAdaVersion():
    """ Method to check if the curren ada version is within the potentially limited
    values specified in variables ada.minimum.version, ada.maximum.version and
    ada.exact.version"""

    minVersion = Directory.globalVariables['ada.minimum.version']
    maxVersion = Directory.globalVariables['ada.maximum.version']
    exactVersion = Directory.globalVariables['ada.exact.version']

    # If no value is given in any variable, avanti
    if (minVersion == '') and (maxVersion == '') and (exactVersion == ''):
        return True

    # Translate current version to integer
    currentValue = 0
    if (currentVersion != ''):
        list = currentVersion.split('.')
        currentValue = 1000000 * list[0] + 10000 * list[1] + list[2]

    # Translate all three variables to numbers
    minValue = currentValue
    if (minVersion != ''):
        list = minVersion.split('.')
        minValue = 1000000 * list[0] + 10000 * list[1] + list[2]

    maxValue = currentValue
    if (maxVersion != ''):
        list = maxVersion.split('.')
        maxValue = 1000000 * list[0] + 10000 * list[1] + list[2]

    exactValue = currentValue
    if (exactVersion != ''):
        list = exactVersion.split('.')
        exactValue = 1000000 * list[0] + 10000 * list[1] + list[2]

        # Check if an exact version is required
    if (exactValue == currentValue) and (minValue <= currentValue) and \
            (currentValue <= maxValue):
        return True

    return False

def initialize():
    #######################################################################
    #
    # Initialization
    #
    #######################################################################

    global ada_home

    # Nuke the adado.log file
    logFile = os.path.join(os.getcwd(), 'adado.log')
    if os.path.exists(logFile):
        os.remove(logFile)

    # Set the logging format
    logging.basicConfig(level=logging.DEBUG,
                        format='%(asctime)s %(levelname)s %(message)s',
#                         datefmt='%y%m%d %H:%M:%S',
                        filename=logFile,
                        filemode='w')

    logging.info('Initialization starts')

    # Get the ADA_HOME from the execution environment
    ada_home = os.path.dirname(os.path.abspath(sys.argv[0]))
    ada_home = os.path.abspath(os.path.join(ada_home, '..'))
    Directory.globalVariables['ada.home'] = ada_home
    if ada_home == '':
        logging.error('ERROR: Unable to set variable ADA_HOME')
        raise TypeError, 'Unable to set variable ADA_HOME'

    if not os.path.isdir(ada_home):
        logging.error('ERROR: ADA_HOME is not a directory')
        raise TypeError, 'ADA_HOME is not a directory'

    logging.debug('ADA_HOME = ' + ada_home)

    Directory.globalVariables.load(\
        open(os.path.join(ada_home, 'bin',
                          'ada_general_definitions.txt')))

    logging.debug('Global Vars: ' + str(Directory.globalVariables))

    # Check if the catalogs are in place
    if not (os.path.exists(os.path.join(ada_home, 'DTDs', 'catalog'))):
        logging.error('WARNING: ' +
                      os.path.join(ada_home, 'DTDs', 'catalog') +
                      ' does not exist')
        print """*************** WARNING ***************
Your system does not appear to have the file /etc/xml/catalog
properly installed. This catalog file is used to find the DTDs
and Schemas required to process Docbook documents. You either
have this definitions inserted manually in the file
${ada.home}/DTDs/catalog.template,
or the processing of the stylesheets will be extremelly slow
(because all the imported style sheets are fetched from the net).

****************************************"""
        Directory.globalVariables['ada.xsltproc.net.option'] = ''
    else:
        Directory.globalVariables['ada.xsltproc.net.option'] = '--nonet'

    # Insert the definition of catalogs in the environment
    os.environ["XML_CATALOG_FILES"] = os.path.join(ada_home, 'DTDs',
                                                   'catalog')

    # Store the current date/time
    Directory.globalVariables['ada.current.datetime'] = \
        str(datetime.datetime.now())

    # Store the profile default
    Directory.globalVariables['ada.profile.revision'] = ''

    # Compare ADA versions to see if execution is allowed
    if not isCorrectAdaVersion():
        logging.error('ERROR: Incorrect Ada Version (' +
                      Directory.globalVariables['ada.current.version'] + ')')
        raise TypeError, 'Incorrect ADA Version (' + \
            Directory.globalVariables['ada.current.version'] + \
            ') Review variables ' + \
            'ada.exact.version, \nada.minimum.version and ada.maximum.version'

def infoMessage(message):
    logging.info(message)
    print message

# Execution as script
if __name__ == "__main__":
    main()
