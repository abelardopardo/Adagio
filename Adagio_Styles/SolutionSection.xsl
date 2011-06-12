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

  <!-- Do not force the title, it is controlled internally -->
  <xsl:param name="admon.textlabel" select="0"/>

  <!-- Include the solutions for the exercises -->
  <xsl:param name="solutions.include.guide" select="'no'"
    description="yes/no variable to show the solution in the document"/>

  <xsl:param name="solutions.default.note.title">
    <xsl:choose>
      <xsl:when test="$profile.lang = 'es'">Solución</xsl:when>
      <xsl:otherwise>Solution</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:param name="solutions.default.phrase.title">
    <xsl:choose>
      <xsl:when test="$profile.lang = 'es'">Solución: </xsl:when>
      <xsl:otherwise>Solution: </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- Conditionally process section TOC -->
  <xsl:template match="section[@condition = 'solution']" mode="toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:if test="$solutions.include.guide = 'yes'">

      <xsl:call-template name="subtoc">
        <xsl:with-param name="toc-context" select="$toc-context"/>
        <xsl:with-param name="nodes"
          select="section|bridgehead[$bridgehead.in.toc != 0]"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Conditionally process section when chunked -->
  <xsl:template match="section[@condition = 'solution']">
    <xsl:if test="$solutions.include.guide = 'yes'">
      <xsl:variable name="depth" select="count(ancestor::section)+1"/>

      <!-- Removed to preserve backward compatibility with 1.69
      <xsl:call-template name="id.warning"/>
      -->

      <div class="{name(.)}_solution">
        <!-- Removed to preserve compatibility with 1.69 stylesheets.
        <xsl:apply-templates select="." mode="class.attribute"/>
        <xsl:call-template name="dir">
          <xsl:with-param name="inherit" select="1"/>
        </xsl:call-template>
        -->
        <xsl:call-template name="language.attribute"/>

        <xsl:call-template name="section.titlepage"/>

        <xsl:variable name="toc.params">
          <xsl:call-template name="find.path.params">
            <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:if test="contains($toc.params, 'toc')
                      and $depth &lt;= $generate.section.toc.level">
          <xsl:call-template name="section.toc">
            <xsl:with-param name="toc.title.p"
              select="contains($toc.params, 'title')"/>
          </xsl:call-template>
          <xsl:call-template name="section.toc.separator"/>
        </xsl:if>

        <xsl:apply-templates/>

        <xsl:call-template name="process.chunk.footnotes"/>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- Conditionally process the notes labeled with condition
       solution -->
  <xsl:template match="note[@condition='solution']">
    <xsl:if test="$solutions.include.guide = 'yes'">
      <div>
        <xsl:apply-templates select="." mode="class.attribute"/>
        <xsl:if test="$admon.style">
          <xsl:attribute name="style">
            <xsl:value-of select="$admon.style"/>
          </xsl:attribute>
        </xsl:if>

        <h3 class="title">
          <xsl:call-template name="anchor"/>
          <xsl:choose>
            <xsl:when test="title or info/title">
              <xsl:apply-templates select="." mode="object.title.markup"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$solutions.default.note.title"/>
            </xsl:otherwise>
          </xsl:choose>
        </h3>

        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- Process the phrase labeled with condition=solution -->
  <xsl:template match="phrase[@condition='solution']">
    <xsl:if test="$solutions.include.guide = 'yes'">
      <span class="solution">
        <xsl:copy-of select="$solutions.default.phrase.title"/>
      </span>
      <xsl:apply-templates />
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
