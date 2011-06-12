<?xml version="1.0" encoding="UTF-8"?>

<!--
  Copyright (C) 2008 Carlos III University of Madrid
  This file is part of Adagio: Agile Distributed Authoring Integrated Toolkit

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

  <xsl:param name="adagio.test.questions.debug" select="0"/>

  <!-- Number QandA with correlative integers within a section -->
  <xsl:template match="question" mode="label.markup">
    <xsl:number level="any" count="qandaentry" from="section" format="1"/>
  </xsl:template>

  <!-- Only those qandadiv with condition TestQuestion or TestMCQuestion
       are processed by this stylesheet -->
  <xsl:template match="qandadiv[@condition='Adagio_Test_Question']|
                       qandaentry">
    <xsl:variable name="beginnumber">
      <xsl:number level="any" count="qandaentry" from="section"/>
    </xsl:variable>
    <xsl:variable name="qnumber" select="count(descendant::qandaentry)"/>

    <!-- Table surrounding one qandadiv (might have several questions) -->
    <div>
      <!-- Set ID attribute to ID of the qandadiv -->
      <xsl:if test="@id">
        <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
      </xsl:if>
      <!-- Set class attribute -->
      <xsl:choose>
        <xsl:when test="($adagio.testquestions.render.onequestionperpage = 'yes') or
              ((/section/sectioninfo/productnumber/remark[@condition =
              ($beginnumber + 1)]) and
              ($adagio.testquestions.insert.pagebreaks = 'yes'))">
          <xsl:attribute name="class">adagio_exam_qandadiv pageBreakBefore</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">adagio_exam_qandadiv</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>

      <!-- Question number and labels -->
      <p class="adagio_exam_qandadiv_numbering">
        <xsl:choose>
          <xsl:when test="$qnumber > 1">
            <xsl:choose>
              <xsl:when test="$profile.lang='es'">Preguntas </xsl:when>
              <xsl:otherwise>Questions </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$beginnumber + 1"/>
            <xsl:choose>
              <xsl:when test="$profile.lang='es'"> a </xsl:when>
              <xsl:otherwise> to </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$beginnumber + $qnumber"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$profile.lang='es'">Pregunta </xsl:when>
              <xsl:otherwise>Question </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$beginnumber + 1"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$adagio.testquestions.include.id = 'yes'">
          (id = <xsl:value-of select="@id"/>)
        </xsl:if>
      </p>

      <xsl:if test="$adagio.test.questions.debug != 0">
        <xsl:message>Processing <xsl:value-of select="@id"/></xsl:message>
        <xsl:message>  BeginNumber: <xsl:value-of select="$beginnumber"/></xsl:message>
        <xsl:message>  QNumber: <xsl:value-of select="$qnumber"/></xsl:message>
      </xsl:if>

      <!-- If processing a qandadiv, recur through the elements previous to the
           qandaentries -->
      <xsl:choose>
        <xsl:when test="name() = 'qandadiv'">

          <xsl:if test="$adagio.test.questions.debug != 0">
            <xsl:message># TF Questions: <xsl:value-of
            select="count(qandaentry[count(answer) = 1])"/></xsl:message>
            <xsl:message># MC Questions: <xsl:value-of
            select="count(qandaentry[count(answer) &gt; 1])"/></xsl:message>
          </xsl:if>

          <xsl:if test="qandaentry[position() = 1]/preceding-sibling::*">
            <div class="adagio_exam_qandadiv_prelude_text">
              <xsl:apply-templates
                select="qandaentry[position() = 1]/preceding-sibling::*"/>
            </div>
          </xsl:if>

          <!--
               Choose between rendering a single question or multiple questions
               common to the same preceeding text
               -->
          <xsl:variable name="class_prefix">
            <xsl:choose>
              <xsl:when test="count(qandaentry) &gt; 1">_multiple</xsl:when>
              <xsl:otherwise>_single</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

	  <xsl:choose>
	    <!-- Recur through the OPEN questions, if any -->
	    <xsl:when test="qandaentry[count(answer[@condition = 'open']) = 1]">
	      <div>
		<xsl:attribute name="class">adagio_exam_qandaentry_table<xsl:value-of
		select="$class_prefix"/></xsl:attribute>

		<xsl:for-each
		  select="qandaentry[count(answer[@condition = 'open']) = 1]">
		  <xsl:variable name="qandaentry_position"><xsl:value-of
		  select="position()"/></xsl:variable>

		  <xsl:if test="$adagio.test.questions.debug != 0">
		    <xsl:message>  OPEN Qandaentry <xsl:value-of
		    select="position()"/></xsl:message>
		  </xsl:if>

		  <!-- Call render template -->
		  <xsl:call-template name="render_qandaentry" select=".">
		    <xsl:with-param name="qandaentry_position"><xsl:value-of
		    select="position()"/></xsl:with-param>
                </xsl:call-template>
		</xsl:for-each>
	      </div>
	    </xsl:when>

	    <!-- Recur through the TF questions, if any -->
	    <xsl:when test="qandaentry[count(answer) = 1]">
	      <div>
		<xsl:attribute name="class">adagio_exam_qandaentry_table<xsl:value-of
		select="$class_prefix"/></xsl:attribute>

		<xsl:call-template name="TFQuestion_Heading"/>

		<xsl:for-each select="qandaentry[count(answer) = 1]">
		  <xsl:variable name="qandaentry_position"><xsl:value-of
		  select="position()"/></xsl:variable>

		  <xsl:if test="$adagio.test.questions.debug != 0">
		    <xsl:message>  TF Qandaentry <xsl:value-of
		    select="position()"/></xsl:message>
		  </xsl:if>

		  <!-- Call render template -->
		  <xsl:call-template name="render_qandaentry" select=".">
		    <xsl:with-param name="qandaentry_position"><xsl:value-of
		    select="position()"/></xsl:with-param>
                </xsl:call-template>
		</xsl:for-each>
	      </div>
	    </xsl:when>

	    <!-- Recur through the MC questions -->
	    <xsl:when test="not(qandaentry[count(answer) = 1])">
	      <div>
		<xsl:attribute name="class">adagio_exam_qandaentry_table<xsl:value-of
		select="$class_prefix"/></xsl:attribute>

		<xsl:for-each select="qandaentry[count(answer) != 1]">
		  <xsl:variable name="qandaentry_position"><xsl:value-of
		  select="position()"/></xsl:variable>

		  <xsl:if test="$adagio.test.questions.debug != 0">
		    <xsl:message>  MC Qandaentry <xsl:value-of
		    select="position()"/></xsl:message>
		  </xsl:if>

		  <!-- Call render template but anticipating if TF heading needs to be
		       included -->
		  <xsl:call-template name="render_qandaentry" select=".">
		    <xsl:with-param name="qandaentry_position"><xsl:value-of
		    select="position()"/></xsl:with-param>
		  </xsl:call-template>
		</xsl:for-each>
	      </div>
	    </xsl:when>
	  </xsl:choose>
        </xsl:when>

        <!-- A single qandaentry, with no surrounding DIV -->
        <xsl:otherwise>
          <xsl:if test="qandaentry[count(answer) = 1]">
            <xsl:call-template name="TFQuestion_Heading"/>
          </xsl:if>
          <xsl:call-template name="render_qandaentry" select="."/>
        </xsl:otherwise>
      </xsl:choose>

    </div>
  </xsl:template>

  <!-- Template to process any qandaentry in the document -->
  <xsl:template name="render_qandaentry">
    <xsl:param name="qandaentry_position" select="1"/>

    <xsl:if test="$adagio.test.questions.debug != 0">
      <xsl:message>    Name: <xsl:value-of select="name()"/></xsl:message>
      <xsl:message>    Prefix: <xsl:value-of select="$class_prefix"/></xsl:message>
    </xsl:if>

    <div>
      <xsl:attribute name="class">adagio_exam_question <xsl:value-of
      select="ancestor::qandadiv/@id"/>_<xsl:value-of
      select="count(preceding-sibling::qandaentry) + 1"/></xsl:attribute>
      <!-- Choose between MC and TF -->
      <xsl:choose>
	<xsl:when test="answer[@condition = 'open']">
          <!-- Open Question -->
          <xsl:call-template name="OPENquestion"/>
	</xsl:when>

        <xsl:when test="count(answer) = 1">
          <!-- TF Question -->
          <xsl:call-template name="TFQuestion_Answer"/>
        </xsl:when>

        <xsl:when test="count(answer) &gt; 1">
          <!-- MC Question -->
          <xsl:call-template name="MCquestion"/>
        </xsl:when>

      </xsl:choose>
    </div>
  </xsl:template>

  <!-- Heading for the TF Questions. It simply dumps a true / false table -->
  <xsl:template name="TFQuestion_Heading">
    <div class="adagio_exam_question_tf_heading">
      <div>
        <xsl:choose>
          <xsl:when test="$profile.lang='es'">Verdadero</xsl:when>
          <xsl:otherwise>True</xsl:otherwise>
        </xsl:choose>
      </div>
      <div>
        <xsl:choose>
          <xsl:when test="$profile.lang='es'">Falso</xsl:when>
          <xsl:otherwise>False</xsl:otherwise>
        </xsl:choose>
      </div>
    </div>
  </xsl:template>

  <!-- True/False squares + the statement in a row -->
  <xsl:template name="TFQuestion_Answer">
    <div class="adagio_exam_question_tf_answer">
      <xsl:call-template name="TF_answer_true_square"/>
      <xsl:call-template name="TF_answer_false_square"/>
      <div class="adagio_exam_question_tf_answer_text">
        <xsl:apply-templates select="question/node()"/>

        <xsl:if test="($adagio.testquestions.include.id = 'yes') or
                      ($adagio.testquestions.include.history = 'yes')">
          <div class="adagio_exam_question_metadata">
            <!-- If requested, include the metadata info -->
            <xsl:call-template name="dump-metadata" select="."/>

            <!-- If requested, include the history info -->
            <xsl:call-template name="dump-history" />
          </div>
        </xsl:if>
      </div>
    </div> <!-- End of adagio_exam_question_tf_answer -->
  </xsl:template>

  <!-- MC Question rendering -->
  <xsl:template name="MCquestion">
    <div class="adagio_exam_question_mc_text">
      <xsl:apply-templates select="question/node()"/>
    </div>

    <div class="adagio_exam_question_mc_answers">
      <xsl:choose>
	<xsl:when test="count(answer) &gt; 0">
	  <xsl:for-each select="answer">
	    <div class="adagio_exam_question_mc_answer">
	      <xsl:call-template name="MC_answer_square"/>
	      <div class="adagio_exam_question_mc_answer_text">
		<xsl:apply-templates />
	      </div>
	    </div>
	  </xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
	  <div>
	    <xsl:if test="question/@role">
	      <xsl:attribute name="style">height: <xsl:value-of
	      select="question/@role"/></xsl:attribute>
	    </xsl:if>
	  </div>
	</xsl:otherwise>
      </xsl:choose>
    </div>

    <xsl:if test="($adagio.testquestions.include.id = 'yes') or
                  ($adagio.testquestions.include.history = 'yes')">
      <div class="adagio_exam_question_metadata">
        <!-- If requested, include the metadata info -->
        <xsl:call-template name="dump-metadata" select="."/>

        <!-- If requested, include the history info -->
        <xsl:call-template name="dump-history" />
      </div>
    </xsl:if>
  </xsl:template>

  <!-- Open Question rendering -->
  <xsl:template name="OPENquestion">
    <div class="adagio_exam_question_open_text">
      <xsl:apply-templates select="question/node()"/>
    </div>

    <div class="adagio_exam_question_open_answer">
      <div>
	<xsl:if test="answer/@role">
	  <xsl:attribute name="style">height: <xsl:value-of
	  select="answer/@role"/></xsl:attribute>
	</xsl:if>
	<xsl:apply-templates select="answer/node()"/>
      </div>
    </div>

    <xsl:if test="($adagio.testquestions.include.id = 'yes') or
                  ($adagio.testquestions.include.history = 'yes')">
      <div class="adagio_exam_question_metadata">
        <!-- If requested, include the metadata info -->
        <xsl:call-template name="dump-metadata" select="."/>

        <!-- If requested, include the history info -->
        <xsl:call-template name="dump-history" />
      </div>
    </xsl:if>
  </xsl:template>

  <!-- Templates to draw answer squares -->
  <xsl:template name="TF_answer_true_square">
    <div class="adagio_exam_answer_square">
      <div>
        <xsl:if test="($adagio.testquestions.include.solutions = 'yes') and
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
    <div class="adagio_exam_answer_square">
      <div>
        <xsl:if test="($adagio.testquestions.include.solutions = 'yes') and
                      (contains(answer/@condition, 'Falso') or
                      contains(answer/@condition, 'False'))">
          <xsl:attribute name="class">solid_answer_square</xsl:attribute>
        </xsl:if>
      </div>
    </div>
  </xsl:template>
  <xsl:template name="MC_answer_square">
    <div class="adagio_exam_answer_square">
      <div>
        <xsl:if test="($adagio.testquestions.include.solutions = 'yes') and
                      (contains(@condition, 'Cierto') or
                      contains(@condition, 'Verdadero') or
                      contains(@condition, 'Correct') or
                      contains(@condition, 'True'))">
          <xsl:attribute name="class">solid_answer_square</xsl:attribute>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <!-- Dump element containing metadata -->
  <xsl:template name="dump-metadata">
    <!-- If requested, include the metadata info -->
    <xsl:if test="$adagio.testquestions.include.id = 'yes'">
      <div class="adagio_exam_question_author">
        <xsl:if test="ancestor-or-self::*/blockinfo/descendant-or-self::author">
          <p>
            <xsl:choose>
              <xsl:when test="$profile.lang='es'">Autor: </xsl:when>
              <xsl:otherwise>Author: </xsl:otherwise>
            </xsl:choose>
          </p>
          <p>
	    <xsl:for-each
	      select="ancestor-or-self::*/blockinfo/descendant-or-self::author">
	      <xsl:value-of
		select="personname/firstname/text()"/>
	      <xsl:text> </xsl:text>
	      <xsl:value-of
		select="personname/surname/text()"/>
	      <xsl:if test="count(following-sibling::author) &gt; 0">
		<xsl:text>/</xsl:text>
	      </xsl:if>
	    </xsl:for-each>
          </p>
        </xsl:if>
      </div>
      <!--
      <div class="adagio_exam_question_editions">
        <p>
          <xsl:choose>
            <xsl:when test="$profile.lang='es'">Ediciones: </xsl:when>
            <xsl:otherwise>Editions: </xsl:otherwise>
          </xsl:choose>
        </p>
        <xsl:for-each select="ancestor-or-self::*/blockinfo/printhistory/para">
          <p><xsl:value-of select="@revision"/></p>
        </xsl:for-each>
      </div>
      -->
    </xsl:if>
  </xsl:template>

  <!-- Dump element containing history -->
  <xsl:template name="dump-history">
    <xsl:if test="$adagio.testquestions.include.history = 'yes'">
      <div class="adagio_exam_question_history">
        <p>
          <xsl:choose>
            <xsl:when test="$profile.lang='es'">Estadísticas</xsl:when>
            <xsl:otherwise>Statistics</xsl:otherwise>
          </xsl:choose>
        </p>

        <table class="adagio_exam_question_history_table">
          <tr>
            <xsl:choose>
              <xsl:when test="$profile.lang='es'">
                <th>Edición</th>
                <th>Anotaciones</th>
              </xsl:when>
              <xsl:otherwise>
                <th>Edition</th>
                <th>Annotations</th>
              </xsl:otherwise>
            </xsl:choose>
          </tr>
          <tr>
            <xsl:choose>
              <xsl:when test="blockinfo/printhistory/para">
                <xsl:for-each select="blockinfo/printhistory/para">
                  <td><xsl:value-of select="@revision"/></td>
                  <td>
                    <xsl:for-each select="phrase">
                      <xsl:if test="position() != 1">
                        <xsl:text>, </xsl:text>
                      </xsl:if>
                      <xsl:value-of select="@condition"/>:
                      <xsl:text> </xsl:text>
                      <xsl:value-of select="text()"/>
                    </xsl:for-each>
                  </td>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <td colspan="6">No information available</td>
              </xsl:otherwise>
            </xsl:choose>
          </tr>
        </table>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- The blockinfo needs to be matched to avoid to appear in the output -->
  <xsl:template match="blockinfo"/>
</xsl:stylesheet>
