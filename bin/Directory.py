#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import sys, os, re, logging, ConfigParser, ordereddict

import Ada, Config, Properties, I18n, Xsltproc

# Set the logger for this module
logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger('directory')

# Table to store tuples:
#   path: Directory object
#
# to avoid executing twice the same directory (cache)
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
            logger.debug('Directory HIT: ' + path)
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

    # previous_dir:     dir before switching to the given one
    # current_dir:      dir represented by this object
    # givenOptions:     list of options given from outside this dir
    # options:          dictionary with the options read from the Properties.txt
    # section_list:     targets in the Properties.txt file
    # current_section:  section being processed
    # executing:        true if in the middle of the "Execute" method
    # executed_targets: set of targets executed with empty given directory

    # Change to the given dir and initlialize fields
    def __init__(self, path=os.getcwd(), givenOptions = []):

        logger.info('New dir object in ' + path)

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

        # Change current directory to this directory
        os.chdir(self.current_dir)

        # Nuke the adado.log file
        logFile = os.path.join(os.getcwd(), 'adado.log')
        if os.path.exists(logFile):
            os.remove(logFile)

        # Safe parser to store the options
        self.options = ConfigParser.SafeConfigParser(Ada.config_defaults,
                                                     ordereddict.OrderedDict)

        #
        # STEP 1: Set ada.home in global options
        #
        self.options.add_section(Ada.module_prefix)
        self.options.set(Ada.module_prefix, 'home', Ada.home)
        logger.debug('ada.home = ' + Ada.home)

        #
        # STEP 2: Load the default options from the Rule files
        #
        Properties.loadOptionsInConfig(self.options, Ada.module_prefix, Ada.options)
        Properties.loadOptionsInConfig(self.options, Xsltproc.module_prefix,
                                       Xsltproc.options)

        #
        # STEP 3: Load the $HOME/.adarc if any
        #
        userAdaConfig = os.path.join(os.environ.get('HOME'), '.adarc')
        if os.path.isfile(userAdaConfig):
            logger.debug('Sourcing ' + userAdaConfig)
            # Swallow user file on top of global options, and if trouble, report
            # up
            if Properties.loadConfigFile(self.options, userAdaConfig):
                sys.exit(1)

        #
        # STEP 4: Options given from outside the dir
        #
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
            except ConfigParser.NoSectionError:
                sys.exit(3)
        #
        # STEP 5: Options given in the config file in the directory
        #
        adaPropFile = self.options.get('ada', 'property_file')
        if not os.path.exists(adaPropFile):
            logger.info('No ' + adaPropFile + ' found in ' + self.current_dir)
            print I18n.get('cannot_find_properties').format(adaPropFile,
                                                            self.current_dir)
            sys.exit(3)
        propAbsFile = os.path.abspath(os.path.join(self.current_dir,
                                                   adaPropFile))
        logger.debug('Parsing ' + propAbsFile)
        if Properties.loadConfigFile(self.options, propAbsFile):
            sys.exit(3)

        #
        # STEP 6: Options given in the config file in the directory
        #
        adaProjFile = self.findProjectFile()
        if adaProjFile != None:
            logger.debug('Parsing ' + adaProjFile)
            if Properties.loadConfigFile(self.options, adaProjFile):
                sys.exit(3)

        # Compare ADA versions to see if execution is allowed
        if not self.isCorrectAdaVersion():
            version = self.options.get(Ada.module_prefix, 'version')
            logger.error('ERROR: Incorrect Ada Version (' + version + ')')
            print I18n.get('incorrect_version').format(version)
            sys.exit(3)

        self.current_section = None
        self.section_list = self.options.sections()
        # Dump a debug message showing the list of sections detected in the
        # config file
        logger.debug('Sections: ' + ', '.join(self.section_list))

        return

    def __del__(self):
        """
        Object no longer needed, so change the directory again
        """
        os.chdir(self.previous_dir)
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

    def Execute(self, targets = []):
        """
        Properties.txt has been parsed into a ConfigParse. Loop over the targets
        and execute all of them.
        """

        logger.info('Execute in ' + self.current_dir)

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
        if targets == []:
            targets = [x for x in self.section_list
                       if not re.match('^ada$', x) and
                          not re.match('^clean(\.?\S+)?$', x) and
                          not re.match('^local(\.?\S+)?$', x)]

        logger.debug('  Targets: ' + str(targets))

        # Loop over all the targets to execute
        for target_name in targets:

            # Check the cache to see if target has already been executed
            if target_name in self.executed_targets:
                logger.info('HIT: ' + self.current_dir + ': ' + target_name)
                continue

            # Execute the target
            Properties.Execute(target_name, self)

            # Insert executed target in cache
            self.executed_targets.add(target_name)

        self.executing = False
        logger.debug(' Executed Targets: ' + str(self.executed_targets))
        return

    # Search for .sc all the way up the hierarchy (until the top)
    def findProjectFile(self):
        """
        Function that traverses the directories upward until the file name given
        by the option ada.projectfile is found, None otherwise
        """

        pfile = self.options.get(Ada.module_prefix, 'project_file')

        currentDir = os.getcwd()
        while (currentDir != '/') and \
                (not os.path.exists(os.path.join(currentDir, pfile))):
            currentDir = os.path.abspath(os.path.join(currentDir, ".."))

        if currentDir == '/':
            return None

        adminDir = os.path.join(currentDir, pfile)

        return adminDir

################################################################################

if __name__=="__main__":
    logger.setLevel(10)
    p1 = Directory(os.getcwd())
    p1.Execute()

    p2 = Directory(os.getcwd())
