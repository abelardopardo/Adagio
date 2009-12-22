#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, re

import Ada, Config, Properties, I18n

class Directory:
    """Class to represent a directory where ADA executes some rules."""

    # Expression to manipulate a variable reference
    varReference = re.compile('\${(?P<varname>[^}]+)}')

    # Table to store (path, list of targets): Directory Object to avoid
    # creating two objects for the same directory (cache)
    createdDirs = {}

    fixed_definitions = {
        'ada.home': os.path.abspath('..'),
        'ada.property_file': 'Properties.txt',
        'file.separator': os.path.sep
        }

    # Objects of this class also have:

    # previous_dir: dir before switching to the given one
    # current_dir: dir represented by this object
    # givenDict: dictionary given from outside this dir
    # options: dictionary with the options read from the Properties.txt
    # current_section: section being processed
    # line_number: line for the section in Properties.txt being processed

    # Change to the given dir and initlialize fields
    def __init__(self, path=os.getcwd(), targets = set([]), givenDict = {}):
        self.previous_dir = os.getcwd()
        self.current_dir = os.path.abspath(path)
        os.chdir(self.current_dir)
        self.givenDict = givenDict
        self.options = {'ada.basedir': path }
        self.current_section = None
        self.line_number = 0

        # Store the created object only if the given dict is empty
        if not givenDict:
            Directory.createdDirs[(self.current_dir, \
                                   ' '.join(sorted(targets)))] = self

        adaPropFile = self.get('ada.property_file')

        # Check first if the Properties.txt is present
        if not os.path.exists(adaPropFile):
            return

        (status, n) = Config.Parse(adaPropFile, None, self.SetOption)

        # If the parsing failed, terminate
        if not self.checkParse(adaPropFile, status, n):
            return

        return

    def __del__(self):
        """
        Object no longer needed, so change the directory again
        """
        os.chdir(self.previous_dir)
        return

    def SetOption(self, section, varname, value, lineNumber, oldValue = None,
                  newSection = False, fileOut = None):

        # A new section appears
        if section != self.current_section:
            current_section = section
            self.line_number = lineNumber
            print 'New section ' + section

        fullName = section + '.' + varname

        if value != None:
            value = self.expandVars(str(value))

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
    def get(self, keyValue):
        """
        Look up the given keyValue first into the fixed values, then into the
        given dict and finally into the options dictionary.
        """

        m = Config.fullVarNameRE.match(keyValue)
        if m == None:
            # Not a valid key
            raise NameError, 'Name ' + keyValue + ' not found in ' + \
                  self.current_dir

        # Look up first in the fixed definitions
        result = Directory.fixed_definitions.get(keyValue)
        if result != None:
            return result

        # Look up in the given Dict
        result = self.givenDict.get(keyValue)
        if result != None:
            return result

        # Look up in the options dict
        result = self.options.get(keyValue)
        if result != None:
            return result

        # Look up in the options dict again, but this time without the section
        # name
        if m.group('sectionsubname') == None and \
               m.group('sectionsubname2') == None:
            raise NameError, 'Name ' + keyValue + ' not found in ' + \
                  self.current_dir

        newKeyValue = m.group('sectionname')
        result = self.options.get(newKeyValue)
        if result != None:
            return result

        # Look now in the defaultOptions dictionary
        result = Properties.defaultOptions.get(keyValue)
        if result != None:
            return result

        result = Properties.defaultOptions.get(newKeyValue)
        if result != None:
            return result

        raise NameError, 'Name ' + keyValue + ' not found in ' + \
              self.current_dir

    def expandVars(self, expression):
        """
        Given an expression with a reference to a variable ${sect.varname},
        replace that reference by the value.
        """
        return re.sub(Directory.varReference, \
                      lambda x: self.get(x.group('varname')), expression)

    def dump(self):
        """
        Show the object content
        """
        print '### Created Dirs'
        print '  ' + '\n  '.join([a for a, b in Directory.createdDirs.keys()])

        for (a, b) in Directory.createdDirs.keys():
            print '### Dir: ' + a
            print '  Targets: ' + b
            print '  Prev dir: ' + self.previous_dir
            print '  Given dict: ' + str(self.givenDict)
            print '  Options:\n    ' + '\n    '.join([' = '.join([a, b]) \
                                                      for a, b in \
                                                      sorted(self.options.items())])
            print '  Current section: ' + str(self.current_section)
            print '  Line number: ' + str(self.line_number)

################################################################################

if __name__=="__main__":
    p1 = Directory(os.getcwd())

    p2 = Directory(os.getcwd())

    p1.dump()
