#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.padro@uc3m.es)
#
#
#
import sys, os, re

import Config, Rule

# Dictionary supplying the default values for a bunch of variables
defaultOptions = {
    # Current date/time
    'ada.current_datetime': (str(datetime.datetime.now()),
                             I18n.get('ada_current_datetime')),
    # Profile revision passed to Docbook
    'ada.profile_revision': (None,
                             I18n.get('ada_profile_revision')),
    # Minimum version number required
    'ada.minimum_version': (None,
                            I18n.get('ada_minimum_version')),
    # Maximum version number required
    'ada.maximum_version': (None,
                            I18n.get('ada_maximum_version')),
    # Exact version required
    'ada.exact_version': (None,
                          I18n.get('ada_exact_version')),
    }

# Load up all the options in the rule files
loadOptions('xslt', Xsltproc.options)

def loadOptions(prefix, options):
    """
    Upload the variable definitions in the defaultOptions dictionary
    """

    # Loop over all the triples. Insert key, and value = (default, help message)
    for (name, value, helpstr) in options:
        Properties.defaultOptions[prefix + '.' + name] = (value, htlpstr)


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
