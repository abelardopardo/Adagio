#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Copyright (C) 2010 Carlos III University of Madrid
# This file is part of the Adagio: Agile Distributed Authoring Toolkit

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
import os, sys, locale, re, datetime, time
import i18n

__all__ = ['rules']

# Get language and locale for locale option
(lang, enc) = locale.getdefaultlocale()

# Prefix to use for the options
module_prefix = 'adagio'

# Local variable with the dir to use as default
_currentDir = os.path.abspath(os.getcwd())

# Defults values for all the options
config_defaults = {
    'alias':              ('', i18n.get('default_alias')),
    'basedir':            (_currentDir, 
                           i18n.get('default_basedir')),
    'current_datetime':   (str(datetime.datetime.now()), 
                           i18n.get('default_current_datetime')),
    'debug_level':        ('0', i18n.get('default_debug_level')),
    'dst_dir':            (_currentDir, i18n.get('default_dst_dir')),
    'enable_begin':       ('', i18n.get('default_enable_begin')),
    'enable_date_format': ('yyyy/MM/dd HH:mm:ss', 
                           i18n.get('default_enable_date_format')),
    'enable_end':         ('', i18n.get('default_enable_end')),
    'enable_open':        ('1', i18n.get('default_enable_open')),
    'enable_profile':     ('', i18n.get('default_enable_profile')),
    'encoding':           (re.sub('^UTF', 'UTF-', enc), 
                           i18n.get('default_encoding')),
    'file_separator':     (os.path.sep, i18n.get('default_file_separator')),
    'files':              ('', i18n.get('default_files')),
    'help':               (i18n.get('no_help_available'),
                           i18n.get('default_help')),
    'home':               (_currentDir, i18n.get('default_home')),
    'languages':          (lang[0:2], i18n.get('default_languages')),
    'partial':            ('0', i18n.get('default_partial')),
    'project_file':       ('Adagio.project', i18n.get('default_project_file')),
    'project_home':       (_currentDir, i18n.get('default_project_home')),
    'property_file':      ('properties.ddo', i18n.get('default_property_file')),
    'src_dir':            (_currentDir, i18n.get('default_src_dir')),
    'version':            ('11.02.1', i18n.get('default_version'))
}

# List of tuples (varname, default value, description string)
options = [
    # Minimum version number required
    ('minimum_version', '', i18n.get('ada_minimum_version')),
    # Maximum version number required
    ('maximum_version', '', i18n.get('ada_maximum_version')),
    # Exact version required
    ('exact_version', '', i18n.get('ada_exact_version')),
    # Revisions to consider when executing rules
    ('enabled_profiles', '', i18n.get('ada_enabled_profiles'))
     ]

documentation = {
    'en': """
<section id="ada_rule" xreflabel="Top of the Section">
    <title>The <code>[ada]</code> rule</title>
    
    <para>The <code>[ada]</code> rule is an expception because it does not
    perform any specific task. It is simply a place holder for the
    definition of the following variables:</para>
    """ + AdaRule.optionDoc(options) + 
    """
    <para>The variables referring to versions are used to force the execution of
    ADA only if the version number is after the minimun version, before the
    maximum version or a specific version (if any of the variable values is not
    empty.</para>
  
    <para>Variable <code>enabled_profiles</code> is used as a set of values to
    check if a rule must be executed or not (see <xref
    linkend="default_config"/> for a more detailed description of the variables
    that enable the execution of a rule).</para>
    """ + 
    '</section>'}

#
# Directory where Adagio is installed
#
home = os.path.dirname(os.path.abspath(sys.argv[0]))
home = os.path.abspath(os.path.join(home, '..'))
if not os.path.isdir(home):
    print i18n.get('cannot_detect_adagio_home')
    sys.exit(1)
(a, b) = config_defaults['home']
config_defaults['home'] = (home, b)

#
# File object where to dump the log of the execution
#
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

    # Flush all data structures (to simplify debugging)
    dependency.flushData()
    directory.flushCreatedDirs()
    properties.flushConfigParsers()
    treecache.flushData()

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
    userLog.write('Adagio execution started at ' + time.asctime() + '\n')
    userLog.flush()

def finish():
    """
    Function to execute upon main script termination
    """

    global userLog

    userLog.flush()
    userLog.write('Adagio finished at ' + time.asctime() + '\n')
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
            # If any of these options, set it to the path
            v = path
        elif n == 'current_datetime':
            # Set the current date time
            v = str(datetime.datetime.now())
        else:
            # If not any of them, take the default value of the tuple
            v = v[0]

        # Set the dictionary as name: default_value, without the documentation
        # string
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
    threshold = config_defaults['debug_level'][0]
    if directory != None:
        threshold = directory.getProperty(module_prefix, 'debug_level')

    try:
        threshold = int(threshold)
    except ValueError:
        print i18n.get('incorrect_debug_option').format(threshold)
        sys.exit(1)

    if threshold >= int(current):
        output.write(tprefix + ':' + str(msg) + '\n')
        output.flush()

def Execute(target, directory):
    """
    This rule is supposed to do nothing, it only contains auxiliary data
    """
    pass

def clean(target, directory):
    """
    This rule is supposed to do nothing
    """
    pass

def dumpOptions(directory):
    """
    Dump the value of the options affecting the computations
    """

    global options
    global module_prefix

    print i18n.get('var_preamble').format(module_prefix)

    for sn in directory.options.sections():
        if sn.startswith(module_prefix):
            for (on, ov) in sorted(directory.options.items(sn)):
                print ' -', module_prefix + '.' + on, '=', ov
