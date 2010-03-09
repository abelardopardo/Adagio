#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.padro@uc3m.es)
#
#
#
import sys, os, re, datetime

import Ada, I18n, Xsltproc, Config

def isDefinitionLegal(name, value):
    """
    Function to check if the assignment name = value is legal. An assignment is
    legal when:

    - name has a correct variable name

    - value is of the right type (if any enforced)

    - It is in the options dictionary.

    The function returns a boolean
    """
    return True

def Execute(target, dirLocation):
    """
    Given a target and a directory, it checks which rule needs to be invoked and
    performs the invokation.
    """

    # Obtain the name of the section and subsection if any
    (sect, subsect, m) =Config.getSectionNameFromPropertyName(target)

    # Select the proper set of rules
    if sect == Xsltproc.rule_prefix:
        Xsltproc.Execute(target, dirLocation)
    elif sect == Ada.rule_prefix:
        Ada.Execute(target, dirLocation)
    else:
        print I18n.get('illegal_target_prefix').format(sect)

# Function to ask for a value in the options a given option table
def getOption(prefix, name, table = None):
    """
    Return the first value of the pair found after lookup. First check the given
    table. If nothing given, traverse all the available dictionaries.
    """
    if table != None:
        return table[name][0]

    if prefix == Ada.rule_prefix:
        return Ada.options[name][0]
    elif prefix == Xsltproc.rule_prefix:
        return Xsltproc.options[name][0]

    raise NameError, I18n.get('option') + ' ' + prefix + '.' + name + \
        ' ' + I18n.get('not_found') + '.'

def setOption(prefix, name, value, table = None):
    pass

def fixedTargets(target, directory, rule_prefix, optionDict):
    """
    Given a target, a directory and a dictionary with options, checks if it is a
    reserved target and performs the appropriate task. If so, True is
    returned. If not, False is returned and nothing is done.
    """

    (a, b, c) = Config.splitVarName(target)
    targetSuffix = c
    targetPrefix = a
    if b != None:
        targetPrefix = targetPrefix + '.' + b

    if targetSuffix == '_show_options':
        print '---- ' + rule_prefix + ': ' + I18n.get('options') + ' ----'
        for a in sorted(optionDict.keys()):
            print '* ' + a + ': ' + str(directory.get(targetPrefix + '.' + a))
        print '----'
        return True
    elif targetSuffix == '_help_options':
        print '---- ' + rule_prefix + ': ' + I18n.get('options') + ' ----'
        for (a, (b, c)) in sorted(optionDict.items()):
            print '* ' + a + ' (Value: ' + str(directory.get(targetPrefix + '.' + a)) + ')'
            print '  ' + str(c)
        print '----'
        return True

    return False

def main():
    (status, n) = Config.Parse(sys.argv[1], None, SetOption)

    print str(status) + ', ' + str(n)
    for s in __sectionList:
        for k, v in sorted([(k, v) for k, v in __options.items() \
                            if k.startswith(s + '.')]):
            print k + ': ' + str(v)

if __name__=="__main__":
    main()
