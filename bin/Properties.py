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
# Author: Abelardo Pardo (abelardo.padro@uc3m.es)
#
import sys, os, re, datetime, ConfigParser, StringIO, ordereddict

# @EXTEND@
import Ada, I18n, Xsltproc, Inkscape, Gotodir, Gimp, Convert, Copy
import Export, Dblatex, Exercise, Exam, Testexam, Office2pdf, Rsync
import Script

# Prefix to use in the module
module_prefix = 'properties'

def loadOptionsInConfig(config, sectionName, options):
    """
    Given a ConfigParser object config, the name of a section and a list of
    triplets (varname, value, message), upload (section, varname= value) to the
    configuration.
    """

    if sectionName == None or options == None:
        raise TypeError, 'Incorrect type in loadOptionsInConfig'

    # If the section is already created, never mind
    try:
        config.add_section(sectionName)
    except ConfigParser.DuplicateSectionError:
        pass

    # Loop over all the given values and add them to the proper sections
    for (vn, vv, msg) in options:
        config.set(sectionName, vn, vv)
        # ABEL: Verify with a get
    return

def loadConfigFile(config, filename, includeChain = None):
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

    # Open the disk file
    configfile = open(filename, 'r')
    if configfile == None:
        I18n.get('cannot_open_file').format(filename)
        sys.exit(1)

    # Pass the file to a StringIO removing the leading spaces from the lines
    # containing an equal sign.
    memoryFile = StringIO.StringIO()
    for line in configfile:
        # Remove comments
        line = re.sub('[#;].*$', '', line)

        # Remove the leading space of the lines with a variable definition
        if re.search('=', line) or re.search(':', line):
            line = re.sub('^\s+', '', line)

        # Should we detect multple lines terminated in \ ?
        memoryFile.write(line)

    memoryFile.seek(0)
    configfile.close()

    # Parse the memory file with a raw parser to check option validity
    newOptions = ConfigParser.RawConfigParser({},
                                              ordereddict.OrderedDict)

    try:
        # Reset the read pointer in the memory file
        newOptions.readfp(memoryFile)
    except Exception, msg:
        print I18n.get('severe_parse_error').format(filename)
        print msg
        memoryFile.close()
        sys.exit(1)

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
                                   includeChain)
            # Incorporate results
            result[0].update(a)
            result[1].extend(b)
            continue

        # Check if the option is legal
        for (oname, ovalue) in newOptions.items(sname):
            # If not present in the default options, terminate
            if not config.has_option(sprefix, oname) and \
                    newOptions.defaults().get(oname) == None:
                optionName = sname + '.' + oname
                print I18n.get('incorrect_option_in_file').format(optionName,
                                                                  filename)
                memoryFile.close()
                sys.exit(1)

            # If present in the default options, add its value
            try:
                config.add_section(sname)
            except ConfigParser.DuplicateSectionError:
                pass
            config.set(sname, oname, ovalue)
            # ABEL: Verify with a get

        # Add it to the result
        result[1].append(sname)

    # No longer needed
    memoryFile.close()

    return result

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

def LoadDefaults(options):
    """
    Loads all the default options for all the rules in the given ConfigParser
    """
    # @EXTEND@
    loadOptionsInConfig(options, Ada.module_prefix,        Ada.options)
    loadOptionsInConfig(options, Xsltproc.module_prefix,   Xsltproc.options)
    loadOptionsInConfig(options, Inkscape.module_prefix,   Inkscape.options)
    loadOptionsInConfig(options, Gotodir.module_prefix,    Gotodir.options)
    loadOptionsInConfig(options, Gimp.module_prefix,       Gimp.options)
    loadOptionsInConfig(options, Convert.module_prefix,    Convert.options)
    loadOptionsInConfig(options, Copy.module_prefix,       Copy.options)
    loadOptionsInConfig(options, Export.module_prefix,     Export.options)
    loadOptionsInConfig(options, Dblatex.module_prefix,    Dblatex.options)
    loadOptionsInConfig(options, Exercise.module_prefix,   Exercise.options)
    loadOptionsInConfig(options, Exam.module_prefix,       Exam.options)
    loadOptionsInConfig(options, Testexam.module_prefix,   Testexam.options)
    loadOptionsInConfig(options, Office2pdf.module_prefix, Office2pdf.options)
    loadOptionsInConfig(options, Rsync.module_prefix,      Rsync.options)
    loadOptionsInConfig(options, Script.module_prefix,     Script.options)

