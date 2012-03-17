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
import os, re, sys, glob

import adagio, directory, i18n, rules, xsltproc

# Prefix to use for the options
module_prefix = 'exercise'

# List of tuples (varname, default value, description string)
options = [
    ('styles',
     '%(home)s%(file_separator)sAdagio_Styles%(file_separator)sExerciseSubmit.xsl',
     i18n.get('xslt_style_file')),
    ('submit_styles',
     '%(home)s%(file_separator)sAdagio_Styles%(file_separator)sAsapSubmit.xsl',
     i18n.get('xslt_style_file')),
    ('output_format', 'html', i18n.get('output_format')),
    ('language_as', 'suffix', i18n.get('language_as')),
    ('extra_arguments', '', i18n.get('extra_arguments').format('Xsltproc')),
    ('produce', 'regular', i18n.get('exercise_produce'))
    ]

documentation = {
    'en' : """
    Rule to process XML files containing exercises. For each file, the following
    documents can (optionally) be created:

    - Regular document for the students: Elements with the condition attribute
      equal to "solution", "professorguide" or ... are ignored.

    - Document with the solutions: The parts of the document included in the
      previous version plus those (elements with condition=solution

    - Document with the professor guide: The parts of the document included in
      the previous version (the solutions as well) plus those elements with
      condition=professorguide.

    - Document containing forms to submit answers: This version is produced by
      processing only a subset of the elements in the source file. These
      elements and the information the could contain are:

        * A note element with the condition attribute equals to "AdminInfo" is
          transformed into. Inside this element, the following elements are
          also rendered:

          . Paragraph with condition attribute equals to "handindate" is
            rendered as a deadline header.

          . Paragraph with the condition attribute equals to "handinlink" is
            taken as the URL to use for the submission destination (in the form
            element).

          . Paragraph with the condition attribute equals to "deadline.format"
            is the format in which the deadline date was given to introduce a
            javascript countdown.

        * A section, para or remarks element with attribute
          condition="adagio_submit_form", or a remark element with the attribute
          condition="adagio_submit_textarea_form". Inside this element the
          following elements are also rendered:

          . The content of any element with condition="form-id" is assigned as
            the id attribute of the form element.

          . The conent of any element with condition="form-method" is taken as
            the method for the submission. The default is "post".

          . The content of any element with condition="form-enctype" is taken as
            the attribute enctype in the form element. The default value is
            multipart/form-data.

          . The content of any element with condition="submit-onclick" is taken
            as the value of the attribute onClick of the generated form. The
            default value is empty.

          . If there is a phrase element with condition="hide", then a hidden
            frame is included. The answer obtained from the server when the
            submission is done is shown in that frame, and therefore, is
            invisible.

          . If there is an element with condition="submit", its text is taken as
            the submission buton text.

          If the remark element has the attribute
          condition="adagio_submit_textarea_form, then a text area box is
          created.

        * The destination URL for the submission is created concatenating the
          value of the variable adagio.submit.action.prefix and the value of any
          element with the attribute action-suffix. This is useful to define a
          common prefix which is valid project wide, and then each submission
          may add a suffix that points to the right entry point in the server
          receiving the data.

    - The previous parameters customize the form surrounding the data to be
      submitted. Each submission field is created in Docbook with a note, para
      or remark element with condition="adagio_submit_input". Each element with
      this attribute is translated into a new field in the submission form. HTML
      input fields accept various attributes. Among them, type, size, maxlength,
      accept, name, id and value can be configured by including in the Docbook
      any element with the condition attribute equal to its name. For example,
      the following Docbook markup in a source document:

      <note condition="adagio_submit_input">
        <para condition="type">text</para>
        <para condition="size">10</para>
        <para condition="maxlength">10</para>
        <para condition="name">FIELD_1</para>
        <para condition="id"/>FIELD_1_ID</para>
        <para condition="value">Default</para>
      </note>

      Renders as an input field with all the values of the para elements as
      attributes.

    - A special markup is considered for select buttons. Any note, para or
      remark element with condition="adagio_submit_scale" is rendered as
      drop-down select menu. The following internal elements are also processed:

      * The content of any element with condition="name" is taken as the
        selection name.

      * The content of each phrase element with condition="value" is rendered as
        a choice in the selection menu.

    - A special markup is considered to render text area form elements. The
      element must be a note, para or remark with
      condition="adagio_submit_textarea". The content of any element with
      condition equal to the following values is directly translated into HTML
      input attributes:

      * textarea-cols, textarea-rows: content is taken as value of attributes
        cols and rows in HTML respectively.

      * textarea-name: content is taken as the name attribute in HTML.

      * onkeyup, onkeydown: content is taken as value of attributes onKeyUp and
        onKeyDown in HTML respectively.

    The generation of these documents is controlled with the following
    convention.

    - The "files" in "src_dir" are processed as many times as specified by the
    "languages" variable and the new files are created in the "dst_dir".

    - All the created files will have the extension given in "output_format"

    - All files are processed as many times as specified by "language"

    """}

