#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#

msgs = {
    '__doc__': """
    Script to execute the production rules in the current directory. The
    invocation of the script must be:

    script [options] [dir dir ...]

    The script executes the production rules in the given directories in the
    order they appear in the command line. If no directory is given, then the
    current directory is processed.

    The script accepts the following options:

      -d num: Debugging level. Used to set the severity level in a
              logging object. Possible values are:

              CRITICAL/FATAL = 50
              ERROR =          40
              WARNING =        30
              INFO =           20
              DEBUG =          10
              NOTSET =          0

      -s 'name value': Executes the application by first storing in the
                       environment the assignment name = value. This means that,
                       unless overwritten by definitions in the properties file,
                       this assignment will be visible to all the rules
                       executed.

      -t target: Specific target in the Properties.txt file to execute. If none
                 is given, all of them are executed.

    """,
    'file_not_found': 'File {0} not found',
    'cannot_open_fiel': 'Cannot open file {0}',
    'line_in_no_section': 'Line {ln} of {pfile} is outside a section',
    'incorrect_assignment': 'Incorrect assignment in line {ln} of {pfile}',
    'severe_parse_error': 'Severe error while parsing line {ln} of {pfile}',
    'not_enough_params': 'Not enough params for {0}',
    'incorrect_arg_num': 'Incorrect arguments for {0}',
    'name_of_executable': 'Name of the executable to use in this rule',
    'rule_debug_level': 'Level of debug message',
    'rule_src_dir': 'Directory containing the source files.',
    'rule_dst_dir': 'Directory where the new files will be created.',
    'xslt_style_file': 'Style to be applied to the given source files.',
    'output_format': 'Extension to use when creating the new files.',
    'xslt_extra_arguments':
    'Extra arguments passed directly to the style processor.',
    'files_to_process': 'Space separated list of files to process.',
    'xslt_merge_styles':
    'Space separated list of styles to combine with the given style',
    'xslt_languages': 'Space separated list of languages to consider',
    'xslt_multilingual':
    'True/False if the documents to process are multilingual.\n\
      Incompatible with profile_lang',
    'xslt_net_option': 'Network option to pass to the xslt processor',
    'ada_current_datetime': 'The Current date/time to be considered',
    'ada_profile_revision':
    'Value of the revision attribute to profile Docbook files',
    'ada_minimum_version':
    'The minimum ada version that is required to execute this directory',
    'ada_maximum_version':
    'The maximum ada version that is required to execute this directory',
    'ada_exact_version':
    'The exact ada version that is required to execute this directory',
    'ada_debu_level':
    'Level of messages to print on the screen: 0 None, 10, 20, 30, 40, 50 CRITICAL',
    'circular_directory':
    'Circular dependency to directory {0}.',
    'circular_execute_directory':
    'Circular execution dependency to directory {0}.',
    'illegal_target_prefix': 'Illegal target name {0}.',
    'ada_debug_level_option' : 'Debug level to use',
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
