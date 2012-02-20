#!/usr/bin/env python
# -*- coding: UTF-8 -*-#
#
# Copyright (C) 2010 Carlos III University of Madrid
# This file is part of Adagio: Agile Distributed Authoring Integrated Toolkit

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
import os, re, glob, sys, subprocess, shutil, ConfigParser, datetime
import urlparse

# Import conditionally either regular xml support or lxml if present
try:
    from lxml import etree
except ImportError:
    import xml.etree.ElementTree as etree

import adagio, i18n, dependency, properties

def getFilesToProcess(rule, dirObj):
    """
    Get the files to process by expanding the expressions in "files" and
    concatenating the src_dir as prefix.
    """

    # Safety guard, if srcFiles is empty, no need to proceed. Silence.
    srcFiles = dirObj.getProperty(rule, 'files').split()
    if srcFiles == []:
        adagio.logDebug(rule, dirObj, i18n.get('no_file_to_process'))
        return []

    srcDir = dirObj.getProperty(rule, 'src_dir')
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

def doExecution(rule, dirObj, command, datafile, dstFile,
                stdout = None, stderr = None, stdin = None):
    """
    Function to execute a program using the subprocess.Popen method. The three
    channels (std{in, out, err}) are passed directly to the call.
    """

    # Check for dependencies if dstFile is given
    if dstFile != None:
        srcDeps = set(dirObj.option_files)
        if datafile != None:
            srcDeps.add(datafile)

        try:
            dependency.update(dstFile, srcDeps)
        except etree.XMLSyntaxError, e:
            print i18n.get('severe_parse_error').format(fName)
            print str(e)
            sys.exit(1)

        # If the destination file is up to date, skip the execution
        if dependency.isUpToDate(dstFile):
            print i18n.get('file_uptodate').format(os.path.basename(dstFile))
            return
        # Notify the production
        print i18n.get('producing').format(os.path.basename(dstFile))
    else:
        if datafile != None:
            print i18n.get('processing').format(os.path.basename(datafile))
        else:
            print i18n.get('processing').format(os.path.basename(dirObj.current_dir))

    adagio.logDebug(rule, dirObj, 'Popen: ' + ' '.join(command))

    try:
        pr = subprocess.Popen(command, stdin = stdin, stdout = adagio.userLog,
                              stderr = stderr)
        pr.wait()
    except Exception, e:
        print i18n.get('severe_exec_error').format(command[0])
        print i18n.get('exec_line').format(' '.join(command))
        print e
        sys.exit(1)

    # If dstFile is given, update dependencies
    if dstFile != None:
        # If dstFile does not exist, something went wrong
        if not os.path.exists(dstFile):
            print i18n.get('severe_exec_error').format(command[0])
            sys.exit(1)

        # Update the dependencies of the newly created file
        try:
            dependency.update(dstFile)
        except etree.XMLSyntaxError, e:
            print i18n.get('severe_parse_error').format(fName)
            print str(e)
            sys.exit(1)

    return

def evaluateCondition(rule, options):
    """
    Evaluates the following condition with the given options (conjunction)

    1) option "enable_open" is '1'
    2) option "enable_begin" is empty or is a datetime before now
    3) option "enable_end" is empty or is a datetime past now
    4) If "adagio.enabled_profiles" is empty or contains the value of option
    "rule.enable_profile"

    The function returns the conjunction of these 5 rules.
    """

    # Check part 1 of the rule: open must be 1
    if properties.getProperty(options, rule, 'enable_open') != '1':
        print i18n.get('enable_not_open').format(openData)
        return False

    # Get current date/time
    now = datetime.datetime.now()

    # Get the date_format
    dateFormat = properties.getProperty(options, rule, 'enable_date_format')

    # Check part 2 of the rule: begin date is before current date
    beginDate = properties.getProperty(options, rule, 'enable_begin')
    if beginDate != '':
        if checkDateFormat(beginDate, dateFormat) < now:
            print i18n.get('enable_closed_begin').format(beginDate)
            return False

    # Check part 3 of the rule: end date is after current date
    endDate = properties.getProperty(options, rule, 'enable_end')
    if endDate != '':
        if now < checkDateFormat(endDate, dateFormat):
            print i18n.get('enable_closed_end').format(endDate)
            return False

    # Check part 4 of the rule: rule.enable_profile must be in
    # adagio.enabled_profiles
    revisionsData = properties.getProperty(options, 'adagio', 'enabled_profiles')
    thisRevision = properties.getProperty(options, rule, 'enable_profile')
    if revisionsData != '' and thisRevision != '':
        if not (thisRevision in set(revisionsData.split())):
            print i18n.get('enable_not_revision').format(rule,
                                                         thisRevision,
                                                         revisionsData)
            return False

    return True

def checkDateFormat(d, f):
    """
    Check if the date d is compliant with the format f. If not, terminate with a
    message.

    Returns the datetime object with the date
    """
    try:
       result = datetime.datetime.strptime(d, f)
    except ValueError, e:
       print i18n.get('date_incorrect_format').format(d, f)
       print str(e)
       sys.exit(1)

    return result

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

class XMLResolver(etree.Resolver):
    """
    Resolver to use with XSLT stylesheets and force the detection of stylesheets
    in the Adagio home directory. Only URLs starting with "file://" or absolute
    paths are processed.

    If the URL points to a file that does not exist, it is redirected to point
    to the directory of Adagio_Styles included in Adagio.
    """
    def __init__(self, paths = None):
        if paths == None:
	    paths = []

        # list of directories where to look for any URL in Adagio
        paths.append(os.path.join(adagio.home, 'Adagio_Styles'))
        self.dirList = paths

    def resolve_file(self, file_name):
        """
        Given a file name, see if it exists in any of the paths included
        in the dirList variable.
        """

        fname = os.path.normpath(file_name)

        # If the path starts with a backslash, it has just been normalized
        # and it is a windows absolute path, thus, it should have the drive
        # letter. Remove the first character.
        if fname[0] == '\\':
            fname = fname[1:]

        # If the file exist as given, return
        if os.path.exists(fname):
	    # print '222', fname
	    return fname

        # If given an abs path, we don't try any prefixes
	# if os.path.isabs(fname):
	#    print '333', file_name
	#    return None

        # The given path is relative and not found directly. Try the values in
        # dirList
        for dir_prefix in self.dirList:
	    # print '111', dir_prefix
            try_file = os.path.join(dir_prefix, os.path.basename(fname))
            if os.path.exists(try_file):
	        # File found in one of the dirs, terminate loop
                return try_file

        return None

    def resolve(self, url, pubid, context):
        newURL = url
        result = None

	# Parse URL to determine which kind of resource referred
        url_chunks = urlparse.urlparse(url)

        # Resolver intervenes only if a file URL is given
        if url_chunks.scheme == 'file' or url_chunks.scheme == '':

	    file_name = self.resolve_file(url_chunks.path)

	    if file_name == None:
		# Nothing found, leave untouched
                result = self.resolve_filename(newURL, context)
            else:
		# File found, resolve as file URL
                result = self.resolve_filename('file://' + file_name, context)

        return result
