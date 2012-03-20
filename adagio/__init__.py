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
import os, sys, locale, re, datetime, time, ConfigParser
import directory, i18n, rules, dependency, properties, treecache

# @@@@@@@@@@@@@@@@@@@@  EXTEND  @@@@@@@@@@@@@@@@@@@@
import xsltproc, inkscape, gotodir, gimp, convert, filecopy
import export, dblatex, exercise, exam, testexam, office2pdf, rsync
import script, latex, dvips, pdfnup, xfig

modules = ['xsltproc', 'inkscape', 'gotodir', 'gimp', 'convert',
           'filecopy', 'export', 'dblatex', 'exercise', 'exam', 'testexam',
           'office2pdf', 'rsync', 'script', 'latex', 'dvips', 'pdfnup', 'xfig']
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

__all__ = ['rules', 'i18n']

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
    'encoding':           (enc, i18n.get('default_encoding')),
    'file_separator':     (os.path.sep, i18n.get('default_file_separator')),
    'files':              ('', i18n.get('default_files')),
    'help':               (i18n.get('no_help_available'),
                           i18n.get('default_help')),
    'home':               (_currentDir, i18n.get('default_home')),
    'languages':          (lang[0:2], i18n.get('default_languages')),
    'partial':            ('0', i18n.get('default_partial')),
    'project_file':       ('Adagio.project', i18n.get('default_project_file')),
    'project_home':       (_currentDir, i18n.get('default_project_home')),
    'property_file':      ('Properties.dgo', i18n.get('default_property_file')),
    'relative_basedir':   ('.',
                           i18n.get('default_relative_basedir')),
    'src_dir':            (_currentDir, i18n.get('default_src_dir')),
    'version':            ('12.03.1', i18n.get('default_version')),
    'xml_paths':          ('', i18n.get('default_xml_paths'))
}

# List of tuples (varname, default value, description string)
options = [
    # Minimum version number required
    ('minimum_version', '', i18n.get('adagio_minimum_version')),
    # Maximum version number required
    ('maximum_version', '', i18n.get('adagio_maximum_version')),
    # Exact version required
    ('exact_version', '', i18n.get('adagio_exact_version')),
    # Revisions to consider when executing rules
    ('enabled_profiles', '', i18n.get('adagio_enabled_profiles'))
     ]

