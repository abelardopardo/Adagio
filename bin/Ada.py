#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, logging, sys, getopt, datetime, locale, ConfigParser, ordereddict

import Directory, Properties, I18n, Xsltproc

# Get language and locale for locale option
(lang, enc) = locale.getdefaultlocale()

# Prefix to use for the options
module_prefix = 'ada'

# Set the logger for this module
logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger(module_prefix)

################################################################################
#
# ConfigParser:
#
# Global variable in this module with name options
#
# SECTIONS
#
# Ada: variables affecting the overall set of operations.
# Xsltproc: apply xsltproc with options/style/xmlfile
#
################################################################################

config_defaults = {
    'debug_level':      '40',
    'version':          '10.03.1',
    'locale':           lang[0:2],
    'home':             os.path.abspath(os.getcwd()),
    'basedir':          os.path.abspath(os.getcwd()),
    'src_dir':          os.path.abspath(os.getcwd()),
    'dst_dir':          os.path.abspath(os.getcwd()),
    'files':            '',
    'property_file':    'Properties.txt',
    'file_separator':   os.path.sep,
    'current_datetime': str(datetime.datetime.now()),
    'profile_revision': ''
}

options = ConfigParser.SafeConfigParser(config_defaults, 
                                        ordereddict.OrderedDict)

# List of tuples (varname, default value, description string)
local_options = [
    # Minimum version number required
    ('minimum_version', '', I18n.get('ada_minimum_version')),

    # Maximum version number required
    ('maximum_version', '', I18n.get('ada_maximum_version')),

    # Exact version required
    ('exact_version', '', I18n.get('ada_exact_version'))
    ]

def initialize():
    """
    Function that initializes all the required variables before doing anything
    else. This function is executed even before the options are parsed. It
    receives the ConfigParser object storing all the values.

    Returns a boolean stating if there had been problems
    """

    global module_prefix
    global options
    global local_options

    # Nuke the adado.log file
#     logFile = os.path.join(os.getcwd(), 'adado.log')
#     if os.path.exists(logFile):
#         os.remove(logFile)

    # Get the ADA_HOME from the execution environment
    ada_home = os.path.dirname(os.path.abspath(sys.argv[0]))
    ada_home = os.path.abspath(os.path.join(ada_home, '..'))
    if ada_home == '':
        logger.error('ERROR: Unable to set variable ada.home')
        print I18n.get('cannot_detect_ada_home')
        return True

    if not os.path.isdir(ada_home):
        logger.error('ERROR: ada.home is not a directory')
        print I18n.get('cannot_detect_ada_home')
        return True

    # Set ada.home in global options
    logger.debug('ada.home = ' + ada_home)
    options.add_section(module_prefix)
    options.set(module_prefix, 'home', ada_home)

    # Load all options to the ConfigParser element
    Properties.loadOptionsInConfig(options, module_prefix, local_options)
    Properties.loadOptionsInConfig(options, Xsltproc.module_prefix, 
                                   Xsltproc.options)

    Properties.dump(options)

    # See if there is a default script in $HOME/.adarc
    userAdaConfig = os.path.join(os.environ.get('HOME'), '.adarc')
    if os.path.isfile(userAdaConfig):
        logger.debug('Sourcing ' + userAdaConfig)
        # Swallow user file on top of global options, and if trouble, report up
        if Properties.loadConfigFile(options, userAdaConfig):
            return True

    # Insert the definition of catalogs in the environment
    os.environ["XML_CATALOG_FILES"] = os.path.join(ada_home, 'DTDs',
                                                   'catalog')
    # Compare ADA versions to see if execution is allowed
    if not isCorrectAdaVersion():
        logger.error('ERROR: Incorrect Ada Version (' +
                     options.get(module_prefix, 'version') + ')')
        print I18n.get('incorrect_version').format(options.get(module_prefix, 
                                                               'version'))
        return True

    # No problems encountered
    return False

def isCorrectAdaVersion():
    """ Method to check if the curren ada version is within the potentially
    limited values specified in variables ada.minimum_version,
    ada.maximum_version and ada.exact_version"""
    
    global module_prefix
    global options

    # Get versions to allow execution depending on the version
    minVersion = options.get(module_prefix, 'minimum_version')
    maxVersion = options.get(module_prefix, 'maximum_version')
    exactVersion = options.get(module_prefix, 'exact_version')

    # If no value is given in any variable, avanti
    if (minVersion == '') and (maxVersion == '') and (exactVersion == ''):
        return True

    # Translate current version to integer
    currentValue = 0
    vParts = options.get(module_prefix, 'version').split('.')
    currentValue = 1000000 * vParts[0] + 10000 * vParts[1] + vParts[2]

    # Translate all three variables to numbers
    minValue = currentValue
    if (minVersion != ''):
        vParts = minVersion.split('.')
        minValue = 1000000 * vParts[0] + 10000 * vParts[1] + vParts[2]

    maxValue = currentValue
    if (maxVersion != ''):
        vParts = maxVersion.split('.')
        maxValue = 1000000 * vParts[0] + 10000 * vParts[1] + vParts[2]

    exactValue = currentValue
    if (exactVersion != ''):
        vParts = exactVersion.split('.')
        exactValue = 1000000 * vParts[0] + 10000 * vParts[1] + vParts[2]

        # Check if an exact version is required
    if (exactValue == currentValue) and (minValue <= currentValue) and \
            (currentValue <= maxValue):
        return True

    return False

def Execute(target, directory):
    """
    This method is here to comply with the rest of rules, but there are no tasks
    to perform here.
    """

    logger.info('ADA: ' + target + ' in ' + directory.current_dir)

    # If the target is special, execute and terminate
    if Properties.reservedTargets(target, directory, module_prefix, options):
        return

    return
