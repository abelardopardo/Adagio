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

  <xsl:import href="HeadTail.xsl"/>

  <xsl:include href="TestQuestions.xsl"/>
  <xsl:include href="SolutionSection.xsl"/>
  <xsl:include href="PguideSection.xsl"/>
  <xsl:include href="AsapSubmitIgnore.xsl"/>

  <!-- This one for sure is needed in all documents -->
  <xsl:param name="xref.with.number.and.title" select="'0'"/>
  <xsl:param name="ada.exam.author"/>

  <xsl:include href="ExamParams.xsl"/>

<!--   <xsl:include href="removespanquote.xsl"/> -->

  <xsl:template match="section">
    <!-- Fetch the customization elements that are present in the document -->
    <xsl:variable name="part">
      <xsl:apply-templates select="para[@condition='part']"/>
    </xsl:variable>
    <xsl:variable name="duration" select="para[@condition='duration']/node()"/>
    <xsl:variable name="scoring"  select="para[@condition='scoring']/node()"/>
    <xsl:variable name="date"     select="para[@condition='date']/node()"/>
    <xsl:variable name="note"     select="para[@condition='note']/node()"/>
    <xsl:variable name="name"     select="para[@condition='name']"/>
    <xsl:variable name="score"    select="para[@condition='score']"/>

    <xsl:comment>Part heading</xsl:comment>

    <div id="ada_exam_heading">
      <!-- If cover is to be rendered in a single page, insert the page break -->
      <xsl:if test="$ada.exam.render.separate.cover = 'yes'">
        <xsl:attribute name="class">pageBreakAfter</xsl:attribute>
      </xsl:if>

      <!-- If the exam has a "part" label, stick it right at the top of the page -->
      <xsl:if test="$part">
        <div id="ada_exam_part_label">
          <xsl:copy-of select="$part"/>
          <xsl:if test="($ada.exam.include.id = 'yes') and (/section/@status)">
            (<xsl:value-of select="/section/@status"/>)
          </xsl:if>
        </div>
      </xsl:if>

      <!-- Include paragraph with duration, scoring, date and/or note -->
      <xsl:if test="$duration or $scoring or $date or $note">
        <xsl:comment>Duration/Score/Date</xsl:comment>
        <div id="ada_exam_notes_block">
          <!-- Duration -->
          <xsl:if test="$duration">
            <div class="ada_exam_note_block">
              <div class="ada_exam_note_title">
                <xsl:choose>
                  <xsl:when test="$profile.lang='en'">Duration: </xsl:when>
                  <xsl:otherwise>Duración: </xsl:otherwise>
                </xsl:choose>
              </div>
              <div class="ada_exam_note_data">
                <xsl:apply-templates select="$duration"/>
              </div>
            </div>
          </xsl:if>

          <!-- Scoring -->
          <xsl:if test="$scoring">
            <div class="ada_exam_note_block">
              <div class="ada_exam_note_title">
                <xsl:choose>
                  <xsl:when test="$profile.lang='en'">Score: </xsl:when>
                  <xsl:otherwise>Puntuación: </xsl:otherwise>
                </xsl:choose>
              </div>
              <div class="ada_exam_note_data">
                <xsl:apply-templates select="$scoring"/>
              </div>
            </div>
          </xsl:if>

          <!-- Date -->
          <xsl:if test="$date">
            <div class="ada_exam_note_block">
              <div class="ada_exam_note_title">
                <xsl:choose>
                  <xsl:when test="$profile.lang='en'">Date: </xsl:when>
                  <xsl:otherwise>Fecha: </xsl:otherwise>
                </xsl:choose>
              </div>
              <div class="ada_exam_note_data">
                <xsl:apply-templates select="$date"/>
              </div>
            </div>
          </xsl:if>

          <!-- Note -->
          <xsl:if test="$note">
            <div class="ada_exam_note_block">
              <div class="ada_exam_note_title">
                <xsl:choose>
                  <xsl:when test="$profile.lang='en'">Remarks: </xsl:when>
                  <xsl:otherwise>Nota: </xsl:otherwise>
                </xsl:choose>
              </div>
              <div class="ada_exam_note_data">
                <xsl:apply-templates select="$note"/>
              </div>
            </div>
          </xsl:if>
        </div>
      </xsl:if>

      <!-- Include a box to write the student first/last/id -->
      <xsl:if test="$name">
        <div id="ada_exam_name_surname">
          <!-- Last name -->
          <div class="ada_exam_name_block">
            <div class="ada_exam_name_title">
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">Last Name: </xsl:when>
                <xsl:otherwise>Apellidos: </xsl:otherwise>
              </xsl:choose>
            </div>
            <div class="ada_exam_name_data"/>
          </div>

          <!-- First name -->
          <div class="ada_exam_name_block">
            <div class="ada_exam_name_title">
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">First Name: </xsl:when>
                <xsl:otherwise>Nombre: </xsl:otherwise>
              </xsl:choose>
            </div>
            <div class="ada_exam_name_data"/>
          </div>

          <!-- Student ID -->
          <div class="ada_exam_name_block">
            <div class="ada_exam_name_title">
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">Student ID: </xsl:when>
                <xsl:otherwise>NIA: </xsl:otherwise>
              </xsl:choose>
            </div>
            <div class="ada_exam_name_data" />
          </div>
        </div>
      </xsl:if>

      <!-- Insert a box to fill with the scoring: Correct/Incorrect/Blank. Only
           suitable for tests.

           Possible improvement: provide several types of score boxes. Another one
           in which a bunch of boxes are created (given by a parameter) and a
           total box for the final score. All this controlled by a parameter.
           -->
      <xsl:if test="$score">
        <div id="ada_exam_score">
          <div class="ada_exam_score_title">
            <div>
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">Correct</xsl:when>
                <xsl:otherwise>Correctas</xsl:otherwise>
              </xsl:choose>
            </div>
            <div>
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">Incorrect</xsl:when>
                <xsl:otherwise>Incorrectas</xsl:otherwise>
              </xsl:choose>
            </div>
            <div>
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">No answer</xsl:when>
                <xsl:otherwise>Sin respuesta</xsl:otherwise>
              </xsl:choose>
            </div>
            <div>
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">Score</xsl:when>
                <xsl:otherwise>Nota</xsl:otherwise>
              </xsl:choose>
            </div>
          </div>
          <div class="ada_exam_score_data">
            <div/>
            <div/>
            <div/>
            <div/>
          </div>
        </div>
      </xsl:if>
    </div>

    <!-- Test questions within qandaset element -->
    <xsl:apply-templates select='qandaset/node()'/>

    <!-- Problems within a section element -->
    <xsl:for-each select="section/section">
      <xsl:if test="$ada.exam.exercise.name">
        <xsl:copy-of select="$ada.exam.exercise.name"/>
        <xsl:if test="count(preceding-sibling::section) +
                      count(following-sibling::section) &gt;= 1">
          <xsl:value-of select="count(preceding-sibling::section) + 1"/>.
        </xsl:if>
        <xsl:choose>
          <xsl:when test="@condition">
            <xsl:text> </xsl:text>
            <xsl:value-of select="@condition"/>
          </xsl:when>
          <xsl:when test="sectioninfo/subtitle">
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="sectioninfo/subtitle/node()"/>
          </xsl:when>
        </xsl:choose>
      </xsl:if>

      <xsl:apply-templates/>

      <xsl:if test="not(position() = last())">
        <hr width="100%"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>

