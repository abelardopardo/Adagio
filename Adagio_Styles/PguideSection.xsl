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

  <!-- Include professor guide text -->
  <xsl:param name="professorguide.include.guide" select="'no'"
    description="yes/no variable to show the professor guide info"/>

  <xsl:param name="professorguide.default.note.title">
    <xsl:choose>
      <xsl:when test="$profile.lang = 'es'">Guía del profesor</xsl:when>
      <xsl:otherwise>Teaching Guide</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <!-- Conditionally process section TOC -->
  <xsl:template match="section[@condition = 'professorguide']" mode="toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:if test="$professorguide.include.guide = 'yes'">

      <xsl:call-template name="subtoc">
        <xsl:with-param name="toc-context" select="$toc-context"/>
        <xsl:with-param name="nodes"
          select="section|bridgehead[$bridgehead.in.toc != 0]"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Conditionally process section when chunked -->
  <xsl:template match="section[@condition = 'professorguide']">
    <xsl:if test="$professorguide.include.guide = 'yes'">
      <xsl:variable name="depth" select="count(ancestor::section)+1"/>

      <!-- Removed to preserve backward compatibility with 1.69
        <xsl:call-template name="id.warning"/>
        -->

      <div>
        <xsl:call-template name="language.attribute"/>

        <xsl:apply-templates select="." mode="class.attribute"/>

        <!-- Removed to preserve compatibility with 1.69 stylesheets.
        <xsl:call-template name="dir">
          <xsl:with-param name="inherit" select="1"/>
        </xsl:call-template>
        -->

        <xsl:call-template name="section.titlepage"/>

        <xsl:variable name="toc.params">
          <xsl:call-template name="find.path.params">
            <xsl:with-param name="table"
              select="normalize-space($generate.toc)"/>
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
       professorguide -->
  <xsl:template match="note[@condition = 'professorguide']">
    <xsl:if test="$professorguide.include.guide = 'yes'">
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
              <xsl:value-of select="$professorguide.default.note.title"/>
            </xsl:otherwise>
          </xsl:choose>
        </h3>

        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- Process the phrase labeled with condition=professorguide -->
  <xsl:template match="phrase[@condition='professorguide']">
    <xsl:if test="$professorguide.include.guide = 'yes'">
      <xsl:apply-templates />
    </xsl:if>
  </xsl:template>

  <!-- Process the subtitle labeled with condition=professorguide -->
  <xsl:template match="subtitle[@condition='professorguide']" mode="titlepage.mode">
    <xsl:if test="$professorguide.include.guide = 'yes'">
      <h2>
        <xsl:apply-templates select="." mode="class.attribute"/>
        <xsl:apply-templates mode="titlepage.mode"/>
      </h2>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
