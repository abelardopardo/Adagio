#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.padro@uc3m.es)
#
#
#
import sys, os, re, datetime, ConfigParser, StringIO, logging, ordereddict

import Ada, I18n, Xsltproc

# Prefix to use in the module
module_prefix = 'properties'

# Set the logger for this module
logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger(module_prefix)

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
        print sectionName, vn, vv
        config.set(sectionName, vn, vv)

    return

def loadConfigFile(config, filename, newconfig = None):
    """
    Function that receives a first set of config options (ConfigParser) and a
    filename. Parses the file, makes sure all the new config options are present
    in the first config. If newconfig is not None the new options are stored in
    newconfig

    Returns boolean notifying if there has been errors
    """

    if not os.path.isfile(filename):
        I18n.get('cannot_open_file').format(filename)
        return True

    # Open the disk file 
    configfile = open(filename, 'r')
    if configfile == None:
        I18n.get('cannot_open_file').format(filename)
        return True

    # Pass the file to a StringIO removing the leading spaces from the lines
    # containing an equal sign.
    memoryFile = StringIO.StringIO()
    for line in configfile:
        if re.search('=', line) or re.search(':', line):
            line = re.sub('^\s+', '', line)
        memoryFile.write(line)
    configfile.close()
    # Parse the memory file with a raw parser to check option validity
    newconfig = ConfigParser.RawConfigParser({}, 
                                             ordereddict.OrderedDict)
    try:
        # Reset the read pointer in the memory file
        memoryFile.seek(0)
        newconfig.readfp(memoryFile)
    except:
        print I18n.get('severe_parse_error').format(filename)
        memoryFile.close()
        return True
    

    # Move all options to the given config but checking if they are legal
    for sname in newconfig.sections():
        for (oname, ovalue) in newconfig.items(sname):
            if not config.has_option(sname, oname):
                optionName = sname + '.' + oname
                print I18n.get('incorrect_option_in_file').format(optionName,
                                                                  filename)
                memoryFile.close()
                return True
            # If newconfig is given store in there.
            if newconfig:
                newconfig.set(sname, oname, ovalue)
            else:
                # Else, fold in the given one
                config.set(sname, oname, ovalue)

    # No longer needed
    memoryFile.close()
    return False

def dump(options, pad = ''):
    """
    Function to print out the content of a config object
    """
    for sname in options.sections():
        print pad, '--', sname, len(options.options(sname))
        for (oname, vname) in options.items(sname):
            print pad, '  ', oname, '=', options.get(sname, oname)

def Execute(target, dirLocation):
    """
    Given a target and a directory, it checks which rule needs to be invoked and
    performs the invokation.
    """

    # Obtain the name of the section and subsection if any
    (sect, subsect, m) =Config.getSectionNameFromPropertyName(target)

    # Make sure the target is legal.
    if not isTargetLegal(target):
        print I18n.get('illegal_target_name').format(t=target,
                                                     dl=dirLocation.current_dir)
        sys.exit(2)

    # Select the proper set of rules
    # Code to extend when a new set of rules is added (@EXTEND@)
    if sect == Xsltproc.module_prefix:
        Xsltproc.Execute(target, dirLocation)
    elif sect == Ada.module_prefix:
        Ada.Execute(target, dirLocation)
    else:
        print I18n.get('illegal_target_prefix').format(sect)

################################################################################
# OLD
################################################################################

def getSectionOptionTable(sectionName):
    """
    Function that given a section name, returns the table containing all the
    options allowed in that section or None if the section is incorrect.
    """

    # Code to extend when a new set of rules is added (@EXTEND@)
    if prefix == Ada.module_prefix:
        return Ada.options
    elif prefix == Xsltproc.module_prefix:
        return Xsltproc.options

    return None

def getOption(prefix, name, table = None):
    """
    Function to ask for an option name in a given option table. Return the first
    value of the pair found after lookup. First check the given table. If
    nothing given, traverse all the available dictionaries.
    """
    if table != None:
        return table[name][0]

    table = getSectionOptionTable(prefix)

    if table == None:
        raise NameError, I18n.get('option') + ' ' + prefix + '.' + name + \
            ' ' + I18n.get('not_found') + '.'

    return table[name][0]

def setOption(prefix, name, value, table = None):
    # To be implemented
    pass

def reservedTargets(target, directory, module_prefix, optionDict):
    """
    Given a target, a directory and a dictionary with options, checks if it is a
    reserved target and performs the appropriate task. If so, True is
    returned. If not, False is returned and nothing is done.
    """

    (a, b, c) = Config.splitVarName(target)
    targetSuffix = c
    targetPrefix = a
    if b != None:
        targetPrefix = targetPrefix + '.' + b

    if targetSuffix == '_show_options':
        print '---- ' + module_prefix + ': ' + I18n.get('options') + ' ----'
        for a in sorted(optionDict.keys()):
            print '* ' + a + ': ' + str(directory.get(targetPrefix + '.' + a))
        print '----'
        return True
    elif targetSuffix == '_help_options':
        print '---- ' + module_prefix + ': ' + I18n.get('options') + ' ----'
        for (a, (b, c)) in sorted(optionDict.items()):
            print '* ' + a + ' (Value: ' + str(directory.get(targetPrefix + '.' + a)) + ')'
            print '  ' + str(c)
        print '----'
        return True

    return False

################################################################################
def main():
    (status, n) = Config.Parse(sys.argv[1], None, SetOption)

    print str(status) + ', ' + str(n)
    for s in __sectionList:
        for k, v in sorted([(k, v) for k, v in __options.items() \
                            if k.startswith(s + '.')]):
            print k + ': ' + str(v)

if __name__=="__main__":
    main()
