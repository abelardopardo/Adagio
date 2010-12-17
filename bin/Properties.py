#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Copyright (C) 2010 Carlos III University of Madrid
# This file is part of the ADA: Agile Distributed Authoring Toolkit

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
import sys, os, re, datetime, ConfigParser, StringIO, ordereddict, atexit

# @@@@@@@@@@@@@@@@@@@@  EXTEND  @@@@@@@@@@@@@@@@@@@@ 
import Ada, AdaRule, I18n, Xsltproc, Inkscape, Gotodir, Gimp, Convert, Copy
import Export, Dblatex, Exercise, Exam, Testexam, Office2pdf, Rsync
import Script, Latex, Dvips, Pdfnup, Xfig

modules = ['Ada', 'Xsltproc', 'Inkscape', 'Gotodir', 'Gimp', 'Convert',
           'Copy', 'Export', 'Dblatex', 'Exercise', 'Exam', 'Testexam',
           'Office2pdf', 'Rsync', 'Script', 'Latex', 'Dvips', 'Pdfnup', 'Xfig']
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 

# Prefix to use in the module
module_prefix = 'properties'

# Dictionary to store the ConfigParsers for a set of files. The pairs stored are
# of the form (filename, ConfigParser.RawConfigParser({},
# orderedict.OrderedDict))
_configParsers = {}

def getConfigParser(fileList):
    """
    Given a set of files, returns the resulting ConfigParser object after being
    parsed.
    """
    
    global _configParsers

    theKey = ' '.join(fileList)
    config = _configParsers.get(theKey)
    if config != None:
        # Hit in the cache, return
        Ada.logDebug('Directory', None, 'Parser HIT: ' + ' '.join(fileList))
        return config
    
    # Parse the file with a raw parser
    config = ConfigParser.RawConfigParser({}, ordereddict.OrderedDict)

    try:
        config.read(fileList)
    except Exception, msg:
        print I18n.get('severe_parse_error').format(' '.join(fileList))
        print msg
        sys.exit(1)
    
    _configParsers[theKey] = config
    return config
    
def flushConfigParsers():
    """
    Delete all the stored parsers
    """
    global _configParsers

    _configParsers = {}
    return

#
# Flush _createdDirs
#
atexit.register(flushConfigParsers);

def loadConfigFile(config, filename, aliasDict, includeChain = None):
    """
    Function that receives a set of config options (ConfigParser) and a
    filename. Parses the file, makes sure all the new config options are present
    in the first config and adds them to it. The parsing may require, through
    some options, the inclusion of additional files. The includeChain is a list
    of files to detect circual includes (and to notify the path to a missing
    file)

    Returns a pair (set of files finally loaded, list of targets detected)
    """

    Ada.logDebug('Properties', None, 'Parsing ' + filename)

    # Cannot use empty dictionary as default value in parameter as it
    # accumulates the values.
    if includeChain == None:
        includeChain = []

    # If the file to be processed has been processed already, we are in a
    # "template" chain, terminate
    if os.path.abspath(filename) in includeChain:
        commonPrefix = os.path.commonprefix(includeChain)
        print I18n.get('circular_include')
        print I18n.get('prefix') + ':', commonPrefix
        print I18n.get('files') + ':', \
            ' '.join(map(lambda x: x.replace(commonPrefix, '', 1), includeChain))
        sys.exit(1)

    # Insert the filename in the includeChain
    includeChain.append(os.path.normpath(filename))

    # If file not found dump also the include stack
    if not os.path.isfile(filename):
        print I18n.get('cannot_open_file').format(filename)
        if includeChain[:-1] != []:
            print I18n.get('included_from')
            print '  ' + '\n  '.join(includeChain[:-1])
        sys.exit(1)

    # Get the ConfigParser for the input file
    newOptions = getConfigParser([filename])

    # Move defaults to the original config passing them to a [DEFAULT] section
    defaultsIO = StringIO.StringIO()
    defaultsIO.write('[DEFAULT]\n')
    for (on, ov) in newOptions.defaults().items():
        defaultsIO.write(on + ' = ' + ov + '\n')
    defaultsIO.seek(0)
    try:
        config.readfp(defaultsIO)
    except ConfigParser.ParsingError, msg:
        print I18n.get('severe_parse_error').format(filename)
        print msg
        defaultsIO.close()
        sys.exit(1)
    
    # Move all options to the given config but checking if they are legal
    result = (set([filename]), [])
    for sname in newOptions.sections():
        # Get the prefix
        sprefix = sname.split('.')[0]

        # Treat the special case of a template section that needs to be expanded
        if sprefix == 'template':
            (a, b) = treatTemplate(config, filename, newOptions, sname, 
                                   aliasDict, includeChain)
            # Incorporate results
            result[0].update(a)
            result[1].extend(b)
            continue

        # Apply the alias expansion
        try:
            unaliased = Ada.expandAlias(sname, aliasDict)
        except SyntaxError:
            print I18n.get('error_alias_expression')
            sys.exit(1)
        
        # Get the prefix again
        sprefix = unaliased.split('.')[0]

        # Process all the new options (check if legal, add them, etc)
        for (oname, ovalue) in newOptions.items(sname):
            # Treat the special case of option with +name or name+
            prepend = False
            append = False
            if oname[0] == '+' and oname[-1] != '+':
                prepend = True
                oname = oname[1:]
            elif oname[0] != '+' and oname[-1] == '+':
                append = True
                oname = oname[:-1]

            # If not present in the default options, terminate
            if not config.has_option(sprefix, oname) and \
                    newOptions.defaults().get(oname) == None:
                optionName = sname + '.' + oname
                print I18n.get('incorrect_option_in_file').format(optionName,
                                                                  filename)
                sys.exit(1)

            # Add the section first
            try:
                config.add_section(unaliased)
            except ConfigParser.DuplicateSectionError:
                pass
            
            # Set the values considering the cases of append or prepend
            try:
                if prepend:
                    ovalue = ' '.join([ovalue, getWithDefault(config, unaliased, 
                                                              oname)])
                elif append:
                    ovalue = ' '.join([getWithDefault(config, unaliased, oname), 
                                       ovalue])
            except ConfigParser.NoOptionError:
                print I18n.get('severe_parse_error').format(filename)
                print I18n.get('error_option_addition').format(sname + '.' + 
                                                               oname)
                sys.exit(1)
            config.set(unaliased, oname, ovalue)

            try:
                # To verify interpolation
                finalValue = config.get(unaliased, oname)
            except (ConfigParser.InterpolationDepthError, 
                    ConfigParser.InterpolationMissingOptionError), e:
                print I18n.get('severe_parse_error').format(filename)
                print I18n.get('incorrect_variable_reference').format(ovalue)
                sys.exit(3)

            # Consider the special case of the alias
            if oname == 'alias':
                for keyValue in finalValue.split():
                    aliasDict[keyValue] = sname
        # Add the original target ot the result
        result[1].append(sname)

    return result

