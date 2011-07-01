#!/usr/bin/python
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
import sys, os, re, ConfigParser, atexit

import adagio, properties, i18n

# Table to store tuples:
#   path: Directory object
#
# to avoid executing twice the same directory (cache). It stores pairs such as
# (path + givenOptions, dirObj)

_createdDirs = {}

def getDirectoryObject(path, givenOptions):
    """
    Function that given a path checks if it exists in the createdDirs hash. If
    so, returns the object. If not, a new object is created.
    """
    global _createdDirs

    # The key to access the hash is the concatenation of path and givenOptions
    theKey = path + ''.join(sorted(givenOptions))
    dirObj = _createdDirs.get(theKey)
    if dirObj != None:
        # Hit in the cache, return
        adagio.logDebug('Directory', None, 'Directory HIT: ' + path)
        return dirObj

    # Create new object
    dirObj = Directory(path, givenOptions)
    _createdDirs[theKey] = dirObj
    return dirObj

def versionToInteger(version):
    """
    Fucntion that given a ??.??.?? version (all digits), produces an integer.
    """

    match = re.match('^(?P<major>[0-9]+)\.(?P<minor>[0-9]+)\.(?P<pt>[0-9]+)$',
                     version)
    if not match:
        print i18n.get('incorrect_version_format').version
        sys.exit(3)

    result = 0
    result = 1000000 * int(match.group('major')) + \
        10000 * int(match.group('minor')) + int(match.group('pt'))

    return result

def dump(self):
    """
    Show the object content
    """

    global _createdDirs

    print '### Created Dir Objects'
    print '  ', '\n  '.join(_createdDirs.keys())

    for (a, go), d in _createdDirs.items():
        print '### Dir: ', a
        print '  Rules: ', d.executed_rules
        print '  Prev dir: ', d.previous_dir
        print '  Given dict: ', go
        print '  Options:\n    ',
        properties.dump(self.options, '   ')

# Search for pfile all the way up the hierarchy (until the top)
def findProjectDir(pfile, startdir):
    """
    Function that traverses the directories upward until the file name given by
    the option adagio.project_file is found.

    WARNING: This function returns always an ABSOLUTE path
    """
    currentDir = startdir

    while (os.path.splitdrive(currentDir)[1] != os.sep) and \
            (not os.path.exists(os.path.join(currentDir, pfile))):
        currentDir = os.path.abspath(os.path.join(currentDir, ".."))

    return currentDir

def flushCreatedDirs():
    """
    Removes all the created dirs. Function registered atexit to facilitate
    debugging
    """
    global _createdDirs

    _createdDirs = {}
    return

#
# Flush _createdDirs
#
atexit.register(flushCreatedDirs);

