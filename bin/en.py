#!/usr/bin/python
# -*- coding: UTF-8 -*-#
#
# Author: Abelardo Pardo (abelardo.pardo@uc3m.es)
#
#
#

msgs = {
    '__doc__': """
    Execute the given targets from the production rules described in a local
    file. The invocation of this script must follow the structure:

    script [options] [target target ...]

    The script visits the current directory and executes the rules attached to
    the given targets. If no target is given, all of them are processed

    The script accepts the following options:

      -d num: Debugging level. Used to set the severity level in a
              logging object. Possible values are:

              CRITICAL/FATAL = 50
              ERROR =          40
              WARNING =        30
              INFO =           20
              DEBUG =          10
              NOTSET =          0

      -h or -x: Shows this message

      -s 'section name value': Executes the application by first storing in the
                       environment the assignment name = value. This means that,
                       unless overwritten by definitions in the properties file,
                       this assignment will be visible to all the rules
                       executed.

    """,
    'file_not_found': 'File {0} not found',
    'not_a_directory': '{0} is not a directory',
    'producing': 'Producing {0}',
    'removing': 'Removing {0}',
    'no_file_to_process' : 'No file given to process',
    'no_style_file' : 'No style file given.',
    'no_doc_for_rule': 'No documentation for rule {0}',
    'doc_preamble' : '===== {0} Processing Rules =====',
    'var_preamble' : '===== {0} Variables        =====',
    'cannot_open_file': 'Cannot open file {0}',
    'line_in_no_section': 'Line {ln} of {pfile} is outside a section',
    'incorrect_assignment': 'Incorrect assignment in line {ln} of {pfile}',
    'incorrect_version_format': 'Incorrect version {0}. Should have major.minor.patch structure',
    'incorrect_version' : 'Incorrect ADA Version ({0}). Review variables ' + \
        'ada.exact_version, ada.minimum_version and ' + \
        'ada.maximum_version',
    'severe_parse_error': 'Error while parsing {0}',
    'severe_option_error': 'Error in configuration file',
    'error_applying_xslt': 'Error while applying style in target {0}',
    'error_extra_args': 'Incorrect arguments in variable {0}.extra-arguments',
    'file_uptodate': 'File {0} is up to date. Bypassing execution.',
    'not_enough_params': 'Not enough params for {0}',
    'incorrect_arg_num': 'Incorrect arguments for {0}',
    'incorrect_option': 'Incorrect option {0}',
    'incorrect_option_in_file': 'Incorrect option {0} in file {1}', 
    'incorrect_option_assignment': 'Incorrect assignment {0} = {1}',
    'cannot_detect_ada_home' : 'Unable to set variable ada.home',
    'cannot_find_properties' : 'No file {0} in directory {1}',
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
    'illegal_target_name': 'The target {t} is not known in dir {dl}.',
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
