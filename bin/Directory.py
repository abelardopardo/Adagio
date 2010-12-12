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
import sys, os, re, ConfigParser, ordereddict

import Ada, Properties, I18n, Xsltproc

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
    theKey = path + ''.join(givenOptions)
    dirObj = _createdDirs.get(theKey)
    if dirObj != None:
        # Hit in the cache, return
        if dirObj != None:
            Ada.logDebug('Directory', None, 'Directory HIT: ' + path)
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
        print I18n.get('incorrect_version_format').version
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
        print '  Targets: ', d.executed_targets
        print '  Prev dir: ', d.previous_dir
        print '  Given dict: ', go
        print '  Options:\n    ',
        Properties.dump(self.options, '   ')

# Search for .sc all the way up the hierarchy (until the top)
def findProjectDir(pfile):
    """
    Function that traverses the directories upward until the file name given by
    the option ada.projectfile is found, None otherwise

    WARNING: If the directory found is the current one, the EMPTY string is
    returned. If any other directory is returned, the os.path.sep is added at
   the end. This is to maintain the convention that the function returns the
   MINIMUM dir expression to be used as prefix.
    """
    currentDir = '.'

    while (os.path.abspath(currentDir) != '/') and \
            (not os.path.exists(os.path.join(currentDir, pfile))):
        currentDir = os.path.join(currentDir, "..")

    if os.path.abspath(currentDir) == '/' or currentDir == '.':
        return ''

    currentDir = currentDir + os.path.sep

    return currentDir

def resetExecuted():
    """
    Sets all the executed flags of all directories to false. This is useful for
    debugging purposes. When re-starting a script, the old values of these
    variables are still valid.
    """
    global _createdDirs

    for (a, dObj) in _createDirs.items():
        dObj.executed = False
    return

