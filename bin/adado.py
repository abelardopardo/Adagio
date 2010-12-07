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
import os, sys, getopt, datetime, locale, ConfigParser, codecs

import Ada, I18n, Properties, Directory
# import Ada, Directory, I18n, Xsltproc

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
    optionsToSet = []
    partial = 0

    # Swallow the options
    try:
        opts, args = getopt.getopt(sys.argv[1:], "c:d:s:hxp", [])
    except getopt.GetoptError, e:
        print e.msg
        print I18n.get('__doc__')
        sys.exit(2)

    # Parse the options
    for optstr, value in opts:
        # Debug option
        if optstr == "-c":
            Ada.config_defaults['property_file'] = value

        elif optstr == "-d":
            # An integer is required
            try:
                numValue = int(value)
            except ValueError, e:
                print I18n.get('incorrect_debug_option')
                sys.exit(3)
            Ada.config_defaults['debug_level'] = value

        # Dump the manual page
        elif optstr == "-h" or optstr == "-x":
            print I18n.get('__doc__')
            sys.exit(3)

        # Allow for partial execution (if some tools are missing
        elif optstr == "-p":
            Ada.config_defaults['partial'] = '1'

        # Set a value in the environment
        elif optstr == "-s":
            sname_value = value.split()
            # If incorrect number of arguments, stop processing
            if len(sname_value) != 3:
                print I18n.get('incorrect_arg_num').format('-s option')
                print I18n.get('__doc__')
                sys.exit(3)
            optionsToSet.append(' '.join(sname_value))

    # Invoke a function that traverses the options and checks that they have the
    # right type (integers, floats, date/time, et.
    pass # TO BE IMPLEMENTED

    # The rest of the arguments are the targets
    targets = args

    # Print Reamining arguments. If none, just stick the current dir
    Ada.logDebug('main', None, 'Targets: ' + ' '.join(targets))

    #######################################################################
    #
    # MAIN PROCESSING
    #
    #######################################################################

    # Create the directory
    dirObject = Directory.getDirectoryObject(os.getcwd(),
                                             sorted(optionsToSet))
        
    # Execute its targets
    try:
        dirObject.Execute(targets)
    except KeyboardInterrupt:
        sys.exit(1)

    #######################################################################
    #
    # Termination
    #
    #######################################################################
    Ada.finish()

# Execution as script
if __name__ == "__main__":
    main()
