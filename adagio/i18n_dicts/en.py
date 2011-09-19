#!/usr/bin/python
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

msgs = {
'default_alias': 
'A synonym for the current rule',

'default_basedir': 
'Current directory where the rules are being executed',

'default_current_datetime': 
'Date/time when the execution started',

'default_debug_level': 
"""Level of debug messages to appear in log file (0-5) The higher the value the 
   more messages are written""",

'default_dst_dir': 
'Directory where the resulting files are created',

'default_enable_begin': 
'Date/time from which the rule must execute.',

'default_enable_date_format': 
'Format to specify date/times in Adagio',

'default_enable_end': 
'Date/time up to which the rule can execute.',

'default_enable_open': 
'0/1 value stating if a rule is allowed to execute',

'default_enable_profile': 
'Value authorizing the execution of the rule (empty means execute anyway)',

'default_encoding': 
'Encoding to use when producing new files',

'default_file_separator': 
'Separator used by the system in file paths',

'default_files': 
'Source files to use in a rule',

'default_help': 
'Documentation explaining the procedure implemented by a rule',

'default_home': 
'Directory where Adagio is installed',

'default_languages': 
"""Space separated list of language names to consider when processing files 
   in certain rules sensitive to languages.""",

'default_partial': 
"""0/1 value stating if Adagio continues when a rule cannot be executed""",

'default_project_file': 
'Name of the file containing the project-wide declarations',

'default_project_home': 
'Directory where the project file is found',

'default_property_file': 
'File name containing the rules',

'default_src_dir': 
'Directory from where the source files are taken',

'default_version': 
'Current Adagio version',

## End of config_defaults

'no_help_available': 
'There is no documentation for this rule.',

'file_not_found': 
'File {0} not found',

'not_a_directory': 
'{0} is not a directory',

'producing': 
'Producing {0}',

'copying': 
'Copying {0}',

'processing': 
'Processing {0}',

'removing': 
'Removing {0}',

'user_defined_variable': 
'User defined variable',

'xslt_empty_result': 
'The result of the XSLT transformation is empty',

'no_file_to_process' : 
'No file given to process',

'no_style_file' : 
'No style file given.',

'no_executable': 
'Application {0} not present in the system.',

'doc_preamble' : 
'=============== {0} Processing Rules ===============',

'var_preamble' : 
'=============== {0} Variables        ===============',

'cannot_open_file': 
'Cannot open file {0}',

'circular_include': 
'Circular chain of templates detected:',

'circular_alias': 
'Circular chain of aliases detected:',

'included_from': 
'Included from:',

'prefix': 
'Prefix',

'files': 
'Files',

'template_error': 
"""Incorrect template in file {0}. 
The template rule must define only the variable 'files'""",

'incorrect_version_format': 
'Incorrect version {0}. Should have major.minor.patch structure',

'incorrect_version' : 
"""Incorrect Adagio Version ({0}). Review variables
 'adagio.exact_version, adagio.minimum_version and 'adagio.maximum_version'""",

'incorrect_variable_reference': 
'Incorrect variable reference in value {0} (syntax: %(varname)s)',

'import_error': 
'Error while importing script in {0}',

'import_collision': 
'Script {0} collides with another Adagio script. Name change required',

'build_function_name': 
'Function to call in the script.',

'clean_function_name': 
'Function to call in the script in rule "clean"',

'function_error': 
'Error when executing function {0}',

'severe_parse_error': 
'Error while parsing {0}',

'severe_exec_error': 
'Error while executing {0}. Check adagio.log',

'exec_line': 
'Invocation: {0}',

'error_option_addition': 
'Option {0} is empty. No addition allowed',

'error_alias_expression': 
"""Incorrect alias expression. Format: 'name': 'value',
 'name': 'value'""",

'severe_option_error': 
'Error in configuration file',

'error_applying_xslt': 
"""Error while applying the following styles: 
{0} 
to file 
{1}
in rule {2}.""",

'error_in_xslt': 
"""Error while parsing style files:
{0}""",

'error_extra_args': 
"""Incorrect argument in variable {0}.
The format must be 'name1': 'value2', 'name2': 'value2'...""",

'unknown_rule': 
'Unknown rule {0}.',

'file_uptodate': 
'{0} up to date. Bypassing.',

'no_var_value': 
'No value given in variable {0}',

'incorrect_arg_num': 
'Incorrect arguments for {0}',

'incorrect_option': 
'Incorrect option {0}',

'incorrect_option_in_file': 
'Incorrect option {0} in file {1}',

'cannot_detect_adagio_home' : 
'Unable to set variable adagio.home',

'cannot_find_properties' : 
'No file {0} in directory {1}',

'name_of_executable': 
'Name of the executable to use in this rule (you may change it)',

'rsync_src_dir': 
'Source directory to use as synchronization source.',

'rsync_dst_dir': 
'Destination directory to synchronize.',

'rule_dst_dir': 
'Directory where the new files will be created by this rule.',

'convert_geometry': 
'Geometry used to convert the files',

'convert_crop_option': 
'Crop option -crop widthxheight+x+y to convert',

'dblatex_compliant':
'If non zero Adagio-flavored behavior (suppress version page)',

'xslt_style_file': 
'Space separated list of style files to be applied to the source files.',

'script_input_file': 
'File to use as script input',

'script_output_file': 
'File to write the script output',

'script_error_file': 
'File to write the script errors',

'script_arguments': 
'Arguments passed to the given Python script',

'output_format': 
'Extension to use when producing the new files (without dot).',

'empty_output_format': 
'Option output_format in rule {0} cannot be empty.',

'gimp_script': 
'Script to process gimp files in batch mode',

'extra_arguments':
"""Extra arguments passed directly to {0}. 
Format: comma separated list of pairs name: value""",

'date_incorrect_format': 
'Date {0} not compliant with format {1}',

'program_incorrect_format': 
'{0} cannot process format {1}',

'exercise_produce': 
"""Space separated list of exercise versions to be produced. Any subset of 
{regular, solution, pguide, submit}""",

'export_dst': 
'Destination of the exports',

'export_rules': 
'Rules to execute in the destination directories',

'export_no_dst': 
'No destination for export. Bypassing.',

'enable_not_open': 
'Rule not executed because variable "open" has value {0}',

'enable_not_revision': 
"""Rule not executed. Variable "{0}.enable_profile"
has value "{1}" which is not contained in
"{2}", the value of "adagio.enabled_profiles".""",

'enable_closed_begin': 
'Rule not executed because it is before {0}',

'enable_closed_end': 
'Rule not executed because it is after {0}',

'testexam_no_shuffle_required': 
'No shuffle required for file {0}',

'testexam_shuffling': 
'Shuffling questions in file {0}',

'testexam_no_permutations':
"""No questions detected in file {0}.
No quandaset under root element.""",

'adagio_enabled_profiles':
'Space separated list of values to use to enable rule execution',

'adagio_minimum_version':
'The minimum Adagio version that is required to execute this directory',

'adagio_maximum_version':
'The maximum Adagio version that is required to execute this directory',

'adagio_exact_version':
'The exact Adagio version that is required to execute this directory',

'circular_execute_directory':
'Circular execution dependency to directory {0}.',

'illegal_rule_name': 
'Rule {t} is not known in dir {dl}.',

'incorrect_debug_option' : 
'Debug option requires an integer as parameter',

'pdfnup_nup': 
'How to divide the pages, default 2 per page.'
}
