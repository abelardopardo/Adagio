#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.padro@uc3m.es)
#
#
#
import sys, os, re, datetime, ConfigParser, StringIO, ordereddict

# @EXTEND@
import Ada, I18n, Xsltproc, Inkscape, Gotodir, Gimp, Convert, Copy
import Export, Dblatex, Exercise, Exam, Testexam

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

    return

def loadConfigFile(config, filename, includeChain = set({})):
    """
    Function that receives a first set of config options (ConfigParser) and a
    filename. Parses the file, makes sure all the new config options are present
    in the first config.

    Returns the list of detected sections or None if problems
    """

    # If the file to be processes is already processed, we are done
    if os.path.abspath(filename) in includeChain:
        print I18n.get('circular_include')
        print ' '.join(includeChain)
        sys.exit(1)

    if not os.path.isfile(filename):
        print I18n.get('cannot_open_file').format(filename)
        return None

    # Open the disk file
    configfile = open(filename, 'r')
    if configfile == None:
        I18n.get('cannot_open_file').format(filename)
        return None

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

    configfile.close()

    # Parse the memory file with a raw parser to check option validity
    tmpconfig = ConfigParser.RawConfigParser({},
                                             ordereddict.OrderedDict)
    try:
        # Reset the read pointer in the memory file
        memoryFile.seek(0)
        tmpconfig.readfp(memoryFile)
    except Exception, msg:
        print I18n.get('severe_parse_error').format(filename)
        print msg
        memoryFile.close()
        return None
    result = tmpconfig.sections()

    # If config is None, we are done, no need to treat anything more
    if config == None:
        return result

    # Process the includes!

    # Move all options to the given config but checking if they are legal
    for sname in result:
        # Get the prefix to check if the option is legal
        sprefix = sname.split('.')[0]
        for (oname, ovalue) in tmpconfig.items(sname):
            # If not present in the default options, terminate
            if not config.has_option(sprefix, oname) and \
                    tmpconfig.defaults().get(oname) == None:
                optionName = sname + '.' + oname
                print I18n.get('incorrect_option_in_file').format(optionName,
                                                                  filename)
                memoryFile.close()
                return None

            # If present in the default options, add its value
            try:
                config.add_section(sname)
            except ConfigParser.DuplicateSectionError:
                pass
            config.set(sname, oname, ovalue)

    # No longer needed
    memoryFile.close()

    return result

def dump(options, pad = '', sections = None):
    """
    Function to print out the content of a config object
    """
    if sections == None:
        sections = options.sections()

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
    loadOptionsInConfig(options, Ada.module_prefix,      Ada.options)
    loadOptionsInConfig(options, Xsltproc.module_prefix, Xsltproc.options)
    loadOptionsInConfig(options, Inkscape.module_prefix, Inkscape.options)
    loadOptionsInConfig(options, Gotodir.module_prefix,  Gotodir.options)
    loadOptionsInConfig(options, Gimp.module_prefix,     Gimp.options)
    loadOptionsInConfig(options, Convert.module_prefix,  Convert.options)
    loadOptionsInConfig(options, Copy.module_prefix,     Copy.options)
    loadOptionsInConfig(options, Export.module_prefix,   Export.options)
    loadOptionsInConfig(options, Dblatex.module_prefix,  Dblatex.options)
    loadOptionsInConfig(options, Exercise.module_prefix, Exercise.options)
    loadOptionsInConfig(options, Exam.module_prefix,     Exam.options)
    loadOptionsInConfig(options, Testexam.module_prefix, Testexam.options)

def Execute(target, directory, pad = ''):
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

    Ada.logFatal('Properties', directory, 'Unexpected target ' + target)
    print I18n.get('fatal_error')
    sys.exit(1)

    return

