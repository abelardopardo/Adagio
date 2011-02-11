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
#
import os, re, glob, sys, subprocess, shutil, ConfigParser, pydoc, datetime

# Import conditionally either regular xml support or lxml if present
try:
    from lxml import etree
except ImportError:
    import xml.etree.ElementTree as etree

import i18n, dependency, properties

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

def locateFile(fileName, dirPrefix = None):
    """Search an stylesheet in the dirs in local ADA dirs"""

    if dirPrefix == None:
        dirPrefix = os.getcwd()

    absName = os.path.abspath(os.path.join(dirPrefix, fileName))

    # If it exists in the given dir, return
    if os.path.exists(absName):
        return absName

    localAdaStyle = os.path.join(Ada.home, 'ADA_Styles', fileName)

    if os.path.exists(localAdaStyle):
        return os.path.abspath(localAdaStyle)

    return None

def getFilesToProcess(target, directory):
    """
    Get the files to process by expanding the expressions in "files" and
    concatenating the src_dir as prefix.
    """

    # Safety guard, if srcFiles is empty, no need to proceed. Silence.
    srcFiles = directory.getProperty(target, 'files').split()
    if srcFiles == []:
        Ada.logDebug(target, directory, i18n.get('no_file_to_process'))
        return []

    srcDir = directory.getProperty(target, 'src_dir')
    toProcess = []
    for srcFile in srcFiles:
        found = glob.glob(os.path.join(srcDir, srcFile))

        # Something was given in the variable, but nothing was found. Warn the
        # user but proceed.
        if found == []:
            print i18n.get('file_not_found').format(srcFile)
            # Exiting here sometimes is needed (i.e. when searching for a source
            # file to process) and sometimes it's ok (i.e. when searching for
            # files to export). There should be a boolean to select either
            # behavior
            # sys.exit(1)

        toProcess.extend(found)

    return toProcess

def doExecution(target, directory, command, datafile, dstFile,
                stdout = None, stderr = None, stdin = None):
    """
    Function to execute a program using the subprocess.Popen method. The three
    channels (std{in, out, err}) are passed directly to the call.
    """

    # Check for dependencies if dstFile is given
    if dstFile != None:
        srcDeps = directory.option_files
        if datafile != None:
            srcDeps.add(datafile)

        try:
            Dependency.update(dstFile, set(srcDeps))
        except etree.XMLSyntaxError, e:
            print i18n.get('severe_parse_error').format(fName)
            print str(e)
            sys.exit(1)

        # If the destination file is up to date, skip the execution
        if Dependency.isUpToDate(dstFile):
            print i18n.get('file_uptodate').format(os.path.basename(dstFile))
            return
        # Notify the production
        print i18n.get('producing').format(os.path.basename(dstFile))
    else:
        if datafile != None:
            print i18n.get('processing').format(os.path.basename(datafile))
        else:
            print i18n.get('processing').format(os.path.basename(directory.current_dir))

    Ada.logDebug(target, directory, 'Popen: ' + ' '.join(command))

    try:
        pr = subprocess.Popen(command, stdin = stdin, stdout = Ada.userLog,
                              stderr = stderr)
        pr.wait()
    except:
        print i18n.get('severe_exec_error').format(command[0])
        print i18n.get('exec_line').format(' '.join(command))
        sys.exit(1)

    # If dstFile is given, update dependencies
    if dstFile != None:
        # If dstFile does not exist, something went wrong
        if not os.path.exists(dstFile):
            print i18n.get('severe_exec_error').format(command[0])
            sys.exit(1)

        # Update the dependencies of the newly created file
        try:
            Dependency.update(dstFile)
        except etree.XMLSyntaxError, e:
            print i18n.get('severe_parse_error').format(fName)
            print str(e)
            sys.exit(1)

    return

