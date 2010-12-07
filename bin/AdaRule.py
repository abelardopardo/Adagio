#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#
import os, re, glob, sys, subprocess

# Import conditionally either regular xml support or lxml if present
try:
    from lxml import etree
except ImportError:
    import xml.etree.ElementTree as etree

import Ada, I18n, Dependency

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

    # Safety guard, if srcFiles is empty, no need to proceed. Silence.
    srcFiles = directory.getWithDefault(target, 'files').split()
    if srcFiles == []:
        Ada.logDebug(target, directory, I18n.get('no_file_to_process'))
        return []

    srcDir = directory.getWithDefault(target, 'src_dir')
    toProcess = []
    for srcFile in srcFiles:
        found = glob.glob(os.path.join(srcDir, srcFile))

        # Here we might have a problem. Something was given in the variable, but
        # nothing was found. Bomb out, user should fix this
        if found == []:
            print I18n.get('file_not_found').format(srcFile)
            sys.exit(1)

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
            print I18n.get('severe_parse_error').format(fName)
            print e
            sys.exit(1)

        # If the destination file is up to date, skip the execution
        if Dependency.isUpToDate(dstFile):
            print I18n.get('file_uptodate').format(os.path.basename(dstFile))
            return
        # Notify the production
        print I18n.get('producing').format(os.path.basename(dstFile))
    else:
        print I18n.get('producing').format(os.path.basename(datafile))

    Ada.logDebug(target, directory, 'Popen: ' + ' '.join(command))

    try:
        pr = subprocess.Popen(command, stdin = stdin, stdout = Ada.userLog,
                              stderr = stderr)
        pr.wait()
    except:
        print I18n.get('severe_exec_error').format(command[0])
        print I18n.get('exec_line').format(' '.join(command))
        sys.exit(1)

    # If dstFile is given, update dependencies
    if dstFile != None:
        # If dstFile does not exist, something went wrong
        if not os.path.exists(dstFile):
            print I18n.get('severe_exec_error').format(command[0])
            sys.exit(1)

        # Update the dependencies of the newly created file
        try:
            Dependency.update(dstFile)
        except etree.XMLSyntaxError, e:
            print I18n.get('severe_parse_error').format(fName)
            print e
            sys.exit(1)

    return

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

def remove(fileName):
    """
    Function that checks if a file exists, and if so, removes it.
    """
    if os.path.exists(fileName):
        if os.path.basename(fileName) == fileName:
            print I18n.get('removing').format(fileName)
        else:
            prefix = I18n.get('removing')
            print prefix.format(fileName[len(prefix) - 3 - 80:])
        os.remove(fileName)
        
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

################################################################################
# OLD
################################################################################

            # Sequence of rules to apply
# DONE            Gotodir.process(executionContext[dirName], cmdName)

# DONE            Copyfiles.process(executionContext[dirName], cmdName)

# NONE            Copytemplates.process(executionContext[dirName], cmdName)

# NONE            Xfig.process(executionContext[dirName], cmdName)

# DONE            Inkscape.process(executionContext[dirName], cmdName)

# DONE            Gimp.process(executionContext[dirName], cmdName)

# DONE            Convert.process(executionContext[dirName], cmdName)

# DONE            Xsltproc.process(executionContext[dirName], cmdName)

# DONE            ExerciseSubmit.process(executionContext[dirName], cmdName)

# DONE            Exam.process(executionContext[dirName], cmdName)

# DONE            TestExam.process(executionContext[dirName], cmdName)

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

# extraant.posttarget
# extraant.posttarget.clean

# mergestyles.master.style

# msf2pdf.files
# ppt2pdf.files
#
# LINUX
# soffice -norestore -nofirststartwizard -nologo -headless -pt PDF sample.ppt
# Params: printer name, executable 
#
# WINDOWS
# soffice -norestore -nofirststartwizard -nologo -headless -pt PDFCreator sample.ppt
# 

# rsync.destination
# rsync.source

# position
# project
# session
# unit