class Directory:
    pass
    """
    Class to represent a directory where ADA executes some rules.

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
    # options:          ConfigParse with the options read from the Properties.txt
    # section_list:     targets in the Properties.txt file
    # current_section:  section being processed
    # executing:        true if in the middle of the "Execute" method
    # executed_targets: set of targets executed with empty given directory
    # option_files:     set of files providing options (to detect dependencies)
    # Change to the given dir and initlialize fields
    def __init__(self, path=os.getcwd(), givenOptions = []):

        # Initial values
        self.previous_dir =     os.getcwd()
        self.current_dir =      os.path.abspath(path)
        self.givenOptions =     ''
        self.options =          None
        self.section_list =     []
        self.current_section =  None
        # Boolean to detect if a directory has been visited twice
        self.executing =        False
        self.executed_targets = set([])
        self.option_files =     set([])

        Ada.logInfo('Directory', None, 'New dir object in ' + self.current_dir)

        configDefaults = Ada.getConfigDefaults(self.current_dir)

        # Compute the project home
        os.chdir(self.current_dir)
        configDefaults['project_home'] = \
            findProjectDir(configDefaults['project_file'])
        os.chdir(self.previous_dir)

        # Safe parser to store the options, the defaults are loaded here
        self.options = ConfigParser.SafeConfigParser(configDefaults,
                                                     ordereddict.OrderedDict)

        #
        # STEP 1: Set ada.home in global options
        #
        self.options.add_section(Ada.module_prefix)
        self.options.set(Ada.module_prefix, 'home', Ada.home)

        #
        # STEP 2: Load the default options from the Rule files
        #
        Properties.LoadDefaults(self.options)

        #
        # STEP 3: Load the $HOME/.adarc if any
        #
        userAdaConfig = os.path.join(os.environ.get('HOME'), '.adarc')
        if os.path.isfile(userAdaConfig):
            # Swallow user file on top of global options, and if trouble, report
            # up
            try:
                (newFiles, b) = Properties.loadConfigFile(self.options, 
                                                          userAdaConfig)
                self.option_files.update(newFiles)
            except ValueError, e:
                print I18n.get('severe_parse_error').format(userAdaConfig)
                print e
                sys.exit(3)

        #
        # STEP 4: Options given in the project file
        #
        adaProjFile = os.path.join(self.current_dir,
                                   configDefaults['project_home'],
                                   self.options.get(Ada.module_prefix, 
                                                    'project_file'))
        if os.path.isfile(adaProjFile):
            try:
                (newFiles, b) = \
                    Properties.loadConfigFile(self.options, 
                                              os.path.abspath(adaProjFile))
                self.option_files.update(newFiles)
            except ValueError, e:
                print I18n.get('severe_parse_error').format(adaProjFile)
                sys.exit(3)

        #
        # STEP 5: Options given in the Properties file in the directory
        #
        adaPropFile = self.options.get('ada', 'property_file')
        propAbsFile = os.path.abspath(os.path.join(self.current_dir,
                                                   adaPropFile))
        if not os.path.exists(propAbsFile):
            Ada.logInfo('Directory', None, 'No ' + adaPropFile + \
                            ' found in ' + self.current_dir)
            print I18n.get('cannot_find_properties').format(adaPropFile,
                                                            self.current_dir)
            sys.exit(3)
        try:
            (newFiles, sections) = Properties.loadConfigFile(self.options, 
                                                             propAbsFile)
            self.option_files.update(newFiles)
        except ValueError, e:
            print I18n.get('severe_parse_error').format(propAbsFile)
            print e
            sys.exit(3)

        self.section_list = sections

        #
        # STEP 6: Options given from outside the dir
        #
        # Compute the project home
        for assignment in givenOptions:
            # Chop assignment into its three parts
            (sn, on, ov) = assignment.split()
            # Check first if the option is legal
            if not self.options.has_option(sn, on):
                optionName = sn + '.' + on
                print I18n.get('incorrect_option').format(value)
                sys.exit(3)
            # Insert in the options in the directory
            try:
                self.options.set(sn, on, ov)
                # To verify interpolation
                self.options.get(sn, on)
            except ConfigParser.NoSectionError:
                print I18n.get('incorrect_section').format(sn)
                sys.exit(1)
            except ConfigParser.InterpolationDepthError, e:
                print I18n.get('incorrect_variable_reference').format(ov)
                sys.exit(3)

        # Compare ADA versions to see if execution is allowed
        if not self.isCorrectAdaVersion():
            version = self.options.get(Ada.module_prefix, 'version')
            Ada.logError('Directory', None, \
                             'ERROR: Incorrect Ada Version (' + version + ')')
            print I18n.get('incorrect_version').format(version)
            sys.exit(3)

        self.current_section = None

        # Dump a debug message showing the list of sections detected in the
        # config file
        Ada.logDebug('Directory', None,
                     'Sections: ' + ', '.join(self.section_list))

        return

    def __del__(self):
        """
        Object no longer needed
        """
        return

    def isCorrectAdaVersion(self):
        """ Method to check if the curren ada version is within the potentially
        limited values specified in variables ada.minimum_version,
        ada.maximum_version and ada.exact_version"""

        global module_prefix

        # Get versions to allow execution depending on the version
        minVersion = self.options.get(Ada.module_prefix, 'minimum_version')
        maxVersion = self.options.get(Ada.module_prefix, 'maximum_version')
        exactVersion = self.options.get(Ada.module_prefix, 'exact_version')

        # If no value is given in any variable, avanti
        if (minVersion == '') and (maxVersion == '') and (exactVersion == ''):
            return True

        currentValue = versionToInteger(self.options.get(Ada.module_prefix,
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

    def Execute(self, targets = [], pad = ''):
        """
        Properties.txt has been parsed into a ConfigParse. Loop over the targets
        and execute all of them.
        """

        Ada.logInfo('Directory', self, 'Execute in ' + self.current_dir)

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
            print I18n.get('circular_execute_directory').format(self.current_dir)
            sys.exit(2)
        self.executing = True

        # If no targets are given, choose the default ones, that is, ignore:
        # - ada
        # - clean*
        # - local*
        #
        toExecTargets = [x for x in self.section_list
                         if not re.match('^ada$', x) and
                         not re.match('^clean(\.?\S+)?$', x) and
                         not re.match('^local(\.?\S+)?$', x)]

        # If no target is given, execute all except the filtered ones
        if targets == []:
            targets = toExecTargets

        # If any of the targets is dump, help, clean, expand the current targets
        # to add them that suffix
        finalTargets = []
        for target in targets:
            if target == 'clean':
                finalTargets.extend([x + '.clean' for x in toExecTargets])
                finalTargets.reverse()
            elif target == 'dump':
                finalTargets.extend([x + '.dump' for x in toExecTargets])
            elif target == 'help':
                finalTargets.extend([x + '.help' for x in toExecTargets])
            else:
                finalTargets.append(target)

        Ada.logDebug('Directory', self, '  Targets: ' + str(finalTargets))

        # Loop over all the targets to execute
        for target_name in finalTargets:

            # Check the cache to see if target has already been executed
            if target_name in self.executed_targets:
                Ada.logInfo('Directory', self,
                            'HIT: ' + self.current_dir + ': ' + target_name)
                continue

            # Execute the target
            Properties.Execute(target_name, self, pad)

            # Insert executed target in cache
            self.executed_targets.add(target_name)

        self.executing = False
        Ada.logDebug('Directory', self,
                     ' Executed Targets: ' + str(self.executed_targets))

        print pad + '-- ' +  showCurrentDir

        # Change directory to the current one
        os.chdir(self.previous_dir)

        return

    def getWithDefault(self, section, option):
        """
        Try to get a pair section/option from the ConfigParser in the object. If
        it does not exist, check if the section has the form name.subname. If
        so, check for the option name/option.
        """
        try:
            result = self.options.get(section, option)
            return result
        except ConfigParser.InterpolationMissingOptionError, e:
            print I18n.get('incorrect_variable_reference').format(option)
            sys.exit(1)
        except ConfigParser.NoOptionError:
            pass
        section = section.split('.')[0]
        return self.options.get(section, option)


################################################################################

if __name__=="__main__":
    p1 = Directory(os.getcwd())
    p1.Execute()

    p2 = Directory(os.getcwd())
