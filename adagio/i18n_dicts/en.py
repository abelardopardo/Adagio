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

msgs = {
    'adagio.help': """

    adagio [options] [rule rule ....]

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

    The script accepts the following options:

      -c filename: File containing the rule (default {0})

      -d num: Debugging level. Used to control the amount of messages
       dumped. Possible values are:

              CRITICAL/FATAL = 5
              ERROR =          4
              WARNING =        3
              INFO =           2
              DEBUG =          1
              NOTSET =         0

      -f path_to_rule_file: Given a path to a rule file, execute ADA in the
       directory where that file is, and with the given file as the rule file

      -h: Shows this message

      -p: Partial execution. Proceed even if some tools are not
          installed. Otherwise stop execution in the first missing tool.

      -s 'rule name value': Executes the application by first storing in the
                       environment the assignment name = value as part of a
                       rule. This means that, unless overwritten by definitions
                       in the properties file, this assignment will be visible
                       to all the rules executed.

      -x: Shows this message

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

    """,
    # Explanations of the values in config_defaults
    'default_alias': 'Define a synonym for the current rule',
    'default_basedir': 'Current directory where the rules are being executed',
    'default_current_datetime': 'Date/time when the execution started',
    'default_debug_level': """Level of debug messages to appear in log file (0-5)
  The higher the value the more messages are written""",
    'default_dst_dir': 'Directory where the resulting files are created',
    'default_enable_begin': 'Date/time from which the rule must execute.',
    'default_enable_date_format': 'Format to specify the date/times for the enable',
    'default_enable_end': 'Date/time up to which the rule can execute.',
    'default_enable_open': 'Rule is allowed to execute',
    'default_enable_profile': 'Value authorizing the execution of the rule',
    'default_encoding': 'Encoding to use in the produced files',
    'default_file_separator': 'Separator used by the system in file paths',
    'default_files': 'Source files to use in a rule',
    'default_help': 'Documentation about what the rule does',
    'default_home': 'Directory where ADA is installed',
    'default_languages': """Space separated list of languages to consider when
    processing the files (when appropriate)""",
    'default_partial': """0/1 value stating if ADA continues when a rule cannot be 
    executed""",
    'default_project_file': 'File with project-wide declarations',
    'default_project_home': 'Directory where the project file is found',
    'default_property_file': 'File name with the rule definitions',
    'default_src_dir': 'Directory from where to take the source files',
    'default_version': 'Current ADA version',
    ## End of config_defaults
    'lxml_not_installed': 
    'Python library lxml is not installed. Check configuration',
    'checking_configuration': 'Checking ADA configuration',
    'no_help_available': 'There is no documentation for this rule.',
    'help_option': 'Text explaining the tasks carried by this rule.',
    'fatal_error': 'Fatal error encountered. Attach "adagio.log" to notification.',
    'file_not_found': 'File {0} not found',
    'dir_not_found': 'Directory {0} not found',
    'dir_created': 'Directory {0} created',
    'not_a_directory': '{0} is not a directory',
    'producing': 'Producing {0}',
    'copying': 'Copying {0}',
    'processing': 'Processing {0}',
    'removing': 'Removing {0}',
    'xslt_empty_result': 'XSLT transformation result is empty',
    'no_file_to_process' : 'No file given to process',
    'no_dir_to_process' : 'No directory given to process',
    'no_style_file' : 'No style file given.',
    'no_doc_for_rule': 'No documentation for rule {0}',
    'no_executable': 'Application {0} not present in the system.',
    'doc_preamble' : '===== {0} Processing Rules =====',
    'var_preamble' : '===== {0} Variables        =====',
    'cannot_open_file': 'Cannot open file {0}',
    'circular_include': 'Circular chain of templates detected:',
    'circular_alias': 'Circular chain of aliases detected:',
    'included_from': 'Included from:',
    'prefix': 'Prefix',
    'files': 'Files',
    'template_error': 'Incorrect template in file {0}.\n' + 
    'Rule must define only the variable "files"',
    'incorrect_assignment': 'Incorrect assignment in line {ln} of {pfile}',
    'incorrect_version_format': 
    'Incorrect version {0}. Should have major.minor.patch structure',
    'incorrect_version' : 'Incorrect ADA Version ({0}). Review variables ' + \
        'ada.exact_version, ada.minimum_version and ' + \
        'ada.maximum_version',
    'incorrect_variable_reference': 'Incorrect reference in value {0}',
    'import_error': 'Error while importing script in {0}',
    'import_collision': 
    'Script {0} collides with another ADA script. Name change required',
    'build_function_name': 'Function to call in the script.',
    'clean_function_name': 'Function to call in the script in rule "clean"',
    'function_error': 'Error when executing function {0}',
    'severe_parse_error': 'Error while parsing {0}',
    'severe_exec_error': 'Error while executing {0}. Check adagio.log',
    'exec_line': 'Invocation: {0}',
    'error_option_addition': 'Option {0} is empty. No addition allowed',
    'error_alias_expression': """Incorrect alias expression. Format: 'name': 'value', 'name': 'value'""",
    'severe_option_error': 'Error in configuration file',
    'error_applying_xslt': 'Error while applying style in rule {0}',
    'error_extra_args': """Incorrect argument in variable {0}.
The format must be 'name1': 'value2', 'name2': 'value2'...""",
    'unknown_rule': 'Unknown rule {0}.',
    'file_uptodate': '{0} up to date. Bypassing.',
    'not_enough_params': 'Not enough params for {0}',
    'no_var_value': 'No value given in variable {0}',
    'incorrect_arg_num': 'Incorrect arguments for {0}',
    'incorrect_option': 'Incorrect option {0}',
    'incorrect_option_in_file': 'Incorrect option {0} in file {1}',
    'incorrect_option_assignment': 'Incorrect assignment {0} = {1}',
    'cannot_detect_ada_home' : 'Unable to set variable ada.home',
    'cannot_find_properties' : 'No file {0} in directory {1}',
    'name_of_executable': 'Name of the executable to use in this rule',
    'rule_debug_level': 'Level of debug message',
    'rule_src_dir': 'Directory containing the source files.',
    'rsync_src_dir': 'Source directory to copy from',
    'rsync_dst_dir': 'Destination directory to synchronize',
    'rule_dst_dir': 'Directory where the new files will be created.',
    'convert_geometry': 'Geometry used to convert the files',
    'convert_output_suffix':
    'Suffix to add to files when processed with "convert"',
    'convert_crop_option': 'Crop option -crop widthxheight+x+y to convert',
    'dblatex_compliant':
    'If non zero Ada-flavored behavior (suppress version page)',
    'xslt_style_file': 'Style to be applied to the given source files.',
    'script_input_file': 'File to use as script input',
    'script_output_file': 'File to write the srcipt output',
    'script_error_file': 'File to write the script errors',
    'output_format': 'Extension to use when creating the new files.',
    'empty_output_format': 'Option output_format in rule {0} cannot be empty.',
    'gimp_script': 'Script to process gimp files in batch mode',
    'extra_arguments':
    """Extra arguments passed directly to {0}. 
     Format: comma separated list of pairs name: value""",
    'files_to_process': 'Space separated list of files to process.',
    'xslt_merge_styles':
    'Space separated list of styles to combine with the given style',
    'languages': 'Space separated list of languages to consider',
    'date_format': 'Format used to manipulate the dates',
    'date_incorrect_format': 'Date {0} not compliant with format {1}',
    'program_incorrect_format': '{0} cannot process format {1}',
    'exercise_produce': 
    'Exercise versions produced. Any subset of {regular, solution, pguide, submit}',
    'export_dst': 'Destination of the exports',
    'export_rules': 'Rules to execute in the destination directories',
    'export_begin': 'Date/time beyond which the export is allowed.',
    'export_end': 'Date/time until the export is allowed.',
    'export_open': 'If the export is enabled (must be "0" or "1").',
    'export_no_dst': 'No destination for export. Bypassing.',
    'enable_not_open': 'Rule not executed because "open" is {0}',
    'enable_not_revision': 
    """Rule not executed. Value of "{0}.enable_profile" is not in
"ada.enabled_profiles".""",
    'files_included_from': 
    'List of files to parse and obtain the included files and visit their directories', 
    'enable_closed_begin': 'Rule not executed because it is before {0}',
    'enable_closed_end': 'Rule not executed because it is after {0}',
    'testexam_permutations': 'Number of versions with the questions shuffled',
    'testexam_no_shuffle_required': 'No shuffle required for file {0}',
    'testexam_shuffling': 'Shuffling questions in file {0}',
    'testexam_error_shuffling': 'Error while shuffling questions in test exam',
    'ada_current_datetime': 'The Current date/time to be considered',
    'ada_enabled_profiles':
    'Space separated list of values to use to enable rule execution',
    'ada_minimum_version':
    'The minimum ada version that is required to execute this directory',
    'ada_maximum_version':
    'The maximum ada version that is required to execute this directory',
    'ada_exact_version':
    'The exact ada version that is required to execute this directory',
    'ada_debug_level_option':
    'Level of messages to print: 0 = None, 1, 2, 3, 4, 5 = CRITICAL',
    'circular_directory':
    'Circular dependency to directory {0}.',
    'circular_execute_directory':
    'Circular execution dependency to directory {0}.',
    'illegal_rule_name': 'Rule {t} is not known in dir {dl}.',
    'incorrect_debug_option' : 'Debug option requires an integer as parameter',
    'ada_version_option' : 'Current ADA version',
    'ada_locale_option' : 'Locale used while executing ADA',
    'ada_home_option' : 'Directory where ADA is installed',
    'ada_property_file_option' : 'File containing the definitions',
    'ada_file_separator_option' : 'Character to separate filenames',
    'pdfnup_nup': 'How to divide the pages, default 2 per page.',
    'option': 'Option',
    'options': 'Options',
    'not_found': 'not found'
    }