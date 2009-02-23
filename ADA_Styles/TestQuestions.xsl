<?xml version="1.0" encoding="UTF-8"?>

<!--
  Copyright (C) 2008 Carlos III University of Madrid
  This file is part of the ADA: Agile Distributed Authoring Toolkit

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor
  Boston, MA  02110-1301, USA.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="exsl" version="1.0">

  <xsl:import href="TestQuestionsParams.xsl"/>

  <xsl:param name="ada.test.questions.debug" select="0"/>

  <!-- Number QandA with correlative integers within a section -->
  <xsl:template match="question" mode="label.markup">
    <xsl:number level="any" count="qandaentry" from="section" format="1"/>
  </xsl:template>

  <!-- Only those qandadiv with condition TestQuestion or TestMCQuestion
       are processed by this stylesheet -->
  <xsl:template match="qandadiv[@condition='ADA_Test_Question']|
                       qandaentry[@condition='ADA_Test_Question']">
    <xsl:variable name="beginnumber">
      <xsl:number level="any" count="qandaentry" from="section"/>
    </xsl:variable>
    <xsl:variable name="qnumber" select="count(descendant::qandaentry)"/>

    <!--
         FIX: Needs to check for the presence of some sort of
         blockinfo that instructs this table to have a
         class="pageBreakBefore" attribute
    -->

    <!-- Table surrounding one qandadiv (might have several questions) -->
    <div>
      <!-- Set ID attribute to ID of the qandadiv -->
      <xsl:if test="@id">
        <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
      </xsl:if>
      <!-- Set class attribute -->
      <xsl:choose>
        <xsl:when test="($ada.testquestions.render.onequestionperpage = 'yes') or
              ((/section/sectioninfo/productnumber/remark[@condition =
              ($beginnumber + 1)]) and
              ($ada.testquestions.insert.pagebreaks = 'yes'))">
          <xsl:attribute name="class">qandadiv pageBreakBefore</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">qandadiv</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>

      <!-- Question number and labels -->
      <p class="qandadiv_numbering">
        <xsl:choose>
          <xsl:when test="$qnumber > 1">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">Questions </xsl:when>
              <xsl:otherwise>Preguntas </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$beginnumber + 1"/>
            <xsl:choose>
              <xsl:when test="$profile.lang='en'"> to </xsl:when>
              <xsl:otherwise> a </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$beginnumber + $qnumber"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">Question </xsl:when>
              <xsl:otherwise>Pregunta </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$beginnumber + 1"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$ada.testquestions.include.id = 'yes'">
          (id = <xsl:value-of select="@id"/>
          <xsl:if test="blockinfo/author">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="blockinfo/author/personname/firstname/text()"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="blockinfo/author/personname/surname/text()"/>
          </xsl:if>
          <xsl:for-each select="blockinfo/printhistory/para">
            <xsl:text>, </xsl:text><xsl:value-of select="@revision"/>
          </xsl:for-each>)
        </xsl:if>
      </p>

      <!-- If processing a qandadiv, recur through the elements previous to the
           qandaentries -->
      <xsl:choose>
        <xsl:when test="name() = 'qandadiv'">

          <xsl:if test="$ada.test.questions.debug != 0">
            <xsl:message>Processing <xsl:value-of select="@id"/></xsl:message>
            <xsl:message># TF Questions: <xsl:value-of
            select="count(qandaentry[count(answer) = 1])"/></xsl:message>
            <xsl:message># MC Questions: <xsl:value-of
            select="count(qandaentry[count(answer) &gt; 1])"/></xsl:message>
          </xsl:if>

          <div class="ada_exam_qandadiv_prelude_text">
            <xsl:apply-templates
              select="qandaentry[position() = 1]/preceding-sibling::*"/>
          </div>

          <!--
               Choose between rendering a single question or multiple questions
               common to the same preceeding text
               -->
          <xsl:variable name="class_prefix">
            <xsl:if test="count(qandaentry) &gt; 1">_multiple</xsl:if>
          </xsl:variable>

          <div>
            <xsl:attribute name="class">ada_exam_qandaentry_table<xsl:value-of
            select="$class_prefix"/></xsl:attribute>

            <xsl:for-each select="qandaentry">
              <xsl:variable name="qandaentry_position"><xsl:value-of
              select="position()"/></xsl:variable>

              <xsl:if test="$ada.test.questions.debug != 0">
                <xsl:message>  Qandaentry <xsl:value-of
                select="position()"/></xsl:message>
              </xsl:if>

              <!-- Call render template but anticipating if TF heading needs to be
                   included -->
              <xsl:call-template name="render_qandaentry" select=".">
                <xsl:with-param name="qandaentry_position"><xsl:value-of
                select="position()"/></xsl:with-param>
                <xsl:with-param name="put_tf_heading"
                  select="(count(answer) = 1) and
                          ((position() = 1) or
                          (count(preceding-sibling::qandaentry[position() =
                          ($qandaentry_position - 1)]/answer) != 1))"/>
              </xsl:call-template>

            </xsl:for-each>
          </div>
        </xsl:when>

        <!-- A single qandaentry, with no surrounding DIV -->
        <xsl:otherwise>
          <xsl:call-template name="render_qandaentry" select="."/>
        </xsl:otherwise>
      </xsl:choose>

    </div>
  </xsl:template>

  <!-- Template to process any qandaentry in the document -->
  <xsl:template name="render_qandaentry">
    <xsl:param name="qandaentry_position" select="1"/>
    <xsl:param name="put_tf_heading" select="false"/>

    <xsl:if test="$ada.test.questions.debug != 0">
      <xsl:message>    TF Heading: <xsl:value-of
      select="$put_tf_heading"/></xsl:message>
      <xsl:message>    Name: <xsl:value-of select="name()"/></xsl:message>
      <xsl:message>    Prefix: <xsl:value-of select="$class_prefix"/></xsl:message>
    </xsl:if>

    <!-- Choose between MC and TF -->
    <xsl:choose>
      <xsl:when test="count(answer) = 1">
        <!-- TF Question -->
        <xsl:if test="$put_tf_heading">
          <xsl:call-template name="TFQuestion_Heading"/>
        </xsl:if>
        <xsl:call-template name="TFQuestion_Statement"/>
      </xsl:when>

      <xsl:when test="count(answer) &gt; 1">
        <!-- MC Question -->
        <xsl:call-template name="MCquestion"/>
      </xsl:when>

      <xsl:otherwise>
        <p>Unknown question type (based on number of answers)</p>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

  <!-- Heading for the TF Questions. It simply dumps a true / false table -->
  <xsl:template name="TFQuestion_Heading">
    <div class="ada_exam_tfquestion_heading">
      <div>
        <xsl:choose>
          <xsl:when test="$profile.lang='en'">True</xsl:when>
          <xsl:otherwise>Verdadero</xsl:otherwise>
        </xsl:choose>
      </div>
      <div>
        <xsl:choose>
          <xsl:when test="$profile.lang='en'">False</xsl:when>
          <xsl:otherwise>Falso</xsl:otherwise>
        </xsl:choose>
      </div>
    </div>
  </xsl:template>

  <!-- Templates to draw answer squares -->
  <xsl:template name="TF_answer_true_square">
    <div class="ada_exam_answer_square">
      <div>
        <xsl:if test="($ada.testquestions.include.solutions = 'yes') and
                      (contains(answer/@condition, 'Cierto') or
                      contains(answer/@condition, 'Verdadero') or
                      contains(answer/@condition, 'Correct') or
                      contains(answer/@condition, 'True'))">
          <xsl:attribute name="class">solid_answer_square</xsl:attribute>
        </xsl:if>
      </div>
    </div>
  </xsl:template>
  <xsl:template name="TF_answer_false_square">
    <div class="ada_exam_answer_square">
      <div>
        <xsl:if test="($ada.testquestions.include.solutions = 'yes') and
                      (contains(answer/@condition, 'Falso') or
                      contains(answer/@condition, 'False'))">
          <xsl:attribute name="class">solid_answer_square</xsl:attribute>
        </xsl:if>
      </div>
    </div>
  </xsl:template>
  <xsl:template name="MC_answer_square">
    <div class="ada_exam_answer_square">
      <div>
        <xsl:if test="($ada.testquestions.include.solutions = 'yes') and
                      (contains(@condition, 'Cierto') or
                      contains(@condition, 'Verdadero') or
                      contains(@condition, 'Correct') or
                      contains(@condition, 'True'))">
          <xsl:attribute name="class">solid_answer_square</xsl:attribute>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <!-- True/False squares + the statement in a row -->
  <xsl:template name="TFQuestion_Statement">
    <div class="ada_exam_question_statement">
      <xsl:call-template name="TF_answer_true_square"/>
      <xsl:call-template name="TF_answer_false_square"/>
      <div class="ada_exam_question_answer_text">
        <xsl:apply-templates select="question/node()"/>
        <xsl:if test="$ada.testquestions.include.history = 'yes'">
          <div class="ada_exam_question_history">
            <xsl:call-template name="dump-history" />
          </div>
        </xsl:if>
      </div>
    </div> <!-- End of ada_exam_tfquestion_statement -->
  </xsl:template>

  <xsl:template name="MCquestion">
    <div>
      <xsl:choose>
        <xsl:when test="count(../qandaentry) = 1">
          <xsl:attribute name="class">ada_exam_question_nosiblings</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">ada_exam_question</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <div class="ada_exam_qandaentry_question_text">
        <xsl:apply-templates select="question/node()"/>
      </div>

      <div class="ada_exam_question_answers">
        <xsl:for-each select="answer">
          <div class="ada_exam_question_answer">
            <xsl:call-template name="MC_answer_square"/>
            <div class="ada_exam_question_answer_text">
              <xsl:apply-templates />
            </div>
          </div>
        </xsl:for-each>
      </div>

      <xsl:if test="$ada.testquestions.include.history = 'yes'">
        <div class="ada_exam_question_history">
          <xsl:call-template name="dump-history" />
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- Dump element containing history -->
  <xsl:template name="dump-history">
    <p>
      <xsl:choose>
        <xsl:when test="$profile.lang='en'">Statistics</xsl:when>
        <xsl:otherwise>Estadísticas</xsl:otherwise>
      </xsl:choose>
    </p>

    <table class="ada_exam_question_history_table">
      <tr>
        <xsl:choose>
          <xsl:when test="$profile.lang='en'">
            <th>Edition</th>
            <th>Correct</th>
            <th>Inc.</th>
            <th>Blank</th>
            <th>Total</th>
            <th>Remarks</th>
          </xsl:when>
          <xsl:otherwise>
            <th>Edición</th>
            <th>Correctas</th>
            <th>Inc.</th>
            <th>Blanco</th>
            <th>Total</th>
            <th>Comentarios</th>
          </xsl:otherwise>
        </xsl:choose>
      </tr>
      <xsl:choose>
        <xsl:when test="blockinfo/printhistory/para">
          <xsl:for-each select="blockinfo/printhistory/para">
            <tr>
              <td>
                <xsl:value-of
                  select="@arch"/>/<xsl:value-of
                select="@revision"/>/<xsl:value-of
                select="@vendor"/>
              </td>
              <td>
                <xsl:value-of
                  select="phrase[@condition='correct']/text()"/>
              </td>
              <td>
                <xsl:value-of select="phrase[@condition='incorrect']/text()"/>
              </td>
              <td>
                <xsl:value-of select="phrase[@condition='blank']/text()"/>
              </td>
              <td>
                <xsl:value-of select="phrase[@condition='total']/text()"/>
              </td>
              <td>
                <xsl:value-of select="phrase[@condition='remarks']/text()"/>
              </td>
            </tr>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <tr>
            <td colspan="6">No information available</td>
          </tr>
        </xsl:otherwise>
      </xsl:choose>
    </table>
  </xsl:template>

  <!-- The blockinfo needs to be matched to avoid to appear in the output -->
  <xsl:template match="blockinfo"/>
</xsl:stylesheet>
