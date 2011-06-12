Adagio: Agile Distributed Authoring Integrated Toolkit
======================================================

* Author:   Abelardo Pardo <abelardo.pardo@uc3m.es>
* Website:   <http://www.it.uc3m.es/abel/Adagio/FAQ.html>
* GitHub:    <https://github.com/abelardopardo/Adagio>

This free software is copyleft licensed under the version 2 of the GPL license.

Adagio is a rule-based program (similar to "make") that given a file
containing a set of rules, it automatically executes them. Given a directory
and a set of rules, a new set of files are created by applying the rules
automatically.

The rules are all included in a file with name {0}. The file is
written in INI format. A rule is defined with a name in brackets at the
begining of a line. Each rule has a set of name = value assignments.

The script visits the current directory and process the rule file included
in that directory. If no rule is given when invoking adagio, all of the
rules in the file are executed.

Usage:
------

The script accepts the following options:

  `-c filename`: File containing the rule (default {0})

  `-d num`: Debugging level. Used to control the amount of messages
   dumped. Possible values are:

          CRITICAL/FATAL = 5
          ERROR =          4
          WARNING =        3
          INFO =           2
          DEBUG =          1
          NOTSET =         0

  `-f path_to_rule_file`: Given a path to a rule file, execute ADA in the
   directory where that file is, and with the given file as the rule file

  `-h`: Shows this message

  `-p`: Partial execution. Proceed even if some tools are not
      installed. Otherwise stop execution in the first missing tool.

  `-s 'rule name value'`: Executes the application by first storing in the
                   environment the assignment name = value as part of a
                   rule. This means that, unless overwritten by definitions
                   in the properties file, this assignment will be visible
                   to all the rules executed.

  `-x`: Shows this message

Rules:
------

Adagio processes the following rules. For each of them a more detailed
description can be obtained by executing the adagio with the rule
"rulename.help" (where rulename is any of the following):

* convert: Convert, resize, crop images in different formats.

* dblatex: Executes dblatex over a set of Docbook files to translate them
  to LaTeX

* dvips: Executes dvips over a set of given DVI files

* exam: Typeset a Docbook file with a specific format into an exam.

* exercise: Typeset a Docbook file and produce a hand out for students and
  (optionally) a solution document, professor guide, and submission form.

* export: Copy a set of files from a source directory to a (possibly given
  from other execution) destination directory. The copy is executed if a
  set of conditions are fullfilled.

* filecopy: Copy files from a source directory.

* gimp: Transform all files in format *.xcf to PNG.

* gotodir: Invoke the execution of Adagio in a different directory
  (recursively).

* inkscape: Transform a SVG file created by Inkscape into PNG, EPS, PS or
  PDF

* latex: Execute LaTeX over a set of give *.tex files.

* office2pdf: Produce a PDF file from a given set of Office files (Word or
  PowerPoint).

* pdfnup: Execute pdfnup over a set of PDF files to create n-up handouts.

* rsync: Executes rsync to synchronize a source and a destination dir.

* script: Executes an extra rule given as a Python script.

* testexam: Typesets a Docbook document in a special format containing a
  set of multiple choice tests into an HTML document. The rule shuffles
  the questions and creates several versions.

* xfig: Transform figures created with xfig into PNG format.

* xsltproc: Applies a XSL style sheet to a given XML file.

If you execute adagio with a single parameter made of a rule name followed
by the suffix ".help" it provides a more detailed description of the
operations contained in the rule.

Contributors:
-------------

* Abelardo Pardo, alias (https://github.com/abelardopardo)
* Jesús Árias Fisteus


