#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, sys, locale, ordereddict, re, datetime, time

import Directory, I18n, AdaRule

# Get language and locale for locale option
(lang, enc) = locale.getdefaultlocale()

# Prefix to use for the options
module_prefix = 'ada'

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
_currentDir = os.path.abspath(os.getcwd())
config_defaults = {
    'basedir':          _currentDir,
    'current_datetime': str(datetime.datetime.now()),
    'debug_level':      '0',
    'dst_dir':          _currentDir,
    'encoding':         re.sub('^UTF', 'UTF-', enc),
    'file_separator':   os.path.sep,
    'files':            '',
    'home':             _currentDir,
    'locale':           lang[0:2],
    'partial':          '0',
    'profile_revision': '',
    'project_file':     'Ada.project',
    'project_home':     _currentDir,
    'property_file':    'Properties.txt',
    'src_dir':          _currentDir,
    'version':          '10.03.1'
}

# List of tuples (varname, default value, description string)
options = [
    # Minimum version number required
    ('minimum_version', '', I18n.get('ada_minimum_version')),

    # Maximum version number required
    ('maximum_version', '', I18n.get('ada_maximum_version')),

    # Exact version required
    ('exact_version', '', I18n.get('ada_exact_version'))
    ]

documentation = {
    'en': """
     Documentation explaining the basic ada variables. To be written.
     """}

# Directory where ADA is installed
home = os.path.dirname(os.path.abspath(sys.argv[0]))
home = os.path.abspath(os.path.join(home, '..'))
if not os.path.isdir(home):
    print I18n.get('cannot_detect_ada_home')
    sys.exit(1)
config_defaults['home'] = home

userLog = None

def initialize():
    """
    Function that initializes all the required variables before doing anything
    else. This function is executed even before the options are parsed. It
    receives the ConfigParser object storing all the values.

    Returns a boolean stating if there had been problems
    """

    global home
    global userLog

    # Insert the definition of catalogs in the environment
    os.environ["XML_CATALOG_FILES"] = os.path.join(home, 'DTDs',
                                                   'catalog')
    if not (os.path.exists(os.path.join(home, 'DTDs', 'catalog'))):
        logWarn(module_prefix, None, os.path.join(home, 'DTDs', 'catalog') +
                ' does not exist')
        print """*************** WARNING ***************

    Your system does not appear to have the file /etc/xml/catalog properly
    installed. This catalog file is used to find the DTDs and Schemas required
    to process Docbook documents. You either have this definitions inserted
    manually in the file %(home)s/DTDs/catalog.template, or the processing of
    the stylesheets will be extremelly slow (because all the imported style
    sheets are fetched from the net).

    ****************************************"""

    userLog = open('adado.log', 'w')
    userLog.write('Ada execution started at ' + time.asctime() + '\n')
    userLog.flush()

def finish():
    """
    Function to execute upon main script termination
    """

    global userLog

    userLog.flush()
    userLog.write('Ada finished at ' + time.asctime() + '\n')
    userLog.close()

def getConfigDefaults(path):
    """
    Return a dictionary with the default options. It needs to be re-computed
    because some of these options are sensitive to the current directory.
    """
    
    global config_defaults

    result = {}
    for (n, v) in config_defaults.items():
        if n == 'basedir' or n == 'src_dir' or n == 'dst_dir':
            v = path
        elif n == 'current_datetime':
            v = str(datetime.datetime.now())
            
        result[n] = v
            
    return result

def logFatal(tprefix, directory, msg):
    """
    """
    log(tprefix, directory, msg, sys._getframe().f_code.co_name)
    

def logError(tprefix, directory, msg):
    """
    """
    log(tprefix, directory, msg, sys._getframe().f_code.co_name)
    

def logWarn(tprefix, directory, msg):
    """
    """
    log(tprefix, directory, msg, sys._getframe().f_code.co_name)
    

def logInfo(tprefix, directory, msg):
    """
    """
    log(tprefix, directory, msg, sys._getframe().f_code.co_name)
    

def logDebug(tprefix, directory, msg):
    """
    """
    log(tprefix, directory, msg, sys._getframe().f_code.co_name)
    

def log(tprefix, directory, msg, fname = None):
    """
    Function that dumps a message on the userLog file or stdout depending on the
    value of the option debug_value.
    """
    global module_prefix
    global config_defaults
    global userLog

    # Select output the log file and if not present, stdout
    output = userLog
    if output == None:
        output = sys.stdout

    if fname == 'logFatal':
        current = 5
    elif fname == 'logError':
        current = 4
    elif fname == 'logWarn':
        current = 3
    elif fname == 'logInfo':
        current = 2
    elif fname == 'logDebug':
        current = 1
    else:
        current = 0
        
    # Check for debug levels
    threshold = config_defaults['debug_level']
    if directory != None:
        threshold = directory.getWithDefault(module_prefix, 'debug_level')
    
    if int(threshold) >= int(current):
        output.write(tprefix + ':' + msg + '\n')
        output.flush()

def Execute(target, directory, pad = ''):
    """
    Execute the rule in the given directory
    """

    global module_prefix
    global documentation

    logInfo(target, directory, 'Enter ' + directory.current_dir)

    # Detect and execute "special" targets
    if AdaRule.specialTargets(target, directory, documentation, 
                              module_prefix):
        return

    # Print msg when beginning to execute target in dir
    print pad + 'BB', target

    print pad + 'EE', target
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
