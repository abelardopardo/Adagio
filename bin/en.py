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
    '__doc__': """
    Execute the given targets from the production rules described in a local
    file. The invocation of this script must follow the structure:

    script [options] [target target ...]

    The script visits the current directory and executes the rules attached to
    the given targets. If no target is given, all of them are processed

    The script accepts the following options:

      -c filename: File to read the configuration

      -d num: Debugging level. Used to control the amount of messages
       dumped. Possible values are:

              CRITICAL/FATAL = 5
              ERROR =          4
              WARNING =        3
              INFO =           2
              DEBUG =          1
              NOTSET =         0

      -h or -x: Shows this message

      -p: Partial execution. Proceed even if some tools are not installed. Otherwise
          stop execution in the first missing tool.

      -s 'section name value': Executes the application by first storing in the
                       environment the assignment name = value. This means that,
                       unless overwritten by definitions in the properties file,
                       this assignment will be visible to all the rules
                       executed.

    """,
    'fatal_error': 'Fatal error encountered. Attach "adado.log" to notification.',
    'file_not_found': 'File {0} not found',
    'not_a_directory': '{0} is not a directory',
    'producing': 'Producing {0}',
    'processing': 'Processing {0}',
    'removing': 'Removing {0}',
    'no_file_to_process' : 'No file given to process',
    'no_dir_to_process' : 'No directory given to process',
    'no_targets_to_clean' : 'No targets to clean in {0}',
    'no_style_file' : 'No style file given.',
    'no_doc_for_rule': 'No documentation for rule {0}',
    'no_executable': 'Application {0} not present in the system.',
    'doc_preamble' : '===== {0} Processing Rules =====',
    'var_preamble' : '===== {0} Variables        =====',
    'cannot_open_file': 'Cannot open file {0}',
    'line_in_no_section': 'Line {ln} of {pfile} is outside a section',
    'circular_include': 'Circular chain of templates detected:',
    'included_from': 'Included from:',
    'prefix': 'Prefix',
    'files': 'Files',
    'template_error': 'Error in template section in file {0}',
    'incorrect_assignment': 'Incorrect assignment in line {ln} of {pfile}',
    'incorrect_version_format': 'Incorrect version {0}. Should have major.minor.patch structure',
    'incorrect_version' : 'Incorrect ADA Version ({0}). Review variables ' + \
        'ada.exact_version, ada.minimum_version and ' + \
        'ada.maximum_version',
    'incorrect_variable_reference': 'Incorrect reference in value {0}',
    'import_error': 'Error while importing script in {0}',
    'function_name': 'Function to call in the given script.',
    'function_error': 'Error when executing function {0}',
    'severe_parse_error': 'Error while parsing {0}',
    'severe_exec_error': 'Error while executing {0}. Check adado.log',
    'exec_line': 'Invocation: {0}',
    'severe_option_error': 'Error in configuration file',
    'error_applying_xslt': 'Error while applying style in target {0}',
    'error_extra_args': 'Incorrect arguments in variable {0}.',
    'unknown_target': 'Unknown target {0}.',
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
    'xslt_common_styles': 'Additional styles to apply.',
    'output_format': 'Extension to use when creating the new files.',
    'gimp_script': 'Script to process gimp files in batch mode',
    'extra_arguments':
    'Extra arguments passed directly to {0}.',
    'files_to_process': 'Space separated list of files to process.',
    'xslt_merge_styles':
    'Space separated list of styles to combine with the given style',
    'languages': 'Space separated list of languages to consider',
    'xslt_multilingual':
    'True/False if the documents to process are multilingual.\n\
      Incompatible with profile_lang',
    'date_format': 'Format used to manipulate the dates',
    'date_incorrect_format': 'Date {0} not compliant with format {1}',
    'exercise_produce': 
    'Exercise versions produced. Any subset of {regular, solution, pguide, submit}',
    'export_dst': 'Destination of the exports',
    'export_targets': 'Targets to execute in the destination directories',
    'export_begin': 'Date/time beyond which the export is allowed.',
    'export_end': 'Date/time until the export is allowed.',
    'export_open': 'If the export is enabled (must be "0" or "1").',
    'export_no_dst': 'No destination for export. Bypassing.',
    'export_not_open': 'Export not executed because "open" is {0}',
    'export_not_revision':
    'Export not executed because revision {0} is not in "profile_revisions".',
    'export_profile_revisions':
    'Values of profile_revision for which the export is allowed.',
    'export_closed_begin': 'Export not executed because it is before {0}',
    'export_closed_end': 'Export not executed because it is after {0}',
    'testexam_permutations': 'Number of versions with the questions shuffled',
    'testexam_no_shuffle_required': 'No shuffle required for file {0}',
    'testexam_shuffling': 'Shuffling questions in file {0}',
    'testexam_error_shuffling': 'Error while shuffling questions in test exam',
    'ada_current_datetime': 'The Current date/time to be considered',
    'ada_profile_revision':
    'Value of the revision attribute to profile Docbook files',
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
    'illegal_target_prefix': 'Illegal target name {0}.',
    'illegal_target_name': 'The target {t} is not known in dir {dl}.',
    'incorrect_debug_option' : 'Option -d requires an integer as parameter',
    'ada_version_option' : 'Current ADA version',
    'ada_locale_option' : 'Locale used while executing ADA',
    'ada_home_option' : 'Directory where ADA is installed',
    'ada_property_file_option' : 'File containing the definitions',
    'ada_file_separator_option' : 'Character to separate filenames',
    'option': 'Option',
    'options': 'Options',
    'not_found': 'not found'
    }
