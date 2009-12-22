#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, re, sys, StringIO

idChars = '[a-zA-Z][a-zA-Z0-9_\-]*'
sectionMainNameEXP = '(?P<sectionname>' + idChars + ')'
subsectionNameEXP = '("(?P<sectionsubname>[^"]+)"' + \
                    '|(?P<sectionsubname2>' + idChars + '))'
sectionFullNameEXP = sectionMainNameEXP + '(( |\.)' + \
                     subsectionNameEXP + ')?'
sectionNameRE = re.compile(sectionFullNameEXP)
sectionLineRE = re.compile('^\[' + sectionFullNameEXP + '\]$')

varNameEXP = '(?P<varname>[a-zA-Z][a-zA-Z0-9_\-]*)'
fullVarNameRE = re.compile(sectionFullNameEXP + '\.' + varNameEXP)

valueEXP = '(\s*=\s*(?P<value>.+))?$'
assignmentRE = re.compile(varNameEXP + valueEXP, re.DOTALL | re.MULTILINE)

class SectionNameMatch():
    Line = 1
    Name = 2
    FullVarName = 3

class Diagnostics():
    OK = 0
    ERROR_ALREADY_TREATED = 1
    FILE_NOT_FOUND = 2
    CANNOT_OPEN_FILE = 3
    LINE_IN_NO_SECTION = 4
    INCORRECT_ASSIGNMENT = 5
    INCORRECT_PROPERTY = 6
    MALFORMED_SECTION = 7
    MALFORMED_LINE = 8
    SECTION_NOT_FOUND = 9


def Parse(parseFile, memoryFile, lineProcessFunc = None):
    """
    Function that receives a file name to parse, a memoryFile to store its
    content, a data Table where to store the definitions and a lineProcessFunc
    to invoke for every configuration file detected.

    The function returns a pair with the following structure:
    (Code, linenumber)
    """
    if not os.path.exists(parseFile):
        return (Diagnostics.FILE_NOT_FOUND, 0)

    # Open the file
    cfile = open(parseFile, 'r')
    if cfile == None:
        return (Diagnostics.CANNOT_OPEN_FILE, 0)

    # Loop over the file lines
    section = None
    multiline = ''
    linenumber = 0
    for line in cfile:
        linenumber = linenumber + 1

        # If multiline, keep processing
        if (len(line) > 1) and (line[-2] == '\\'):
            multiline = multiline + line
            continue

        # If last line of multiline, reset and leave line to process
        if multiline != '':
            line = multiline + line
            multiline = ''

        # Store line in memory file
        if memoryFile != None:
            memoryFile.write(line)

        # Normalize space and remove comments
        line = comment_remover(line)
        line = re.sub('^[ \t]*|[ \t]*$', '', line)
        line = re.sub('[ \t]+', ' ', line)

        # Remove the final newline
        line = line[:-1]

        # Ignore empty lines
        if len(line) == 0:
            continue

        # Check if it is a section line
        (newSection, m) = regularSectionName(line)

        if newSection != None:
            # If section line remember it
            section = newSection
        else:
            # Variable assignment line

            # If line with no section, format error.
            if section == None:
                return (Diagnostics.LINE_IN_NO_SECTION, linenumber)

            # Obtain variable name and value
            m = assignmentRE.match(line)
            if m == None:
                # If no match, format error
                return (Diagnostics.INCORRECT_ASSIGNMENT, linenumber)

            # Treat multiline values and remove quotes
            value = m.group('value')
            if value != None:
                value = re.sub('\\\\\n', '', value)
                value = re.sub('[ \t]+', ' ', value)
                value = doublequote_remover(value)
            else:
                value = True

            # Execute the given function
            if lineProcessFunc != None:
                if not lineProcessFunc(section, m.group('varname'), value, \
                                       linenumber):
                    return (Diagnostics.ERROR_ALREADY_TREATED, linenumber)

    return (Diagnostics.OK, 0)