def evaluateCondition(target, options):
    """
    Evaluates the following condition with the given options (conjunction)

    1) option "enable_open" is '1'
    2) option "enable_begin" is empty or is a datetime before now
    3) option "enable_end" is empty or is a datetime past now
    4) If "ada.enabled_profiles" is empty or contains the value of option
    "target.enable_profile"

    The function returns the conjunction of these 5 rules.
    """

    # Check part 1 of the rule: open must be 1
    if Properties.getProperty(options, target, 'enable_open') != '1':
        print i18n.get('enable_not_open').format(openData)
        return False

    # Get current date/time
    now = datetime.datetime.now()

    # Get the date_format
    dateFormat = Properties.getProperty(options, target, 'enable_date_format')

    # Check part 2 of the rule: begin date is before current date
    beginDate = Properties.getProperty(options, target, 'enable_begin')
    if beginDate != '':
        if checkDateFormat(beginDate, dateFormat) < now:
            print i18n.get('enable_closed_begin').format(beginDate)
            return False

    # Check part 3 of the rule: end date is after current date
    endDate = Properties.getProperty(options, target, 'enable_end')
    if endDate != '':
        if now < checkDateFormat(endDate, dateFormat):
            print i18n.get('enable_closed_end').format(endDate)
            return False

    # Check part 4 of the rule: target.enable_profile must be in
    # ada.enabled_profiles
    revisionsData = Properties.getProperty(options, 'ada', 'enabled_profiles')
    thisRevision = Properties.getProperty(options, target, 'enable_profile')
    if revisionsData != '' and thisRevision != '':
        if not (thisRevision in set(revisionsData.split())):
            print i18n.get('enable_not_revision').format(target)
            return False

    return True

def dumpOptions(target, directory, prefix):
    """
    Dump the value of the options affecting the computations
    """

    global options

    print i18n.get('var_preamble').format(prefix)

    # Remove the .dump from the end of the target to fish for options
    target = re.sub('\.?dump$', '', target)
    if target == '':
        target = prefix

    for (on, ov) in sorted(directory.options.items(target)):
        print ' -', on, '=', ov

def which(program):
    """
    Function to search if an executable is available in the machine. Lifted from
    StackOverflow.
    """
    def is_exe(fpath):
        return os.path.exists(fpath) and os.access(fpath, os.X_OK)

    fpath, fname = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file

    return None

def remove(fileName):
    """
    Function that checks if a file exists, and if so, removes it.
    """
    if os.path.exists(fileName):
        if os.path.basename(fileName) == fileName:
            print i18n.get('removing').format(fileName)
        else:
            prefix = i18n.get('removing')
            print prefix.format(fileName[len(prefix) - 3 - 80:])

        # If the given fileName is a file, simply remove it
        if os.path.isfile(fileName):
            os.remove(fileName)
            return

        # If a directory, nuke the entire tree
        shutil.rmtree(fileName)
        
    return

def optionDoc(options):
    """
    Function that given a list of triplets (variable, default_value,
    documentation) creates a Docbook snippet with the documentation about the
    variables.
    """
    
    result = """<informaltable frame="all">
  <tgroup rowsep="1" colsep="1" cols="3">
    <colspec colnum="1" colname="col1" align="left"></colspec>
    <colspec colnum="2" colname="col2" align="left"></colspec>
    <colspec colnum="3" colname="col3" align="center"></colspec>
    <thead>
      <row>
        <entry align="center">Name</entry>
        <entry align="center">Description</entry>
        <entry align="center">Default value</entry>
      </row>
    </thead>
    <tbody>"""

    for vname, vdefault, vdoc in options:
        result += """      <row>
        <entry><varname>""" + vname + """</varname></entry>
        <entry>""" + vdoc + """</entry>
        <entry>"""
        if vdefault == '':
            result += '(empty)'
        else:
            result += vdefault

        result += """</entry>
      </row>"""

    result += """    </tbody>
  </tgroup>
</informaltable>"""

    return result

class StyleResolver(etree.Resolver):
    """
    Resolver to use with XSLT stylesheets and force the detection of stylesheets
    in the ADA home directory
    """
    def __init__(self):
        self.styleDir = 'file://' + os.path.join(Ada.home, 'ADA_Styles')

    def resolve(self, url, pubid, context):
        if url.startswith('file://') or url.startswith('/'):
            if url.startswith('file://'):
                url = url[7:];
            if not os.path.exists(url):
                newURL = os.path.join(self.styleDir, os.path.basename(url))
                return self.resolve_filename(newURL, context)

