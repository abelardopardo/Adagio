#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import sys, os, re, logging

import Ada, Config, Properties, I18n

# Set the logger for this module
logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger('ada.directory')

# Table to store tuples:
#   path: Directory object
#
# to avoid executing twice the same directory (cache)
createdDirs = {}

def getDirectoryObject(path):
    """
    Function that given a path checks if it exists in the createdDirs hash. If
    so, returns the object. If not, a new object is created.
    """
    dirObj = createdDirs.get(os.path.abspath(path), None)
    # Hit in the cache, return
    if dirObj != None:
        logger.debug('HIT: ' + path)
        return dirObj


    # Create new object
    return Directory(path)

def dump(self):
    """
    Show the object content
    """
    print '### Created Dir Objects'
    print '  ' + '\n  '.join(createdDirs.keys())

    for a in createdDirs.keys():
        print '### Dir: ' + a
        print '  Targets: ' + a.executed_targets
        print '  Prev dir: ' + a.previous_dir
        print '  Given dict: ' + str(a.givenDict)
        print '  Options:\n    ' + '\n    '.join([' = '.join([a, b]) \
                                                  for a, b in \
                                                  sorted(self.options.items())])

class Directory:
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

    # previous_dir: dir before switching to the given one
    # current_dir: dir represented by this object
    # givenDict: dictionary given from outside this dir
    # options: dictionary with the options read from the Properties.txt
    # current_section: section being processed
    # line_number: line for the section in Properties.txt being processed
    # executing: true if in the middle of the "Execute" method
    # section_list: targets in the Properties.txt file
    # executed_targets: set of targets executed with empty given directory

    # Change to the given dir and initlialize fields
    def __init__(self, path=os.getcwd()):
        logger.info('New object in ' + path)

        # Make sure a directory is not created twice
        if os.path.abspath(path) in createdDirs:
            print I18n.get('circular_directory').format(path)
            sys.exit(2)

        # Assign
        self.previous_dir = os.getcwd()
        self.current_dir = os.path.abspath(path)
        self.givenDict = None
        self.options = { 'ada.basedir': self.current_dir }
        self.current_section = None
        self.line_number = -1
        self.section_list = []
        # Boolean to detect if a directory has been visited twice
        self.executing = False
        self.executed_targets = set([])

        os.chdir(self.current_dir)

        # Insert the directory in the cache, no targets have been processed
        createdDirs[self.current_dir] = self

        # Check first if the Properties.txt is present
        adaPropFile = Ada.options['property_file'][0]
        if not os.path.exists(adaPropFile):
            logger.info('No ' + adaPropFile + ' found in ' + self.current_dir)
            return

        # Parse the file
        self.current_section = None
        self.line_number = 0
        self.section_list = []

        logger.debug('Parsing ' + adaPropFile + ' in ' + self.current_dir)
        (status, n) = Config.Parse(adaPropFile, None, self.SetOption)

        # If the parsing failed, terminate
        if not self.checkParse(adaPropFile, status, n):
            return

        # Dump a debug message showing the list of sections detected in the
        # config file
        logger.debug('Sections: ' + str(self.section_list))

        return

    def __del__(self):
        """
        Object no longer needed, so change the directory again
        """
        os.chdir(self.previous_dir)
        return

    def Execute(self, targets = [], givenDict = None):
        """
        Execute the directory targets. This is one of the most important
        functions because it parses the file and invokes the different rule
        execution scripts.
        """

        logger.info('Execute in ' + self.current_dir)

        # Make sure no circular execution is produced
        if self.executing:
            print I18n.get('circular_execute_directory').format(self.current_dir)
            sys.exit(2)
        self.executing = True

        # If no targets are given, choose all of them except ada
        if targets == []:
            targets = [x for x in self.section_list if x != 'ada']

        logger.debug('  Targets: ' + str(targets))
        logger.debug('  GivenDict: ' + str(givenDict))

        # Loop over all the targets to execute
        for target_name in targets:

            # Check the cache to see if target has already been executed
            if target_name in self.executed_targets:
                logger.info('HIT: ' + self.current_dir + ': ' + target_name)
                continue

            # Execute the target
            Properties.Execute(target_name, self)

            # Insert executed target in cache only if the given dict is empty
            if not givenDict:
                self.executed_targets.add(target_name)

        self.executing = False

        logger.debug(' Executed Targets: ' + str(self.executed_targets))

        return

    def SetOption(self, section, varname, value, lineNumber, oldValue = None,
                  newSection = False, fileOut = None):

        # A new section appears
        if section != self.current_section:
            # If a section appears for second time, protest
            if next((True for n in self.section_list if n == section), False):
                print 'Section already present in file.'
                print section + ', ' + str(self.current_section)
                return False

            self.current_section = section
            self.line_number = lineNumber

            # Append new section to the list for further reference
            self.section_list.append(section)

            logger.debug('Parsing section ' + section)


        # Check if the option given is legal, if not, the getOption method bombs
        # out
        fullName = section + '.' + varname
        (a, b, c) = Config.splitVarName(fullName)

        try:
            Properties.getOption(a, c)
        except NameError, e:
            file = Ada.options['property_file'][0]
            print I18n.get('severe_parse_error').format(ln=lineNumber,
                                                        pfile = file)
            print e
            sys.exit(2)
        except KeyError, e:
            file = Ada.options['property_file'][0]
            print I18n.get('severe_parse_error').format(ln=lineNumber,
                                                        pfile = file)
            print I18n.get('option') + ' ' + fullName + \
                ' ' + I18n.get('not_found') + '.'
            sys.exit(2)

        if value != None:
            try:
                value = self.expandVars(str(value))
            except NameError, e:
                file = Ada.options['property_file'][0]
                print I18n.get('severe_parse_error').format(ln=lineNumber,
                                                            pfile = file)
                print e
                sys.exit(2)

        self.options[fullName] = value

        return True

    def checkParse(self, file, status, lineNumber):
        """
        Print messages depending on the outcome of the parse function
        """
        if status == Config.Diagnostics.OK:
            return True
        elif status == Config.Diagnostics.ERROR_ALREADY_TREATED:
            # No message here, it has been treated
            return False
        elif status == Config.Diagnostics.FILE_NOT_FOUND:
            print I18n.get('file_not_found').format(file)
            return False
        elif status == Config.Diagnostics.CANNOT_OPEN_FILE:
            print I18n.get('config_parse_cannot_open').format(file)
            return False
        elif status == Config.Diagnostics.LINE_IN_NO_SECTION:
            print I18n.get('config_parse_line_nosection').format(pfile = file,
                                                                 ln = lineNumber)
            return False
        elif status == Config.Diagnostics.INCORRECT_ASSIGNMENT:
            print I18n.get('config_incorrect_assignment').format(pfile = file,
                                                                 ln = lineNumber)
            return False

        print I18n.get('options_unchecked_parse_error').format(pfile = file,
                                                               ln = lineNumber)
    def get(self, keyValue, otherDict = None):
        """
        Split a property name in section, subsection and name and call a function
        """
        (sect, subsect, name) = Config.splitVarName(keyValue)

        # If the name is malformed, raise exception
        if sect == None:
            raise NameError, I18n.get('option') + ' ' + keyValue + \
                ' ' + I18n.get('not_found') + '.'

        return self.getSplit(keyValue, sect, subsect, name, otherDict)


    def getSplit(self, fullName, sect, subsect, name, otherDict = None):
        """
        Look up the given fullName in a set of dictionaries and return the
        first one that contains it.

        It should be noted that fullName = sect + '.' + subsect + '.' name

        The order in which these dictionaries are checked are:

        A.1) Given dictionary of the directory (fullName)

        A.2) Given dictionary of the directory (sect.name)

        B.1) options dictionary in the directory (fullName)

        B.2) options dictionary in the directory (sect.name)

        If otherDict is given: Check name otherDict

        else: Check fullName with Properties.get
        """

        # Prepare result and property name without the subsection part
        result = None
        shortname = sect + '.' + name

        # A) If there is a given dict and has the key, return it
        if self.givenDict != None:
            # A.1) Check with the full name
            result = self.givenDict.get(fullName)
            if result != None:
                return result
            # A.2) Check with the simplified name
            result = self.givenDict.get(shortname)
            if result != None:
                return result

        # B.1) If fullName is in options, return it
        result = self.options.get(fullName)
        if result != None:
            return result

        # B.2) If sect.name is in options, return it
        result = self.options.get(shortname)
        if result != None:
            return result

        # If nothing worked so far, check all the dictionaries for the sect.name
        return Properties.getOption(sect, name, otherDict)

    def set(self, keyName, value):
        """
        Set the pair (keyName, value) in the options dictionary
        """
        self.options[keyName] = value

    def expandVars(self, expression):
        """
        Given an expression with a reference to a variable ${sect.varname},
        replace that reference by the value.
        """
        return re.sub(Directory.varReference, \
                      lambda x: self.get(x.group('varname')), expression)

################################################################################

if __name__=="__main__":
    logger.setLevel(10)
    p1 = Directory(os.getcwd())
    p1.Execute()

    p2 = Directory(os.getcwd())

#     p1.dump()