def Execute(target, directory, pad = None):
    """
    Given a target and a directory, it checks which rule needs to be invoked and
   performs the invokation.
    """

    # Detect help or dump targets with/without section name
    specialTarget = re.match('(.+\.)?dump$', target) or \
        re.match('(.+\.)?help$', target) or \
        re.match('(.+\.)?clean$', target) or \
        re.match('(.+\.)?dumphelp$', target) or \
        re.match('(.+\.)?helpdump$', target)

    # Make sure the target is legal.
    if not specialTarget and not directory.options.has_section(target):
        print I18n.get('illegal_target_name').format(t=target,
                                                     dl=directory.current_dir)
        sys.exit(2)

    # Get the target prefix (everything up to the first dot)
    targetPrefix = target.split('.')[0]

    Ada.logInfo('Properties', directory, 'Target ' + target)

    if pad == None:
	pad = ''

    # Select the proper set of rules
    # Code to extend when a new set of rules is added (@EXTEND@)
    if targetPrefix == Ada.module_prefix:
        Ada.Execute(target, directory, pad)
    if targetPrefix == Xsltproc.module_prefix:
        Xsltproc.Execute(target, directory, pad)
        return
    elif targetPrefix == Inkscape.module_prefix:
        Inkscape.Execute(target, directory, pad)
        return
    elif targetPrefix == Gotodir.module_prefix:
        Gotodir.Execute(target, directory, pad)
        return
    elif targetPrefix == Gimp.module_prefix:
        Gimp.Execute(target, directory, pad)
        return
    elif targetPrefix == Convert.module_prefix:
        Convert.Execute(target, directory, pad)
        return
    elif targetPrefix == Copy.module_prefix:
        Copy.Execute(target, directory, pad)
        return
    elif targetPrefix == Export.module_prefix:
        Export.Execute(target, directory, pad)
        return
    elif targetPrefix == Dblatex.module_prefix:
        Dblatex.Execute(target, directory, pad)
        return
    elif targetPrefix == Exercise.module_prefix:
        Exercise.Execute(target, directory, pad)
        return
    elif targetPrefix == Exam.module_prefix:
        Exam.Execute(target, directory, pad)
        return
    elif targetPrefix == Testexam.module_prefix:
        Testexam.Execute(target, directory, pad)
        return
    elif targetPrefix == Office2pdf.module_prefix:
        Office2pdf.Execute(target, directory, pad)
        return
    elif targetPrefix == Rsync.module_prefix:
        Rsync.Execute(target, directory, pad)
        return
    elif targetPrefix == Script.module_prefix:
        Script.Execute(target, directory, pad)
        return

    print I18n.get('unknown_target').format(target)
    sys.exit(1)

def treatTemplate(config, filename, newOptions, sname, includeChain):
    """
    Process template and parse the required files.

    - Config what you have so far
    - filename file where the template is found
    - NewOptions is the new config
    - sname is the section name where the template was detected
    - includeChain are the files that are included

    Returns the pair (set of files processed, list of targets detected)
    """

    fileItem = newOptions.items(sname)
    # There must be a single option with name 'files'
    if len(fileItem) != 1 or fileItem[0][0] != 'files':
        print I18n.get('template_error').format(filename)
        sys.exit(1)

    # Add template section to the given config to evaluate the files assignment
    config.add_section(sname)
    config.set(sname, 'files', fileItem[0][1])
    # ABEL: Verify with a get
    templateFiles = config.get(sname, 'files').split()

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
            
        (a, b) = loadConfigFile(config, templateFile, includeChain)
        result[0].update(a)
        result[1].extend(b)
    return result