# Possible values of the 'produce' option for this rule
_produce_values = set(['regular', 'solution', ' pguide', ' submit'])

def Execute(rule, dirObj):
    """
    Execute the rule in the given directory
    """

    # Get the files to process, if empty, terminate
    toProcess = rules.getFilesToProcess(rule, dirObj)
    if toProcess == []:
        return

    # Prepare the style transformation
    styleFiles = dirObj.getProperty(rule, 'styles')
    styleTransform = xsltproc.createStyleTransform(styleFiles.split())
    if styleTransform == None:
        print i18n.get('no_style_file')
        return

    # Create the dictionary of stylesheet parameters
    styleParams = xsltproc.createParameterDict(rule, dirObj)

    # Create a list with the param dictionaries to use in the different versions
    # to be created.
    paramDict = []
    produceValues = set(dirObj.getProperty(rule, 'produce').split())
    if 'regular' in produceValues:
        # Create the regular version, no additional parameters needed
        paramDict.append(({}, ''))
    if 'solution' in produceValues:
        paramDict.append(({'solutions.include.guide': "'yes'"},
                          '_solution'))
    if 'pguide' in produceValues:
        paramDict.append(({'solutions.include.guide': "'yes'",
                          'professorguide.include.guide': "'yes'"},
                          '_pguide'))

    # Apply all these transformations.
    xsltproc.doTransformations(styleFiles.split(), styleTransform, styleParams,
                               toProcess, rule, dirObj, paramDict)

    # If 'submit' is also in the produce values, apply that transformation as
    # well (an optimization could be applied here such that if the same style is
    # given for the submit production, it could be folded in the previous
    # transformations...)

    if 'submit' in produceValues:

        # Prepare the style transformation
        styleFiles = dirObj.getProperty(rule, 'submit_styles')
        styleTransform = xsltproc.createStyleTransform(styleFiles.split())
        if styleTransform == None:
            print i18n.get('no_style_file')
            return

        # Create the dictionary of stylesheet parameters
        styleParams = xsltproc.createParameterDict(rule, dirObj)

        # Apply the transformation and produce '_submit' file
        xsltproc.doTransformations(styleFiles.split(), styleTransform,
                                   styleParams, toProcess, rule, dirObj,
                                   [({}, '_submit')])

    return

def clean(rule, dirObj):
    """
    Clean the files produced by this rule
    """

    adagio.logInfo(rule, dirObj, 'Cleaning')

    # Get the files to process
    toProcess = rules.getFilesToProcess(rule, dirObj)
    if toProcess == []:
        return

    # Create a list with the suffixes to consider
    suffixes = []
    produceValues = set(dirObj.getProperty(rule, 'produce').split())
    if 'regular' in produceValues:
        # Delete the regular version
        suffixes.append('')
    if 'solution' in produceValues:
        # Delete the solution
        suffixes.append('_solution')
    if 'pguide' in produceValues:
        # Delete the professor guide
        suffixes.append('_pguide')
    if 'submit' in produceValues:
        # Delete the submission file
        suffixes.append('_submit')

    xsltproc.doClean(rule, dirObj, toProcess, suffixes)

    return

