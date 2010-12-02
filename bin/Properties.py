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
import Export, Dblatex, Exercise, Exam, Testexam, Office2pdf

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

def loadConfigFile(config, filename, includeChain = None):
    """
    Function that receives a first set of config options (ConfigParser) and a
    filename. Parses the file, makes sure all the new config options are present
    in the first config.

    Returns the Raw config object with the filename parsed.
    """

    Ada.logDebug('Properties', None, 'Parsing ' + filename)

    # Cannot use empty dictionary as default value in parameter as it
    # accumulates the values.
    if includeChain == None:
        includeChain = set([])

    # If the file to be processed has been processed already processed, we are
    # in a "template" chain, terminate
    if os.path.abspath(filename) in includeChain:
        commonPrefix = os.path.commonprefix(list(includeChain))
        print I18n.get('circular_include')
        print I18n.get('prefix') + ':', commonPrefix
        print I18n.get('files') + ':', \
            ' '.join(map(lambda x: x.replace(commonPrefix, '', 1), includeChain))
        sys.exit(1)

    # Insert the filename in the includeChain
    includeChain.add(os.path.normpath(filename))

    if not os.path.isfile(filename):
        print I18n.get('cannot_open_file').format(filename)
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

    configfile.close()

    # Parse the memory file with a raw parser to check option validity
    result = ConfigParser.RawConfigParser({},
                                          ordereddict.OrderedDict)
    try:
        # Reset the read pointer in the memory file
        memoryFile.seek(0)
        result.readfp(memoryFile)
    except Exception, msg:
        print I18n.get('severe_parse_error').format(filename)
        print msg
        memoryFile.close()
        sys.exit(1)

    # Process templates if they are present
    result = expandTemplate(result, filename, includeChain)

    # If config is None, we are done, no need to treat anything more
    if config == None:
        return result

    # Move all options to the given config but checking if they are legal
    for sname in result.sections():
        # Get the prefix to check if the option is legal
        sprefix = sname.split('.')[0]
        for (oname, ovalue) in result.items(sname):
            # If not present in the default options, terminate
            if not config.has_option(sprefix, oname) and \
                    result.defaults().get(oname) == None:
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

    print I18n.get('unknown_target').format(target)
    sys.exit(1)

def expandTemplate(config, filename, includeChain):
    """
    Process the options in the given config, and if there is any template,
    process it by calling recursivelly to loadConfigFile.
    """

    # If there is no template, terminate
    if not config.has_section('template'):
        return config

    Ada.logDebug('Properties', None, 'Expanding ' + filename)

    # Process the sections in result that are "template"
    result = ConfigParser.RawConfigParser(config.defaults(),
                                          ordereddict.OrderedDict)

    # Loop over the newly read values and detect templates
    for sname in config.sections():

        if sname != 'template':
            result.add_section(sname)
            for (oname, ovalue) in config.items(sname):
                result.set(sname, oname, ovalue)
            continue

        # Process only the template options that are no in the default
        items = [(a, b) for (a, b) in config.items(sname) \
                     if not a in config.defaults()]
        if len(items) != 1:
            print I18n.get('template_error').format(filename)
            sys.exit(1)

        # Fetch the only template value
        (oname, templateFiles) = items[0]
        # It must be a 'file' option, if not, bomb out
        if oname != 'files':
            print I18n.get('template_error').format(filename)
            sys.exit(1)

        for fname in templateFiles.split():
            # Get the full path of the template
            if os.path.isabs(fname):
                templateFile = fname
            else:
                templateFile = os.path.join(os.path.dirname(filename), fname)
            # Included template must exist
            if not os.path.isfile(templateFile):
                print I18n.get('file_not_found').format(templateFile)
                sys.exit(1)

            # Call recursively to expand the template
            expandedConfig = loadConfigFile(None, templateFile, includeChain)
            # Transfer all the values to the result
            for s in expandedConfig.sections():
                for (o, v) in expandedConfig.items(s):
                    if not result.has_section(s):
                        result.add_section(s)
                    result.set(s, o, v)

    return result

