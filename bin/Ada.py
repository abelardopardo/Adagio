#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, logging, sys, getopt, datetime, locale

import Directory, Properties, I18n, Xsltproc

# Get language and locale for locale option
(lang, enc) = locale.getdefaultlocale()

# Prefix to use for the options
rule_prefix = 'ada'

# Set the logger for this module
logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger('ada.' + rule_prefix)

# Dictionary {varname: (default value (if any), description) }
options = {
    'debug_level': ('40', I18n.get('ada_debug_level_option')),

    'version': ('10.03.1', I18n.get('ada_version_option')),

    'locale': (lang[0:2], I18n.get('ada_locale_option')),

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
    }

def isCorrectAdaVersion():
    """ Method to check if the curren ada version is within the potentially
    limited values specified in variables ada.minimum.version,
    ada.maximum.version and ada.exact.version"""

    # Get versions to allow execution depending on the version
    minVersion = options['minimum_version'][0]
    maxVersion = options['maximum_version'][0]
    exactVersion = options['exact_version'][0]

    # If no value is given in any variable, avanti
    if (minVersion == None) and (maxVersion == None) and (exactVersion == None):
        return True

    # Translate current version to integer
    currentValue = 0
    vParts = options['version'][0].split('.')
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
#     logFile = os.path.join(os.getcwd(), 'adado.log')
#     if os.path.exists(logFile):
#         os.remove(logFile)

    # See if there is a default script in $HOME/.adarc
    if os.path.isfile(os.path.join(os.environ.get('HOME'), '.adarc')):
        logger.debug('Sourcing ' + os.path.join(os.environ.get('HOME'), '.adarc'))
        # TO BE IMPLEMENTED

    # Get the ADA_HOME from the execution environment
    ada_home = os.path.dirname(os.path.abspath(sys.argv[0]))
    ada_home = os.path.abspath(os.path.join(ada_home, '..'))
    if ada_home == '':
        logger.error('ERROR: Unable to set variable ADA_HOME')
        raise TypeError, 'Unable to set variable ADA_HOME'

    if not os.path.isdir(ada_home):
        logger.error('ERROR: ADA_HOME is not a directory')
        raise TypeError, 'ADA_HOME is not a directory'

    logger.debug('ADA_HOME = ' + ada_home)
    options['home'] = (ada_home, options['home'][1])

    # Insert the definition of catalogs in the environment
    os.environ["XML_CATALOG_FILES"] = os.path.join(ada_home, 'DTDs',
                                                   'catalog')

    # Compare ADA versions to see if execution is allowed
    if not isCorrectAdaVersion():
        logger.error('ERROR: Incorrect Ada Version (' +
                      Directory.globalVariables['ada.current.version'] + ')')
        raise TypeError, 'Incorrect ADA Version (' + \
            Directory.globalVariables['ada.current.version'] + \
            ') Review variables ' + \
            'ada.exact.version, \nada.minimum.version and ada.maximum.version'

    Xsltproc.checkCatalogs()

def Execute(target, directory):
    """
    This method is here to comply with the rest of rules, but there are no tasks
    to perform here.
    """

    logger.info('ADA: ' + target + ' in ' + directory.current_dir)

    # If the target is special, execute and terminate
    if Properties.reservedTargets(target, directory, rule_prefix, options):
        return

    return