documentation = {
    'en': """

    adagio [options] [rule rule ....]

    Adagio is a rule-based program (similar to "make") that given a file
    containing a set of rules, it automatically executes them. Given a directory
    and a set of rules, a new set of files are created by applying the rules
    automatically.

    The rules are all included in a file with name {0}. The file is written in
    INI format. A rule is defined with a name in brackets at the begining of a
    line. Each rule has a set of name = value assignments. For example:

    [inkscape]
    files = *.svg

    These two lines invoke the "inkscape" rule that processes all files given in
    its "files" variable and transforms them into PNG images.

    When executing, Adagio reads the rule file in the current directory and
    process the rules included in it. If no rules are given when invoking the
    program, all of the rules in the file are executed in the order they appear.

    OPTIONS
    
    Adagio accepts the following command line options:

      -c filename: Specify the file containing the rules (default {0})

      -d num: Debugging level to control the amount of messages
       printed. Possible values are:

              CRITICAL/FATAL = 5
              ERROR =          4
              WARNING =        3
              INFO =           2
              DEBUG =          1
              NOTSET =         0

      -f path_to_rule_file: Execute Adagio with the rules in the given file and
       in the directory where that file is.

      -h: Shows this message

      -p: Partial execution. Proceed with the rules even if some tools are not
          installed. Otherwise Adagio stops execution upon finding the first
          missing tool.

      -s 'rule name value': Executes the rules but first stores in the
                       environment the assignment name = value as part of the
                       given rule. This means that, unless overwritten by
                       definitions in the properties file, this assignment will
                       be visible to all the rules.

      -x: Shows this message

    RULES

    Adagio contains support for several rules. For each of them a more detailed
    description can be obtained by executing the adagio with the rule
    "rulename.help", where rulename is any of the following:

      * convert: Use the ImageMagik library to perform operations over images
        such as format conversion, resize or crop (needs ImageMagik installed)

      * dblatex: Executes dblatex over a set of Docbook files to translate them
        to LaTeX (needs dblatex and LaTeX installed)

      * dvips: Executes dvips over a set of given DVI files to translate them to
        Postscript (needs dvips installed)

      * exam: Typeset a Docbook file with a specific format into an exam (needs
        Docbook and Docbook XSLT installed)

      * exercise: Typeset a Docbook file and produce a hand out for students and
        (optionally) a solution document, professor guide, and submission form
        (needs Docbook and Docbook XSLT installed)

      * export: Copy a set of files from a source directory to a (possibly given
        from other execution) destination directory. The copy is executed if a
        set of conditions are fullfilled.

      * filecopy: Copy files from a source directory.

      * gimp: Transform all files in a directory in *.xcf format to PNG
        (needs Gimp installed)

      * gotodir: Invoke the execution of Adagio in a different directory
        (recursively).

      * inkscape: Transforms SVG files created by Inkscape into PNG, EPS, PS or
        PDF (needs Inkscape installed)

      * latex: Execute LaTeX over a set of give *.tex files (needs LaTeX
        installed)

      * office2pdf: Produce a PDF file from a given set of Office Word or
        PowerPoint files (needs LibreOffice installed).

      * pdfnup: Execute pdfnup over a set of PDF files to create n-up handouts
        (needs pdfnup installed)

      * rsync: Executes rsync to synchronize a source and a destination dir
        (needs rsync installed)

      * script: Executes an extra rule given as a Python script.

      * testexam: Typesets a Docbook document in a special format containing a
        set of multiple choice tests into an HTML document. The rule shuffles
        the questions and creates several versions (needs Docbook and Docbook
        XSLT installed)

      * xfig: Transform figures created with xfig into PNG format (needs xfig
        installed)

      * xslt: Applies a XSL style sheet to a given XML file.

    If you execute adagio with a single parameter made of a rule name followed
    by the suffix ".help" it provides a more detailed description of the
    operations contained in the rule. For example:

    adagio inkscape.help

    will print more detailed information about the "inkscape" rule.

    Analogously, if the suffix ".vars" is used, all the variables, their
    assigned values and a brief explanation is printed.

    """}

# Dictionary storing pairs (variable name, variable help message)
variable_help_messages = {}

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
# File object where to write the execution log
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
    treecache.setResolver()

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

    userLog = open('adagio.log', 'w')
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
    global variable_help_messages

    result = {}
    for (n, v) in config_defaults.items():

        # Add the help message to the variable_help_messages dir
        variable_help_messages[n] = v[1]

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

def logFatal(tprefix, dirObj, msg):
    """
    """
    log(tprefix, dirObj, msg, sys._getframe().f_code.co_name)


def logError(tprefix, dirObj, msg):
    """
    """
    log(tprefix, dirObj, msg, sys._getframe().f_code.co_name)


def logWarn(tprefix, dirObj, msg):
    """
    """
    log(tprefix, dirObj, msg, sys._getframe().f_code.co_name)


def logInfo(tprefix, dirObj, msg):
    """
    """
    log(tprefix, dirObj, msg, sys._getframe().f_code.co_name)


def logDebug(tprefix, dirObj, msg):
    """
    """
    log(tprefix, dirObj, msg, sys._getframe().f_code.co_name)