def Set(fileIn, fileOut, propFullName, propValue, lineProcessFunc = None):
    """
    fileIn: StringIO file to read
    fileOut: StringIO file to update
    propFullName: section.propname to be set
    propValue: new property value
    lineProcessFunc: function to invoke when the line that assigns the given
    property is reached. The params are:
      section: section name
      propName: property name without the section
      propValue: new property value given to Set
      linenumber: Number of line being processed
      value: old value in the file
      oldLine: full raw line for the given property
      newSect: boolean stating if the variable is in a new section
      fileOut: file where the output is stored

      if this function returns False, the line is written in fileOut

    This function returns a (status, linenumber) pair. Linenumber is 0 if no
    relevant linenumber information is obtained.
    """
    # See if the given propFullName is correct
    (section, m) = regularSectionName(propFullName, SectionNameMatch.FullVarName)
    if m == None:
        return (Diagnostics.INCORRECT_PROPERTY, 0)

    propName = m.group('varname')

    # Make sure the fileIn is prepared
    fileIn.seek(0)

    # Loop over the stored lines
    currentSection = None
    linenumber = 0
    multiline = ''
    processed = False
    for line in fileIn:
        linenumber = linenumber + 1

        # If multiline, keep processing
        if (len(line) > 1) and (line[-2] == '\\'):
            multiline = multiline + line
            continue

        # If last line of multiline, reset and leave line o process
        if multiline != '':
            line = multiline + line
            multiline = ''

        # Normalize string and remove comments
        auxline = comment_remover(line)
        auxline = re.sub('^[ \t]*|[ \t]*$', '', auxline)
        auxline = re.sub('[ \t]+', ' ', auxline)

        # Remove the final newline
        auxline = auxline[:-1]

        # Ignore empty line
        if len(auxline) == 0:
            # Dump line in output file
            fileOut.write(line)
            continue

        # Detected section line
        (newSection, m) = regularSectionName(auxline)
        if newSection != None:
            # If at the end of the section where the given prop belongs, process
            if currentSection == section and not processed:

                # Execute the given function
                if lineProcessFunc != None:
                    if not lineProcessFunc(section, propName, propValue, \
                                           line, None, False, fileOut):
                        return (Diagnostics.ERROR_ALREADY_TREATED, linenumber)
                processed = True

            currentSection = newSection
            fileOut.write(line)
        else:
            # Regular assignment line
            # match both sides of the equal
            m = assignmentRE.match(auxline)
            if m == None:
                # If no match, format error
                return (Diagnostics.MALFORMED_LINE, linenumber)
            # If section and varname match, it is an overwrite
            elif (currentSection == section) and \
                 (m.group('varname') == propName):
                value = m.group('value')
                # Execute the given function
                if lineProcessFunc != None:
                    if not lineProcessFunc(section, propName, propValue, \
                                           line, value, False, fileOut):
                        fileOut.write(line)
                processed = True
            # If nothing matches, it is a regular line
            else:
                fileOut.write(line)

    # It is a new variable in a new section, therefore, write at the end
    if not processed:
        if propValue != None:
            # Execute the given function
            if lineProcessFunc != None:
                if not lineProcessFunc(section, propName, propValue, \
                                       None, None, currentSection != section, \
                                       fileOut):
                    return (Diagnostics.ERROR_ALREADY_TREATED, linenumber)

    return (Diagnostics.OK, 0)

def DeleteSection(fileIn, fileOut, section, lineProcessFunc = None):
    """
    fileIn: StringIO file containing the stored config file
    fileOut: File where the new version has to be stored
    section: Section to be deleted/renamed

    lineProcessFunc()
      section: section name
      oldLine: full raw line for the given property
      fileOut: file where the output is stored
    """

    # See if the given section name is correct
    (section, m) = regularSectionName(section, SectionNameMatch.Name)
    if m == None:
        return (Diagnostics.MALFORMED_SECTION, 0)

    # Make sure the fileIn is prepared
    fileIn.seek(0)

    # Loop over the stored lines
    currentSection = None
    linenumber = 0
    multiline = ''
    skip = False
    processed = False
    for line in fileIn:
        linenumber = linenumber + 1

        # If multiline, keep processing
        if (len(line) > 1) and (line[-2] == '\\'):
            multiline = multiline + line
            continue

        # If last line of multiline, reset and leave line o process
        if multiline != '':
            line = multiline + line
            multiline = ''

        # Normalize string and remove comments
        auxline = comment_remover(line)
        auxline = re.sub('^[ \t]*|[ \t]*$', '', auxline)
        auxline = re.sub('[ \t]+', ' ', auxline)

        # Remove the final newline
        auxline = auxline[:-1]

        # Ignore empty line
        if len(auxline) == 0:
            # Dump line in config file
            fileOut.write(line)
            continue

        # Detected section line
        (lineSection, m) = regularSectionName(auxline)
        if lineSection != None:
            if lineSection == section:
                # Invoke a function
                skip = True
                processed = True
            else:
                skip = False
                fileOut.write(line)
        else:
            # Line inside the section that needs to be deleted
            if skip:
                continue

            # Regular assignment line
            fileOut.write(line)

    # It is a new variable in a new section, therefore, write at the end
    if not processed:
        return (Diagnostics.SECTION_NOT_FOUND, 0)

    return (Diagnostics.OK, 0)

def regularSectionName(fullText, select = SectionNameMatch.Line):
    # Match either a full line with [] or simply the section name
    if select == SectionNameMatch.Line:
        m = sectionLineRE.match(fullText)
    elif select == SectionNameMatch.Name:
        m = sectionNameRE.match(fullText)
    else:
        m = fullVarNameRE.match(fullText)

    if m == None:
        return (None, m)

    section = m.group('sectionname')
    if m.group('sectionsubname') != None:
        section = section + '.' + m.group('sectionsubname')
    elif m.group('sectionsubname2') != None:
        section = section + '.' + m.group('sectionsubname2')

    return (section, m)

def comment_remover(text):
    """
    Function to remove comments. Adapted from one published
    in stackoverflow.com courtesy of MizardX
    """
    # Function invoked every time a match is produced
    def replacer(match):
        s = match.group(0)
        if s.startswith('#') or s.startswith(';'):
            return ''
        else:
          return s
    # This is the key. Match not only the comment, but also strings surrounded
    # by double quotes
    pattern = re.compile(r'#.*?$|;.*?$|"(?:\\.|[^\\"])*"', \
                         re.DOTALL | re.MULTILINE)
    return re.sub(pattern, replacer, text)

def doublequote_remover(text):
    """
    Function to remove surrounding double quotes.
    """
    # Function invoked every time a match is produced
    def replacer(match):
        return match.group(0)[1:-1]

    # Match the string surrounded by double quotes
    pattern = re.compile(r'"(?:\\.|[^"])*"', re.DOTALL | re.MULTILINE)
    return re.sub(pattern, replacer, text)

def main():
    """
    """
    dictionary = {}
    vars = Parse(sys.argv[1], None, None)

    print "Dictionary:"
    print str(dictionary)

if __name__ == "__main__":
    main()