class Directory:
    pass
    """
    Class to represent a directory where Adagio executes some rules.

    TODO:

    * Insert a mark in the object that is true when it is being processed and
    false when done. With this mechanism, it is very easy to detect a circular
    dependency where a directory is visited when it is being processed. The
    stack of directories should be shown at that point.

    * Speaking of which. Is there a stack of directories being processed so far?

    """

    # Expression to manipulate a variable reference
    varReference = re.compile('\${(?P<varname>[^}]+)}')

    # Objects of this class have:

    # previous_dir:     dir before switching to the given one
    # current_dir:      dir represented by this object
    # givenOptions:     list of options given from outside this dir
    # options:          ConfigParse with the options given in properties.ddo
    # alias:            Dictionary of 'aliasname': 'aliasvalue'
    # rule_list:        rules in the properties.ddo file
    # current_rule:     rule being processed
    # executing:        true if in the middle of the "Execute" method
    # executed_rules:   set of rules executed with empty given directory
    # option_files:     set of files providing options (to detect dependencies)

    # Change to the given dir and initlialize fields
    def __init__(self, path=os.getcwd(), givenOptions = []):

        # Initial values
        self.previous_dir =    os.getcwd()
        self.current_dir =     os.path.abspath(path)
        self.givenOptions =    ''
        self.options =         None
        self.rule_list =    []
        self.alias =           {}
        self.current_rule = None
        # Boolean to detect if a directory has been visited twice
        self.executing =       False
        self.executed_rules =  set([])
        self.option_files =    set([])

        adagio.logInfo('Directory', None, 'New dir object in ' + self.current_dir)

        configDefaults = adagio.getConfigDefaults(self.current_dir)

        # Compute the project home
        os.chdir(self.current_dir)
        configDefaults['project_home'] = \
            findProjectDir(configDefaults['project_file'], self.current_dir)
        os.chdir(self.previous_dir)

        # Safe parser to store the options, the defaults are loaded here
        self.options = properties.initialConfig(configDefaults)

        #
        # STEP 1: Load the default options from the Rule files
        #
        adagio.LoadDefaults(self.options)

        #
        # STEP 2: Load the ~/.adagiorc if any
        #
        userAdagioConfig = os.path.expanduser('~/.adagiorc')
        if os.path.isfile(userAdagioConfig):
            # Swallow user file on top of global options, and if trouble, report
            # up
            try:
                (newFiles, b) = properties.loadConfigFile(self.options,
                                                          userAdagioConfig,
                                                          self.alias)
                self.option_files.update(newFiles)
            except ValueError, e:
                print i18n.get('severe_parse_error').format(userAdagioConfig)
                print str(e)
                sys.exit(3)

        #
        # STEP 3: Options given in the project file
        #
        adagioProjFile = os.path.join(self.current_dir,
                                      configDefaults['project_home'],
                                      self.options.get(adagio.module_prefix,
                                                       'project_file'))
        if os.path.isfile(adagioProjFile):
            try:
                (newFiles, b) = \
                    properties.loadConfigFile(self.options,
                                              os.path.abspath(adagioProjFile),
                                              self.alias)
                self.option_files.update(newFiles)
            except ValueError, e:
                print i18n.get('severe_parse_error').format(adagioProjFile)
                print str(e)
                sys.exit(3)

        #
        # STEP 4: Options given in the Properties file in the directory
        #
        adagioPropFile = self.options.get('adagio', 'property_file')
        propAbsFile = os.path.abspath(os.path.join(self.current_dir,
                                                   adagioPropFile))
        if os.path.exists(propAbsFile):
            try:
                (newFiles, confRules) = properties.loadConfigFile(self.options,
                                                                  propAbsFile,
                                                                  self.alias)
                self.option_files.update(newFiles)
            except ValueError, e:
                print i18n.get('severe_parse_error').format(propAbsFile)
                print str(e)
                sys.exit(3)
                
            self.rule_list = confRules
        else:
            # If there is no rule file, notify and execute help rule
            adagio.logInfo('Directory', None, 'No ' + adagioPropFile + \
                            ' found in ' + self.current_dir)
            print i18n.get('cannot_find_properties').format(adagioPropFile,
                                                            self.current_dir)
            self.rule_list = []

        #
        # STEP 5: Options given from outside the directory
        #
        for assignment in givenOptions:
            # Chop assignment into its three parts
            (sn, on, ov) = assignment.split()

            sn = properties.expandAlias(sn, self.alias)
            # Check first if the option is legal
            if not self.options.has_option(sn, on):
                optionName = sn + '.' + on
                print i18n.get('incorrect_option').format(optionName)
                sys.exit(3)

            # Insert the new assignment in options of the directory
            properties.setProperty(self.options, sn, on, ov)

        # Compare Adagio versions to see if execution is allowed
        if not self.isCorrectAdagioVersion():
            version = self.options.get(adagio.module_prefix, 'version')
            adagio.logError('Directory', None, \
                             'ERROR: Incorrect Adagio Version (' + version + ')')
            print i18n.get('incorrect_version').format(version)
            sys.exit(3)

        self.current_rule = None

        # Dump a debug message showing the list of rules detected in the
        # config file
        adagio.logDebug('Directory', None,
                     'Rules: ' + ', '.join(self.rule_list))

        return

    def __del__(self):
        """
        Object no longer needed
        """
        return

    def isCorrectAdagioVersion(self):
        """
        Method to check if the curren adagio version is within the potentially
        limited values specified in variables adagio.minimum_version,
        adagio.maximum_version and adagio.exact_version
        """

        global module_prefix

        # Get versions to allow execution depending on the version
        minVersion = self.options.get(adagio.module_prefix, 'minimum_version')
        maxVersion = self.options.get(adagio.module_prefix, 'maximum_version')
        exactVersion = self.options.get(adagio.module_prefix, 'exact_version')

        # If no value is given in any variable, avanti
        if (minVersion == '') and (maxVersion == '') and (exactVersion == ''):
            return True

        currentValue = versionToInteger(self.options.get(adagio.module_prefix,
                                                         'version'))

        # Translate all three variables to numbers
        minValue = currentValue
        if (minVersion != ''):
            minValue = versionToInteger(minVersion)

        maxValue = currentValue
        if (maxVersion != ''):
            maxValue = versionToInteger(maxVersion)

        exactValue = currentValue
        if (exactVersion != ''):
            exactValue = versionToInteger(exactVersion)

        # Check if an exact version is required
        if (exactValue == currentValue) and (minValue <= currentValue) and \
                (currentValue <= maxValue):
            return True

        return False

    def Execute(self, rules = [], pad = ''):
        """
        properties.ddo has been parsed into a ConfigParse. Loop over the rules
        and execute all of them.
        """

        adagio.logInfo('Directory', self, 'Execute in ' + self.current_dir)

        # Change directory to the current one
        self.previous_dir = os.getcwd()
        os.chdir(self.current_dir)

        # Print a line flagging the start of the execution showing the maximum
        # suffix of the current directory up to 80 chars.
        showCurrentDir = self.current_dir[len(pad) + 3 - 80:]
        if len(self.current_dir) > (77 - len(pad)):
            showCurrentDir = '...' + showCurrentDir[3:]

        print pad + '++ ' + showCurrentDir

        # Make sure no circular execution is produced
        if self.executing:
            print i18n.get('circular_execute_directory').format(self.current_dir)
            sys.exit(2)
        self.executing = True

        # If no rules are given, choose the default ones, that is, ignore:
        # - adagio
        # - clean*
        # - local*
        #
        toExecRules = [x for x in self.rule_list
                         if not re.match('^adagio$', x) and
                         not re.match('^clean(\.?\S+)?$', x) and
                         not re.match('^local(\.?\S+)?$', x) and
                         not re.match('^rsync(\.?\S+)?$', x)]

        # If no rule is given, execute all except the filtered ones
        if rules == []:
            rules = toExecRules

        # If any of the rules is dump, help, clean, expand the current rules
        # to add them that suffix, otherwise simply accumulate
        finalRules = []
        for rule in rules:
            if rule == 'deepclean':
                # Get all the rules
                finalRules.extend([x + '.deepclean' for x in toExecRules])
                finalRules.reverse()
            elif rule == 'clean':
                # Get all the rules except the "gotodir" ones
                finalRules.extend([x + '.clean'
                                     for x in toExecRules])
                finalRules.reverse()
            elif rule == 'dump':
                finalRules.extend([x + '.dump' for x in toExecRules])
            elif rule == 'help':
                finalRules.extend([x + '.help' for x in toExecRules])
            elif rule == 'local':
                finalRules.extend([x for x in toExecRules
                                     if not x.startswith('gotodir')])
            else:
                finalRules.append(rule)

        adagio.logDebug('Directory', self, '  Rules: ' + str(finalRules))

        # If after all these preparations, finalRules is empty, help is
        # needed, hardwire the rule to adagio.help.
        if finalRules == []:
            finalRules = ['adagio.help']

        adagio.logDebug('Directory', self,
                     ' to execute ' + ' '.join(finalRules))

        for rule_name in finalRules:

            # Check the cache to see if rule has already been executed
            if rule_name in self.executed_rules:
                adagio.logInfo('Directory', self,
                            'Rule HIT: ' + self.current_dir + ': ' + \
                            rule_name)
                continue

            # Execute the rule
            adagio.Execute(rule_name, self, pad)

            # Insert executed rule in cache
            self.executed_rules.add(rule_name)

        self.executing = False
        adagio.logDebug('Directory', self,
                     ' Executed Rules: ' + str(self.executed_rules))

        print pad + '-- ' +  showCurrentDir

        # Change directory to the current one
        os.chdir(self.previous_dir)

        return

    def getProperty(self, rule, option):
        """
        Try to get a pair rule/option from the ConfigParser in the object. If
        it does not exist, check if the rule has the form name.subname. If
        so, check for the option name/option.
        """
        return properties.getProperty(self.options, rule, option)

################################################################################

if __name__=="__main__":
    p1 = Directory(os.getcwd())
    p1.Execute()

    p2 = Directory(os.getcwd())
