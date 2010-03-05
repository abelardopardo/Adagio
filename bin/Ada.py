#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, logging, sys, getopt, datetime, locale

import Directory, I18n, Xsltproc

# Get language and locale for fixed definitions
(lang, enc) = locale.getdefaultlocale()

# Prefix to use for the options
rule_prefix = 'ada'

# Dictionary {varname: (default value (if any), description) }
options = {
    'debug_level': ('info', I18n.get('ada_debug_level_option')),

    'version': ('10.03.1', I18n.get('ada_version_option')),

    'locale': (lang[0:1], I18n.get('ada_locale_option')),

    'home': (os.path.abspath('..'), I18n.get('ada_home_option')),

    'property_file': ('Properties.txt', I18n.get('ada_property_file_option')),

    'file_separator': (os.path.sep, I18n.get('ada_file_separator_option')),

    # Current date/time
    'current_datetime': (str(datetime.datetime.now()),
                         I18n.get('ada_current_datetime')),

    # Profile revision passed to Docbook
    'profile_revision': (None, I18n.get('ada_profile_revision')),

    # Minimum version number required
    'minimum_version': (None, I18n.get('ada_minimum_version')),

    # Maximum version number required
    'maximum_version': (None, I18n.get('ada_maximum_version')),

    # Exact version required
    'exact_version': (None, I18n.get('ada_exact_version')),

    # Debug level
    'debug_level': (0,
                    I18n.get('ada_debug_level')),

    }

Xsltproc.checkCatalogs()

# Function to set a value in the options table
def set(name, value):
    options[name] = value

def main():
    """
    The manual page for this method is inside the localization package. Check
    the proper [ĺang].py file.
    """

    # Fix the output encoding when redirecting stdout
    if sys.stdout.encoding is None:
        (lang, enc) = locale.getdefaultlocale()
        if enc is not None:
            (e, d, sr, sw) = codecs.lookup(enc)
            # sw will encode Unicode data to the locale-specific character set.
            sys.stdout = sw(sys.stdout)

    #######################################################################
    #
    # Initialization of all the required variables
    #
    #######################################################################
    initialize()

    #######################################################################
    #
    # OPTIONS
    #
    #######################################################################
    targets = []
    directories = []
    givenDictionary = None

    # Swallow the options
    try:
        opts, args = getopt.getopt(sys.argv[1:], "d:s:t:",
                                   ["dir="])
    except getopt.GetoptError, e:
        print e.msg
        print I18n.get('__doc__')
        sys.exit(2)

    # Parse the options
    for optstr, value in opts:
        # Debug option
        if optstr == "-d":
            Properties.options['ada.debug_level'] = value

        # Set a value in the environment
        elif optstr == "-s":
            name_value = value.split()
            # If incorrect number of arguments, stop processing
            if len(name_value) != 2:
                print I18n.get('incorrect_arg_num').format('-s option')
                print I18n.get('__doc__')
                sys.exit(2)
            # This option is stored in level B of the dictionary
            if not givenDictionary:
                givenDictionary = {}
            givenDictionary[name_value[0]] = name_value[1]

        # Set the targets
        elif optstr == "-t":
            # Extend the list of targets to process
            targets.extend(value.split())

    # Set the proper debug level
    logging.basicConfig(level=int(Properties.options['ada.debug_level']))

    # Turn targets into a set
    targets = set(targets)

    # Print Reamining arguments. If none, just stick the current dir
    logging.debug('Remaning args: ' + str(args))
    if args == []:
        directories = [os.getcwd()]
    else:
        directories = args

    #######################################################################
    #
    # MAIN PROCESSING
    #
    #######################################################################
    logging.info('ADA targets: ' + ' '.join(targets))

    # Remember the initial directory
    initialDir = os.getcwd()

    # Create the initial list of directories to process
    for currentDir in directories:

        # Move to the actual dir
        logging.info('INFO: Switching to ' + currentDir)
        os.chdir(currentDir)

        # Check if the cache already contains this directory
        (dirObject, doneTargets) = \
                    Directory.Directory.executedDirs.get(currentDir,
                                                        (None, None))

        # If it is the first time the directory is hit, create it
        if dirObject == None:
            dirObject = Directory.Directory(currentDir)
        else:
            logging.debug('HIT. Directory ' + currentDir + ' already processed')

        dirObject.Execute(targets, givenDictionary)

def isCorrectAdaVersion():
    """ Method to check if the curren ada version is within the potentially
    limited values specified in variables ada.minimum.version,
    ada.maximum.version and ada.exact.version"""

    # Get versions to allow execution depending on the version
    minVersion = Properties.options['ada.minimum_version'][0]
    maxVersion = Properties.options['ada.maximum_version'][0]
    exactVersion = Properties.options['ada.exact_version'][0]

    # If no value is given in any variable, avanti
    if (minVersion == None) and (maxVersion == None) and (exactVersion == None):
        return True

    # Translate current version to integer
    currentValue = 0
    vParts = Directory.Directory.fixed_definitions['ada.version'].split('.')
    currentValue = 1000000 * vParts[0] + 10000 * vParts[1] + vParts[2]

    # Translate all three variables to numbers
    minValue = currentValue
    if (minVersion != None):
        vParts = minVersion.split('.')
        minValue = 1000000 * vParts[0] + 10000 * vParts[1] + vParts[2]

    maxValue = currentValue
    if (maxVersion != None):
        vParts = maxVersion.split('.')
        maxValue = 1000000 * vParts[0] + 10000 * vParts[1] + vParts[2]

    exactValue = currentValue
    if (exactVersion != None):
        vParts = exactVersion.split('.')
        exactValue = 1000000 * vParts[0] + 10000 * vParts[1] + vParts[2]

        # Check if an exact version is required
    if (exactValue == currentValue) and (minValue <= currentValue) and \
            (currentValue <= maxValue):
        return True

    return False

def initialize():
    """
    Function that initializes all the required variables before doing anything
    else. This function is executed even before the options are parsed.
    """

    # Nuke the adado.log file
    logFile = os.path.join(os.getcwd(), 'adado.log')
    if os.path.exists(logFile):
        os.remove(logFile)

    # Set the logging format
#     logging.basicConfig(level=logging.INFO,
#                         format='%(levelname)s %(message)s',
#                         filename=logFile,
#                         filemode='w')
    logging.basicConfig(level=logging.INFO,
                        format='%(levelname)s %(message)s')

    logging.debug('Initialization starts')

    # Get the ADA_HOME from the execution environment
    ada_home = os.path.dirname(os.path.abspath(sys.argv[0]))
    ada_home = os.path.abspath(os.path.join(ada_home, '..'))
    if ada_home == '':
        logging.error('ERROR: Unable to set variable ADA_HOME')
        raise TypeError, 'Unable to set variable ADA_HOME'

    if not os.path.isdir(ada_home):
        logging.error('ERROR: ADA_HOME is not a directory')
        raise TypeError, 'ADA_HOME is not a directory'

    logging.debug('ADA_HOME = ' + ada_home)
    Directory.Directory.fixed_definitions['ada.home'] = ada_home

    # Insert the definition of catalogs in the environment
    os.environ["XML_CATALOG_FILES"] = os.path.join(ada_home, 'DTDs',
                                                   'catalog')

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
