#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, logging, sys, getopt, datetime, locale

import Ada, Directory, I18n, Xsltproc

def main():
    """
    The manual page for this method is inside the localization package. Check
    the proper [ĺang].py file.
    """

    # Fix the output encoding when redirecting stdout
    if sys.stdout.encoding is None:
        (lang, enc) = locale.getdefaultlocale()
        if enc is not None:
            (e, d, sr, sw) = codecs.lookup(enc)
            # sw will encode Unicode data to the locale-specific character set.
            sys.stdout = sw(sys.stdout)

    #######################################################################
    #
    # Initialization of all the required variables
    #
    #######################################################################
    Ada.initialize()

    #######################################################################
    #
    # OPTIONS
    #
    #######################################################################
    targets = []
    directories = []
    givenDictionary = None

    # Swallow the options
    try:
        opts, args = getopt.getopt(sys.argv[1:], "d:s:t:",
                                   ["dir="])
    except getopt.GetoptError, e:
        print e.msg
        print I18n.get('__doc__')
        sys.exit(2)

    # Parse the options
    for optstr, value in opts:
        # Debug option
        if optstr == "-d":
            Ada.options['debug_level'] = (value, Ada.options['debug_level'][1])

        # Set a value in the environment
        elif optstr == "-s":
            name_value = value.split()
            # If incorrect number of arguments, stop processing
            if len(name_value) != 2:
                print I18n.get('incorrect_arg_num').format('-s option')
                print I18n.get('__doc__')
                sys.exit(2)
            # This option is stored in level B of the dictionary
            if not givenDictionary:
                givenDictionary = {}
            givenDictionary[name_value[0]] = name_value[1]

        # Set the targets
        elif optstr == "-t":
            # Extend the list of targets to process
            targets.extend(value.split())

    # Set the proper debug level
    logging.basicConfig(level=int(Ada.options['debug_level'][0]))

    # Turn targets into a set
    targets = set(targets)

    # Print Reamining arguments. If none, just stick the current dir
    logging.debug('Remaning args: ' + str(args))
    if args == []:
        directories = [os.getcwd()]
    else:
        directories = args

    #######################################################################
    #
    # MAIN PROCESSING
    #
    #######################################################################
    logging.info('ADA targets: ' + ' '.join(targets))

    # Remember the initial directory
    initialDir = os.getcwd()

    # Create the initial list of directories to process
    for currentDir in directories:

        # Move to the actual dir
        logging.info('INFO: Switching to ' + currentDir)
        os.chdir(currentDir)

        # Check if the cache already contains this directory
        dirObject = Directory.getDirectoryObject(currentDir)

        dirObject.Execute(targets, givenDictionary)

# Execution as script
if __name__ == "__main__":
    main()
