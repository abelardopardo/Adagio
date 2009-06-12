#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, glob
import Ada, Inkscape

def isProgramAvailable(executable):
    def is_exe(fpath):
        return os.path.exists(fpath) and os.access(fpath, os.X_OK)

    # First look at the given program name
    fpath, fname = os.path.split(executable)

    # If full path, check directly for execution permission
    if fpath:
        if is_exe(executable):
            return executable
    else:
        # Loop over the paths in PATH variable in environment
        for path in os.environ["PATH"].split(os.pathsep):
            exe_file = os.path.join(path, executable)
            if is_exe(exe_file):
                return exe_file

    return None

def expandFiles(dir, files):
    """Function that given a (possible empty) directory and a set of space separated
    list of file patterns, it returns a list of elements each of them is an
    absolute path to a file referred to by the given expressions"""

    # Trivial cases first, if files are empty, return
    if files == '':
        return []

    # Set dir to proper value, and make it an absolute path
    if dir == '':
        dir = os.getcwd()
    dir = os.path.abspath(dir)

    return [os.path.join(dir, srcFile) for srcFile in  files.split()]

def expandExistingFiles(dir, files):
    """Function that given a (possible empty) directory and a set of space separated
    list of file patterns, it returns a list of elements each of them is an
    absolute path to an EXISTING file referred to by the given expressions"""

    result = []
    for fPattern in expandFiles(dir, files):
        result = result + glob.glob(fPattern)

    return result

def executeRuleChain(dirList, executionContext, commands):

    # If no commands are given, take run as the default
    if commands == []:
        commands = ['run']

    # Loop over all the directories
    for dirName, exportDst in dirList:
        Ada.infoMessage('BG ' + dirName)

        # Loop over the list of commands to apply
        for cmdName in commands:

            # Sequence of rules to apply

            Inkscape.process(executionContext[dirName], cmdName)


        Ada.infoMessage('EN ' + dirName)
    pass

if __name__ == "__main__":
    pass