def getWithDefault(config, section, option):
    """
    Try to get a pair section/option from the given ConfigParser. If it
    does not exist, check if the section has the form name.subname. If so, check
    for the option name/option.
    """
    try:
        result = config.get(section, option)
        return result
    except ConfigParser.InterpolationMissingOptionError, e:
        print I18n.get('incorrect_variable_reference').format(option)
        sys.exit(1)
    except ConfigParser.NoOptionError:
        pass
    section = section.split('.')[0]
    return config.get(section, option)
    
def dump(options, pad = None, sections = None):
    """
    Function to print out the content of a config object
    """
    if sections == None:
        sections = options.sections()

    if pad == None:
	pad = ''

    try:
        for sname in sections:
            for (oname, vname) in options.items(sname):
                print pad, '  ', oname, '=', options.get(sname, oname)
    except ConfigParser.InterpolationDepthError, e:
        print I18n.get('severe_option_error')
        print e
        sys.exit(1)

def LoadDefaults(config):
    """
    Loads all the default options for all the rules in the given ConfigParser.
    """
    global modules

    # Traverse the modules and load the values in the "option" variable
    for moduleName in modules:
        # Get the three required values from the module
        sectionName = eval(moduleName + '.module_prefix')
        options = eval(moduleName + '.options')
        documentation = eval(moduleName + '.documentation')

        # If any of these variables is None, bomb out.
        if sectionName == None or options == None or documentation == None:
            raise TypeError, 'Incorrect type in LoadDefaults'

        # If the section is already present in the config, never mind
        try:
            config.add_section(sectionName)
        except ConfigParser.DuplicateSectionError:
            pass

        # Loop over all the default values and add them to the proper sections
        for (vn, vv, msg) in options:
            config.set(sectionName, vn, vv)
            try:
                # To verify interpolation
                config.get(sectionName, vn)
            except (ConfigParser.InterpolationDepthError, 
                    ConfigParser.InterpolationMissingOptionError), e:
                print I18n.get('incorrect_variable_reference').format(vv)
                print I18n.get('fatal_error')
                sys.exit(3)

        # Add the string for the help
        helpStr = documentation.get(Ada.config_defaults['locale'])
        if helpStr == None:
            helpStr = documentation.get('en')
        config.set(sectionName, 'help', helpStr)
    return

