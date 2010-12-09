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
import os, sys, getopt, datetime, locale, re, codecs, ConfigParser

def main(dataFile):
    """
    File that takes the file given as the only parameter and tries to migrate to
    Properties.ini automatically. Script should be invoked:

    [script] Properties.txt

    ... and dumps content to stdout
    """

    # Fix the output encoding when redirecting stdout
    if sys.stdout.encoding is None:
        (lang, enc) = locale.getdefaultlocale()
        if enc is not None:
            (e, d, sr, sw) = codecs.lookup(enc)
            # sw will encode Unicode data to the locale-specific character set.
            sys.stdout = sw(sys.stdout)

    config = ConfigParser.SafeConfigParser()

    dataIn = open(dataFile, 'r')
    multiline = ''
    currentSection = ''
    # Loop over the data in
    for line in dataIn:
        # Ad-hoc for Progsys
        line = re.sub('^# See ada.home/AntImports/Properties.txt',
                      '# See %(home)s/bin/Properties.ini', line)

        # If line starts with #, pass it directly to output
        if line[0] == '#':
            print line,

        # Normalize space and remove comments
        line = comment_remover(line)
        line = re.sub('^[ \t]*|[ \t]*$', '', line)
        line = re.sub('[ \t]+', ' ', line)
        
        # Remove the final newline
        line = line[:-1]

        if line == '':
            continue

        # Take care of the multiline entries
        if line[-1] == '\\':
            multiline = multiline + line[:-1]
            continue

        if multiline != '':
            line = multiline + line
            multiline = ''

        # Change interpolation
        line = changeInterpolation(line)

        # Change variables
        # line = re.sub('AdaCourseParams', 'AdaProjectParams', line)

        # Split lines into fields
        fields = line.split('=')
        if len(fields) != 2:
            print 'Weird line:', line
            sys.exit(1)
            
        # Chop the name into fields separated by dot
        nameFields = fields[0].split('.')
        section = nameFields[0]
        subsection = '.'.join(nameFields[1:])

        transSection = translateSection(section, subsection)
        # See if we have changed the section
        if transSection != currentSection and section != 'mergestyles':
            if currentSection != '':
                print
            currentSection = transSection
            print '[' + currentSection + ']'
        
        # Fire cases:
        if subsection == 'files':
            print '        files =', fields[1]

        if subsection == 'src.dir':
            print '        src_dir =', fields[1]

        if subsection == 'dst.dir':
            print '        dst_dir =', fields[1]

        if subsection == 'style.file':
            print '        styles =', fields[1]

        if subsection.startswith('multilingual.file'):
            print '        files =', fields[1]
            print '        languages = en es'

        if section == 'mergestyles':
            for fname in fields[1].split():
                print '                ', fname, '# Mergestyles'

        if section == 'subrecursive' and subsection == 'dirs':
            print '        files =', fields[1]
            print '        export_dst = %(basedir)s'

        if section == 'subrecursive' and subsection == 'dirs.nodst':
            print '        files =', fields[1]

        if section == 'rsync':
            if subsection == 'source':
                print '        src_dir =', fields[1]
            if subsection == 'destination':
                print '        dst_dir =', fields[1]

def translateSection(sin, subs = None):
    """
    Sections have changed
    """

    if sin == 'xsltproc':
        return 'xslt'
    elif sin == 'subrecursive' and subs == 'dirs':
        return 'gotodir.export'
    elif sin == 'subrecursive' and subs == 'dirs.nodst':
        return 'gotodir.publish'
    elif sin == 'msf2pdf':
        return 'office2pdf'
    elif sin == 'copyfiles':
        return 'copy'
    elif sin == 'exercisesubmit':
        return 'exercise'
    
    return sin

def comment_remover(text):
    """
    Function to remove comments. Adapted from one published
    in stackoverflow.com courtesy of MizardX
    """
    # Function invoked every time a match is produced
    def replacer(match):
        s = match.group(0)
        if s.startswith('#') or s.startswith(';'):
            return ''
        else:
          return s
    # This is the key. Match not only the comment, but also strings surrounded
    # by double quotes
    pattern = re.compile(r'#.*?$|;.*?$|"(?:\\.|[^\\"])*"', \
                         re.DOTALL | re.MULTILINE)
    return re.sub(pattern, replacer, text)

def changeInterpolation(line):
    """
    Function that changes $(blah) by %(blah)s
    """

    def replacer(match):
        s = match.group(1)
        return '%(' + re.sub('ada\.course\.home', 'project_home', s) + ')s'

    pattern = re.compile(r'\$\{([^\)]+)\}', re.DOTALL)
    
    return re.sub(pattern, replacer, line)

# Execution as script
if __name__ == "__main__":
    main(sys.argv[1])

    