def log(tprefix, dirObj, msg, fname = None):
    """
    Function that writes a message on the userLog file or stdout depending on
    the value of the option debug_value.
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
    if dirObj != None:
        threshold = dirObj.getProperty(module_prefix, 'debug_level')

    try:
        threshold = int(threshold)
    except ValueError:
        print i18n.get('incorrect_debug_option').format(threshold)
        sys.exit(1)

    if threshold >= int(current):
        output.write(tprefix + ':' + str(msg) + '\n')
        output.flush()

def Execute(rule, dirObj):
    """
    This rule is supposed to do nothing, it only contains auxiliary data
    """
    pass

def clean(rule, dirObj):
    """
    This rule is supposed to do nothing
    """
    pass

def LoadDefaults(config):
    """
    Loads all the default options for all the rules in the given ConfigParser.
    """
    global modules
    global config_defaults
    global module_prefix
    global options
    global documentation

    # Load the package generic default options
    AppendOptions(config, module_prefix, options, documentation)

    # Traverse the modules and load the values in the "option" variable
    for moduleName in modules:

        # Get the three required values from the module
        sectionName = eval(moduleName + '.module_prefix')
        mOptions = eval(moduleName + '.options')
        documentation = eval(moduleName + '.documentation')

        # If any of these variables is None, bomb out.
        if sectionName == None or mOptions == None or documentation == None:
            raise TypeError, 'Incorrect type in LoadDefaults'

        # Add the optios to the config object
        AppendOptions(config, sectionName, mOptions, documentation)

    return

def AppendOptions(config, sectionName, options, documentation):
    """
    Function that incorporates to the given config a set of options as part of
    the given section. The documentation string is added taking into account the
    current languages.
    """
    
    global variable_help_messages
    # If the section is already present in the config, never mind
    try:
        config.add_section(sectionName)
    except ConfigParser.DuplicateSectionError:
        pass

    # Loop over all the default values and add them to the proper sections
    for (vn, vv, msg) in options:
        properties.setProperty(config, sectionName, vn, vv,
                               createRule = True, createOption = True)
        
        variable_help_messages[sectionName + '.' + vn] = msg
        
    # Add the string for the help
    helpStr = documentation.get(config_defaults['languages'][0].split()[0])
    if helpStr == None:
        helpStr = documentation.get('en')
    properties.setProperty(config, sectionName, 'help', helpStr,
                           createRule = True, createOption = True)
    return

def Execute(rule, dirObj, pad = None):
    """
    Given a rule and a directory, it checks which rule needs to be invoked and
   performs the invokation.
    """

    global modules

    # Keep a copy of the rule before applying aliases
    originalRule = rule

    # Apply the alias expansion
    try:
        rule = properties.expandAlias(rule, dirObj.alias)
    except SyntaxError:
        print i18n.get('error_alias_expression')
        sys.exit(1)

    # Detect help, vars or clean rule
    specialRule = re.match('.+\.help$', rule) or \
        re.match('.+\.vars$', rule) or \
        re.match('.+\.clean$', rule) or \
        re.match('.+\.deepclean$', rule)

    # Make sure the rule is legal.
    if not specialRule and not dirObj.options.has_section(rule):
        print i18n.get('illegal_rule_name').format(t = originalRule,
                                                     dl = dirObj.current_dir)
        sys.exit(2)

    # Get the module prefix (everything up to the first dot) and the rule prefix
    # (dropping any special rule suffix)
    ruleParts = rule.split('.')
    modulePrefix = ruleParts[0]
    if specialRule:
        rulePrefix = '.'.join(ruleParts[:-1])
    else:
        rulePrefix = rule

    if pad == None:
	pad = ''

    # Traverse the modules and execute the "Execute" function
    executed = False
    for moduleName in modules:

        # If the rule does not belong to this module, keep iterating
        if modulePrefix != eval(moduleName + '.module_prefix'):
            continue

        logInfo(originalRule, dirObj, 'Enter ' + dirObj.current_dir)

        # Print msg when beginning to execute a rule in dir
        print pad + 'BB', originalRule

        # Detect and execute "help" rule
        if helpRule(rule, dirObj, moduleName, pad):
            print pad + 'EE', originalRule
            logInfo(originalRule, dirObj, 'Exit ' + dirObj.current_dir)
            return

        # Detect and execute "vars" rule
        if varsRule(rule, dirObj, moduleName, pad):
            print pad + 'EE', originalRule
            logInfo(originalRule, dirObj, 'Exit ' + dirObj.current_dir)
            return

        # Check the condition
        if not rules.evaluateCondition(rulePrefix, dirObj.options):
            return

        # Detect and execute "clean" rules
        if cleanRules(rule, dirObj, moduleName, pad):
            print pad + 'EE', originalRule
            logInfo(originalRule, dirObj, 'Exit ' + dirObj.current_dir)
            return

        # Execute.
        if moduleName == 'gotodir':
            # gotodir must take into account padding
            eval(moduleName + '.Execute(rule, dirObj, pad)')
        else:
            eval(moduleName + '.Execute(rule, dirObj)')

        # Detect if no module executed the rule
        executed = True

        print pad + 'EE', originalRule

        logInfo(originalRule, dirObj, 'Exit ' + dirObj.current_dir)

        # Once the rule executed, no need to keep checking for the rest of modules
        break

    # Special case of targets of the "default" module.
    if modulePrefix == 'adagio':
        print pad + 'BB', originalRule

        # Detect and execute "help" rule
        if helpRule(rule, dirObj, 'adagio', pad):
            print pad + 'EE', originalRule
            logInfo(originalRule, dirObj, 'Exit ' + dirObj.current_dir)
            return

        # Detect and execute "vars" rule
        if varsRule(rule, dirObj, 'adagio', pad):
            print pad + 'EE', originalRule
            logInfo(originalRule, dirObj, 'Exit ' + dirObj.current_dir)
            return

    if not executed:
        print i18n.get('unknown_rule').format(originalRule)
        sys.exit(1)

def cleanRules(rule, dirObj, moduleName, pad = None):
    """
    Execute the clean rules. Return True if a rule has been executed
    """

    # CLEAN
    if re.match('.+\.clean$', rule):
        eval(moduleName + '.clean(\'' + re.sub('\.clean$', '', rule)
             + '\', dirObj)')
        return True

    # DEEPCLEAN
    if re.match('.+\.deepclean$', rule):
        if rule.startswith('gotodir'):
            # gotodir propagates the pad for the deep
            eval(moduleName + '.clean(\'' + re.sub('\.deepclean$', '', rule)
                 + '\', dirObj, True, pad)')
        else:
            eval(moduleName + '.clean(\'' + re.sub('\.deepclean$', '', rule)
                 + '\', dirObj)')
        return True

    return False

def findExecutable(rule, dirObj):
    """
    Function to search if an executable is available in the machine. Lifted from
    StackOverflow and modified to account for possible executable suffixes
    stored in Windows in the environment variable PATHEXT.
    """

    # Get the program name
    program = properties.getProperty(dirObj.options, rule, 'exec')

    suffixes = ['']
    pext = os.environ.get("PATHEXT")
    if pext:
        suffixes = pext.split(';')

    def is_exe(fpath, suffixes):
        # Return the first executable when concatenating a suffix
        return next((fpath + s for s in suffixes \
                        if os.path.exists(fpath + s) and \
                         os.access(fpath + s, os.X_OK)), None)

    fpath, fname = os.path.split(program)
    if fpath:
        return is_exe(program, suffixes)

    # Return the first executable when traversing the path
    for path in os.environ["PATH"].split(os.pathsep):
        executable = is_exe(os.path.join(path, program), suffixes)
        # If found, return it
        if executable != None:
            properties.setProperty(dirObj.options, rule, 'exec', executable) 
            return executable

    return None

def helpRule(rule, dirObj, moduleName, pad = None):
    """
    Check if the requested rule is help

    Return boolean stating if it has been executed
    """

    # Detect if any of the special rule has been detected
    hit = False

    # Calculate the rule prefix (up to the last dot)
    (prefix, b, c) = rule.rpartition('.')

    if re.match('.+[^\.]\.help$', rule):
        print i18n.get('doc_preamble').format(prefix)
        print properties.getProperty(dirObj.options, prefix, 'help')
        hit = True

    return hit

def varsRule(rule, dirObj, moduleName, pad = None):
    """
    Check if the requested rule is vars

    Return boolean stating if it has been executed
    """

    # Detect if any of the special rule has been detected
    hit = False

    # Calculate the rule prefix (up to the last dot)
    (prefix, b, c) = rule.rpartition('.')

    if re.match('.+[^\.]\.vars$', rule):
        print dirObj.dumpOptions(rule, prefix)
        hit = True

    return hit

