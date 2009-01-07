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

  <!-- Number QandA with correlative integers within a section -->
  <xsl:template match="question" mode="label.markup">
    <xsl:number level="any" count="qandaentry" from="section" format="1"/>
  </xsl:template>

  <!-- Only those qandadiv with condition TestQuestion or TestMCQuestion
       are processed by this stylesheet -->
  <xsl:template match="qandadiv[@condition='TestQuestion'] |
                       qandadiv[@condition='TestMCQuestion']">
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
            <xsl:text>, </xsl:text><xsl:value-of select="@arch"/>/<xsl:value-of select="@revision"/>/<xsl:value-of select="@vendor"/>
          </xsl:for-each>)
        </xsl:if>
      </p>

      <!-- Recur through other DocBook elements -->
      <div class="ada_exam_qandadiv_prelude_text">
        <xsl:apply-templates/>
      </div>

      <!--
           Choose between rendering a single question or multiple questions
           common to the same preceeding text
           -->
      <xsl:choose>
        <xsl:when test="count(qandaentry) = 1">
          <xsl:for-each select="qandaentry">
            <xsl:call-template name="singlequestion"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <div class="ada_exam_multiplequestions">
            <!-- There are three possible cases: All questions TF, all
                 questions MC and mixed. Is it worth considering these three
                 cases? So far, only the TF and MC templates are invoked. -->
            <xsl:choose>
              <xsl:when test="count(qandaentry[position() = 1]/answer) = 1">
                <xsl:call-template name="multipleTFquestion"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="multipleMCquestion"/>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <!-- Render one individual question -->
  <xsl:template match="qandaentry">
    <xsl:if test="not(boolean(ancestor::qandadiv))">
      <div class="qandaentry">
        <div class="qandaentry_numbering">
          <xsl:choose>
            <xsl:when test="$profile.lang = 'en'">Question</xsl:when>
            <xsl:otherwise>Pregunta</xsl:otherwise>
          </xsl:choose>
          <xsl:value-of
            select="count(ancestor::section/preceding::qandaentry) + 1"/>
          <xsl:if test="$ada.testquestions.include.id = 'yes'">
            (id=<xsl:value-of select="@id"/>
            <xsl:for-each select="blockinfo/printhistory/para">
              , <xsl:value-of select="@arch"/>/<xsl:value-of select="@revision"/>/<xsl:value-of select="@vendor"/>
            </xsl:for-each>)
          </xsl:if>
        </div>
        <xsl:call-template name="singlequestion"/>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- Formats the question of the qandaentry. To be used, either when not in a
       qandadiv, or when it is the only one in a qandadiv -->
  <xsl:template name="singlequestion">
    <xsl:choose>
      <xsl:when test="count(answer) = 1">
        <xsl:call-template name="singleTFquestion"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="singleMCquestion"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- One single TF question -->
  <xsl:template name="singleTFquestion">
    <div class="ada_exam_singletfquestion">
      <xsl:call-template name="TFQuestion_Heading"/>
      <xsl:call-template name="TFQuestion_Statement"/>
    </div>
  </xsl:template>

  <!-- One single multiple choice question -->
  <xsl:template name="singleMCquestion">
    <div>
      <xsl:choose>
        <xsl:when test="count(../qandaentry) = 1">
          <xsl:attribute name="class">ada_exam_singlemcquestion_nosiblings</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">ada_exam_singlemcquestion</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <div class="ada_exam_qandaentry_question_text">
        <xsl:apply-templates select="question/node()"/>
      </div>

      <div class="ada_exam_singlemcquestion_answers">
        <xsl:for-each select="answer">
          <div class="ada_exam_singlemcquestion_answer">
            <xsl:call-template name="MC_answer_square"/>
            <div class="ada_exam_singlemcquestion_answer_text">
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

  <!-- multple TF question elements in the same quandaentry -->
  <xsl:template name="multipleTFquestion">
    <xsl:call-template name="TFQuestion_Heading"/>
    <xsl:for-each select="qandaentry">
      <xsl:call-template name="TFQuestion_Statement"/>
    </xsl:for-each>
  </xsl:template>

  <!-- multple TF question elements in the same quandaentry -->
  <xsl:template name="multipleMCquestion">
    <xsl:for-each select="qandaentry">
        <xsl:call-template name="singleMCquestion"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="TFQuestion_Heading">
    <div class="ada_exam_singletfquestion_heading">
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
    <div class="ada_exam_tfquestion_statement">
      <xsl:call-template name="TF_answer_true_square"/>
      <xsl:call-template name="TF_answer_false_square"/>
      <div class="ada_exam_singlemcquestion_answer_text">
        <xsl:apply-templates select="question/node()"/>
        <xsl:if test="$ada.testquestions.include.history = 'yes'">
          <div class="ada_exam_question_history">
            <xsl:call-template name="dump-history" />
          </div>
        </xsl:if>
      </div>
    </div> <!-- End of ada_exam_tfquestion_statement -->
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
