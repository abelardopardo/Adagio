#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.padro@uc3m.es)
#
#
#
import sys, os, re

import Config, Rule.py

# Dictionary supplying the default values for a bunch of variables
defaultOptions = {
    }

# Load the dictionary with the default values by invoking every rule file and
# upload the default options
Rule.loadOptions(defaultOptions)

def loadOptions(prefix, options):
    """
    Upload the variable definitions in the defaultOptions dictioo
    """

def isDefinitionLegal(name, value):
    """
    Function to check if the assignment name = value is legal. An assignment is
    legal when:

    - name has a correct variable name

    - value is of the right type (if any enforced)

    - It is in the defaultOptions dictionary.

    The function returns a boolean
    """
    return True

def main():
    __sectionList = []
    __options['basedir'] = os.getcwd()
    __options['ada.home'] = os.getcwd()
    __options['file.separator'] = os.path.sep
    (status, n) = Config.Parse(sys.argv[1], None, SetOption)

    print str(status) + ', ' + str(n)
    for s in __sectionList:
        for k, v in sorted([(k, v) for k, v in __options.items() \
                            if k.startswith(s + '.')]):
            print k + ': ' + str(v)

if __name__=="__main__":
    main()
