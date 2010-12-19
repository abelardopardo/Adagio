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
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi str">
  
  <xsl:import href="ExerciseSubmitParams.xsl"/>

  <xsl:import href="CountDown.xsl"/>
  <xsl:import href="HeaderLinks.xsl"/>
  <xsl:import href="Forms.xsl"/>

  <!-- Ignore the submit elements -->
  <xsl:import href="AsapSubmitIgnore.xsl"/>

  <!-- Math the top level -->
  <xsl:template match="chapter" name="exercise_top_element">
    <div>
      <xsl:apply-templates select="." mode="class.attribute"/>

      <!-- Title if present -->
      <xsl:call-template name="chapter.titlepage"/>

      <!-- Insert a header with the deadline if present in the document -->
      <xsl:if test="(note[@condition = 'AdminInfo']/para[@condition =
                    'handindate']/text() != '') and
                    ($solutions.include.guide != 'yes')">
        <div id="submission_date">
          <h2>
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                Submission Deadline:
              </xsl:when>
              <xsl:otherwise>
                Fecha de entrega:
              </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates
              select="note[@condition='AdminInfo']/para[@condition =
                      'handindate']/node()"/>
          </h2>
        </div>
      </xsl:if>

      <xsl:if
        test="(note[@condition = 'AdminInfo']/para[@condition =
              'handinlink']) and 
              ($solutions.include.guide != 'yes')">
        <div class="noprint" id="handin_link">
          <p>
            <xsl:apply-templates
              select="note[@condition = 'AdminInfo']/para[@condition =
                      'handinlink']/node()"/>
          </p>
        </div>
      </xsl:if>
      
      <!-- Insert countdown here -->
      <xsl:if
        test="note[@condition='AdminInfo']/para[@condition =
              'deadline.format']/text()">
        <xsl:variable name="deadlineparts">
          <tokens xmlns="">
            <xsl:copy-of
              select="str:tokenize(normalize-space(note[@condition =
                      'AdminInfo']/para[@condition =
                      'deadline.format']/text()), ' /')" />
          </tokens>
        </xsl:variable>
	<div id="countdown">
	  <p>
	    <xsl:call-template name="ada.page.countdown.insert">
	      <xsl:with-param name="countdown.year">
		<xsl:value-of
		  select="exsl:node-set($deadlineparts)/tokens/token[position()
			  = 4]/text()"/>
	      </xsl:with-param>
	      <xsl:with-param name="countdown.month">
		<xsl:value-of
		  select="exsl:node-set($deadlineparts)/tokens/token[position()
			  = 3]/text()"/>
	      </xsl:with-param>
	      <xsl:with-param name="countdown.day">
		<xsl:value-of
		  select="exsl:node-set($deadlineparts)/tokens/token[position()
			  = 2]/text()"/>
	      </xsl:with-param>
	      <xsl:with-param name="countdown.hour">
		<xsl:value-of
		  select="exsl:node-set($deadlineparts)/tokens/token[position()
			  = 5]/text()"/>
	      </xsl:with-param>
	      <xsl:with-param name="countdown.minute">
		<xsl:value-of
		  select="exsl:node-set($deadlineparts)/tokens/token[position()
			  = 6]/text()"/>
	      </xsl:with-param>
	    </xsl:call-template>
	  </p>
	</div> <!-- End of coutdown -->
      </xsl:if>

      <!-- Render the TOC if allowed AND top-level document -->
      <xsl:if test="$exercisesubmit.include.toc = 'yes' and
                    (count(ancestor::*) = 0)">
        <xsl:call-template name="section.toc" mode="toc"/>
      </xsl:if>
      
      <xsl:call-template name="ada.insert.header.links"/>

      <!-- Main content -->
      <xsl:apply-templates/>
    </div>
  </xsl:template>

</xsl:stylesheet>