def Execute(target, directory, pad = None):
    """
    Given a target and a directory, it checks which rule needs to be invoked and
   performs the invokation.
    """

    global modules

    # Keep a copy of the target before applying aliases
    originalTarget = target

    # Apply the alias expansion
    try:
        target = Ada.expandAlias(target, directory.alias)
    except SyntaxError:
        print I18n.get('error_alias_expression')
        sys.exit(1)

    # Detect help or dump targets with/without section name
    specialTarget = re.match('(.+\.)?dump$', target) or \
        re.match('(.+\.)?help$', target) or \
        re.match('(.+\.)?clean$', target) or \
        re.match('(.+\.)?deepclean$', target) or \
        re.match('(.+\.)?dumphelp$', target) or \
        re.match('(.+\.)?helpdump$', target)

    # Make sure the target is legal.
    if not specialTarget and not directory.options.has_section(target):
        print I18n.get('illegal_target_name').format(t = originalTarget,
                                                     dl = directory.current_dir)
        sys.exit(2)

    # Get the target prefix (everything up to the first dot)
    targetParts = target.split('.')
    modulePrefix = targetParts[0]
    if len(targetParts) == 1:
        targetPrefix = modulePrefix
    else:
        targetPrefix = '.'.join(targetParts[:-1])

    if pad == None:
	pad = ''

    # Traverse the modules and execute the "Execute" function
    executed = False
    for moduleName in modules:
        
        # If the target does not belong to this module, keep iterating
        if modulePrefix != eval(moduleName + '.module_prefix'):
            continue
            
        Ada.logInfo(originalTarget, directory, 'Enter ' + directory.current_dir)
            
        # Print msg when beginning to execute target in dir
        print pad + 'BB', originalTarget

        # Check the condition
        if not AdaRule.evaluateCondition(targetPrefix, directory.options):
            return

        # Detect and execute "special" targets
        if specialTargets(target, directory, moduleName, pad):
            print pad + 'EE', originalTarget
            Ada.logInfo(originalTarget, directory, 
                        'Exit ' + directory.current_dir)
            return
        
        # Execute. 
        if moduleName == 'Gotodir':
            # Gotodir must take into account padding
            eval(moduleName + '.Execute(target, directory, pad)')
        else:
            eval(moduleName + '.Execute(target, directory)')

        # Detect if no module executed the target
        executed = True

        print pad + 'EE', originalTarget

        Ada.logInfo(originalTarget, directory, 'Exit ' + directory.current_dir)

    if not executed:
        print I18n.get('unknown_target').format(originalTarget)
        sys.exit(1)

def treatTemplate(config, filename, newOptions, sname, aliasDict, includeChain):
    """
    Process template and parse the required files.

    - Config what you have so far
    - filename file where the template is found
    - NewOptions is the new config
    - sname is the section name where the template was detected
    - includeChain are the files that are included

    Returns the pair (set of files processed, list of targets detected)
    """

    # Get the pairs in the template section that are not in the defaults
    # dictionary
    fileItem = [(a, b) for (a, b) in newOptions.items(sname)
                if not a in newOptions.defaults()]

    # There must be a single option with name 'files'
    if len(fileItem) != 1:
        print I18n.get('template_error').format(filename)
        sys.exit(1)

    # The option must have name files
    if fileItem[0][0] != 'files':
        print I18n.get('incorrect_option_in_file').format(fileItem[0][0],
                                                          filename)
        sys.exit(1)

    # Add template section to the given config to evaluate the files assignment
    config.add_section(sname)
    config.set(sname, 'files', fileItem[0][1])

    try:
        # Get the files and catch interpolation error
        templateFiles = config.get(sname, 'files').split()
    except (ConfigParser.InterpolationDepthError, 
            ConfigParser.InterpolationMissingOptionError), e:
        print I18n.get('severe_parse_error').format(filename)
        print I18n.get('incorrect_variable_reference').format(fileItem[0][1])
        sys.exit(3)


    # Remove section from the original config:
    config.remove_section(sname)
    
    # Process the template files recursively!
    result = (set([]), [])
    for fname in templateFiles:
        # Get the full path of the template
        if os.path.isabs(fname):
            templateFile = fname
        else:
            templateFile = os.path.abspath(os.path.join(os.path.dirname(filename), fname))
            
        (a, b) = loadConfigFile(config, templateFile, aliasDict, includeChain)
        result[0].update(a)
        result[1].extend(b)
    return result

def specialTargets(target, directory, moduleName, pad = None):
    """
    Check if the requested target is special:
    - dump
    - help
    - clean
    - deepclean

    Return boolean stating if any of them has been executed
    """
    
    # Detect if any of the special target has been detected
    hit = False

    # Calculate the target prefix (up to the last dot)
    (prefix, b, c) = target.rpartition('.')

    # Remember if it is one of the helpdump or dumphelp
    doubleTarget = re.match('(.+\.)?helpdump$', target) or \
        re.match('(.+\.)?dumphelp$', target)

    # If requesting help, dump msg and terminate
    if doubleTarget or re.match('(.+)?help$', target):
        msg = directory.getWithDefault(prefix, 'help')
        print I18n.get('doc_preamble').format(prefix) + '\n\n' + msg + '\n\n'
        hit = True

    # If requesting var dump, do it and finish
    if doubleTarget or re.match('(.+\.)?dump$', target):
        AdaRule.dumpOptions(target, directory, prefix)
        hit =  True

    # CLEAN
    if re.match('(.+\.)?clean$', target):
        eval(moduleName + '.clean(\'' + re.sub('\.clean$', '', target)
             + '\', directory)')
        hit =  True

    # DEEPCLEAN
    if re.match('(.+\.)?deepclean$', target):
        if clean_function != None:
            if prefix.startswith('gotodir'):
                # Gotodir propagates the pad for the deep
                eval(moduleName + '.clean(\'' + re.sub('\.clean$', '', target)
                     + '\', directory, True, pad)')
            else:
                eval(moduleName + '.clean(\'' + re.sub('\.clean$', '', target)
                     + '\', directory)')
            hit =  True

    return hit

