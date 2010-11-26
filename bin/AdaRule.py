#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, re, glob, sys

# Import conditionally either regular xml support or lxml if present
try:
    from lxml import etree
except ImportError:
    import xml.etree.ElementTree as etree

import Ada, I18n

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

def locateFile(fileName, dirPrefix = os.getcwd()):
    """Search an stylesheet in the dirs in local ADA dirs"""

    absName = os.path.abspath(os.path.join(dirPrefix, fileName))

    # If it exists in the given dir, return
    if os.path.exists(absName):
        return absName

    localAdaStyle = os.path.join(Ada.home, 'ADA_Styles', fileName)

    if os.path.exists(localAdaStyle):
        return os.path.abspath(localAdaStyle)

    return None

def specialTargets(target, directory, documentation, prefix, 
                          clean_function = None, pad = None):
    """
    Check if the requested target is special:
    - dump
    - help
    - clean

    Return boolean stating if any of them has been executed
    """
    
    # Detect if any of the special target has been detected
    hit = False

    # Remember if it is one of the helpdump or dumphelp
    doubleTarget = re.match('(.+\.)?helpdump$', target) or \
        re.match('(.+\.)?dumphelp$', target)

    # If requesting help, dump msg and terminate
    if doubleTarget or re.match('(.+)?help$', target):
        msg = documentation[directory.getWithDefault(Ada.module_prefix, 
                                                     'locale')]
        if msg != None:
            print I18n.get('doc_preamble').format(prefix)
            print msg
        else:
            print I18n.get('no_doc_for_rule').format(prefix)
        hit = True

    # If requesting var dump, do it and finish
    if doubleTarget or re.match('(.+\.)?dump$', target):
        dumpOptions(target, directory, prefix)
        hit =  True

    # CLEAN
    if re.match('(.+\.)?clean$', target) and (clean_function != None):
        clean_function(re.sub('\.clean$', '', target), directory, pad)
        hit =  True

    return hit

def getFilesToProcess(target, directory):
    """
    Get the files to process by expanding the expressions in "files" and
    concatenating the src_dir as prefix.
    """
    srcDir = directory.getWithDefault(target, 'src_dir')
    toProcess = []
    for srcFile in directory.getWithDefault(target, 'files').split():
        toProcess.extend(glob.glob(os.path.join(srcDir, srcFile)))

    if toProcess == []:
        Ada.logDebug(target, directory, I18n.get('no_file_to_process'))

    return toProcess

def dumpOptions(target, directory, prefix):
    """
    Dump the value of the options affecting the computations
    """

    global options

    print I18n.get('var_preamble').format(prefix)

    # Remove the .dump from the end of the target to fish for options
    target = re.sub('\.?dump$', '', target)
    if target == '':
        target = prefix

    # Calculate default section if any
    defSection = target.split('.')
    if len(defSection) > 1:
        defSection = defSection[0]
    else:
        defSection = target

    for sn in directory.options.sections():
        if sn.startswith(target) or sn == defSection:
            for (on, ov) in sorted(directory.options.items(sn)):
                print ' -', sn + '.' + on, '=', ov

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

class StyleResolver(etree.Resolver):
    """
    Resolver to use with XSLT stylesheets and force the detection of stylesheets
    in the ADA home directory
    """
    def __init__(self):
        self.styleDir = 'file://' + os.path.join(Ada.home, 'ADA_Styles')

    def resolve(self, url, pubid, context):
        if url.startswith('file://'):
            url = url[7:];
            if not os.path.exists(url):
                newURL = os.path.join(self.styleDir, os.path.basename(url))
                return self.resolve_filename(newURL, context)

################################################################################
# OLD
################################################################################

def executeRuleChain(dirList, executionContext, commands):

    # If no commands are given, take run as the default
    if commands == []:
        commands = ['run']

    # Loop over all the directories
    for dirName, exportDst in dirList:
        Ada.infoMessage('BG ' + dirName)

        # Loop over the list of commands to apply
        for cmdName in commands:
            Ada.infoMessage('EN ' + dirName)

            # Sequence of rules to apply
# DONE            Gotodir.process(executionContext[dirName], cmdName)

# DONE            Copyfiles.process(executionContext[dirName], cmdName)

# NONE            Copytemplates.process(executionContext[dirName], cmdName)

# NONE            Xfig.process(executionContext[dirName], cmdName)

# DONE            Inkscape.process(executionContext[dirName], cmdName)

# DONE            Gimp.process(executionContext[dirName], cmdName)

# DONE            Convert.process(executionContext[dirName], cmdName)

# DONE            Xsltproc.process(executionContext[dirName], cmdName)

#             ExerciseSubmit.process(executionContext[dirName], cmdName)

#             Exam.process(executionContext[dirName], cmdName)

# ???            TestExam.process(executionContext[dirName], cmdName)

# NONE            Rss.process(executionContext[dirName], cmdName)

# NONE            Latex.process(executionContext[dirName], cmdName)

# NONE            Dvips.process(executionContext[dirName], cmdName)

# NONE            Ps2pdf.process(executionContext[dirName], cmdName)

# NONE            Pdflatex.process(executionContext[dirName], cmdName)

# DONE            Dblatex.process(executionContext[dirName], cmdName)

#             Msf2PDF.process(executionContext[dirName], cmdName)

# NONE            PDFnup.process(executionContext[dirName], cmdName)

#             ExtraAnt.process(executionContext[dirName], cmdName)

# DONE            Export.process(executionContext[dirName], cmdName)

#             WkHtmlToPDF ???

# clean.files

# convert.dst.dir
# convert.files
# convert.geometry

# copyfiles.dst.dir
# copyfiles.files
# copyfiles.src.dir

# dblatex.compliant.mode
# dblatex.extra.args
# dblatex.files

# exam.extra.args
# exam.multilingual.file

# exercisesubmit.extra.args
# exercisesubmit.files
# exercisesubmit.multilingual.files
# exercisesubmit.style.file

# export.dst.dir
# export.files

# exportcontrol.profile.revision.value

# extraant.posttarget
# extraant.posttarget.clean

# file.prefix

# gimp.files

# inkscape.files
# inkscape.output.format

# mergestyles.master.style

# msf2pdf.files

# ppt2pdf.files

# rsync.destination
# rsync.source

# gotodir.dirs
# gotodir.dirs.nodst

# testexam.extra.args
# testexam.file
# testexam.multilingual.file
# testexam.style.file

# xfig.files

# xsltproc.extra.args
# xsltproc.files
# xsltproc.multilingual.files
# xsltproc.output.format
# xsltproc.style.file

# position
# project
# session
# unit

    pass

if __name__ == "__main__":
    pass
