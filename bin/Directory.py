#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, re
import Properties

# Dictionary with global definitions. All variables suitable to be modified from
# the Properties.txt file need to be included either here (to guarantee a
# default value) or in the Directory object.
globalVariables = Properties.Properties()

#######################################################################
#
# Initial values
#
#######################################################################
globalVariables['ada.debug.level'] = '0'
globalVariables['ada.exact.version'] = ''
globalVariables['ada.minimum.version'] = ''
globalVariables['ada.maximum.version'] = ''

# Ignored variables when migrating from ANT
# ada.course.home.valid.candidate

class Directory(object):
    """Class to produce objects that represent a directory where ADA needs to
    perform some processing."""

    def __init__(self,
                 path=os.getcwd(),
                 givenExportDst=''):

        # Initial values
        self.path = path
        self.properties = Properties.Properties()

        # Calculate ada.course.home from this directory
        self.__setAdaCourseHome()

        # Parse the properties file
        self.__parseProperties(os.path.join(self.path, 'Properties.txt'))

        # Parse the Ada.properties file in the ada.course.home
        self.__parseProperties(os.path.join(globalVariables['ada.course.home'],
                                            'Ada.properties'))

        # Store the givenExportDst
        self.exportDestinations = [givenExportDst]

    def __parseProperties(self, fileName):

        # Check if the fileName to parse exists, if not, terminate
        if not os.path.exists(fileName):
            return

        # Parse the properties file
        self.properties.load(open(fileName))

        # Loop over all keys and expand with respect to global vars
        curlies = re.compile("\${.+?}")
        for pKey in self.properties.propertyNames():
            value = self.properties[pKey]
            found = curlies.findall(value)

            # If the value has references to expand
            if found != []:
                # Loop over the references
                for f in found:
                    srcKey = f[2:-1]
                    if globalVariables.has_key(srcKey):
                        value = value.replace(f, globalVariables[srcKey], 1)

                self.properties[pKey] = value.strip()

    def getProperty(self, key):
        """ Return a property for the given key by looking up first in the local
        dictionary and if not found, look up in the global one"""

        if self.properties.has_key(key):
            return self.properties.getProperty(key)
        return globalVariables.getProperty(key)

    def setProperty(self, key, value):
        """ Set the property for the given key in the local dictionary"""

        self.properties.setProperty(key, value)

    def appendExportDst(self, exportDir):
        """ Add a new export destination to the chain of exports """
        self.exportDestinations.append(exportDir)

    def __getitem__(self, name):
        """ To support direct dictionary like access """

        return self.getProperty(name)

    def __setitem__(self, name, value):
        """ To support direct dictionary like access """

        self.setProperty(name, value)

    def __getattr__(self, name):
        """Look up keys"""

        # Look up first in the local dictionary
        if hasattr(self.properties._props, name):
            return getattr(self.properties._props, name)

        # Look up in the global dictionarya
        if hasattr(globalVariables._props, name):
            return getattr(globalVariables._props, name)


    def __str__(self):
        return '[' + self.path + ', ' + str(self.properties) + ', ' \
            + str(self.exportDestinations) + ']'
#         return '[' + self.path + ', ' \
#             + str(self.exportDestinations) + ']'

    def getSubrecursiveDirs(self):
        # If the property is present return the tokenized list
        if self.properties.has_key('subrecursive.dirs'):
            return map(os.path.abspath,
                       self.properties['subrecursive.dirs'].split())

        # No definition, empty list
        return []

    def getSubrecursiveDirsNodst(self):
        # If the property is present return the tokenized list
        if self.properties.has_key('subrecursive.dirs.nodst'):
            return map(os.path.abspath,
                       self.properties['subrecursive.dirs.nodst'].split())

        # No definition, empty list
        return[]

    def isCorrectVersion(self):
        """
        Checks the values of ada.version against ada.exact.version,
        ada.minimum.version or ada.maximum.version.

        Return true if the version is allowed.
        """
        # TO BE IMPLEMENTED
        pass

    def __setAdaCourseHome(self):
        """
        Sets the value of ada.course.home by searching for a given file 10
        levels up in the hierarchy
        """
        # Go up to 10 levels searching for AdaCourseParams.xml
        point = self.path;
        depth = 0
        max = 10
        while depth < max:
            if os.path.exists(os.path.join(point, 'AdaCourseParams.xml')):
                self.properties['ada.course.home'] = \
                    os.path.join(os.path.abspath(point), '')
                return
            depth = depth + 1
            point = os.path.join(point, '..')

        self.properties['ada.course.home'] = os.path.join('.', '')

if __name__=="__main__":
    p = Directory(os.getcwd())
    if p.has_key('testing'):
        print 'Got Testing'
    print "Key Testing = " + p['testing']
    if p['testing'] == '':
        print "No attribute for key testing"
