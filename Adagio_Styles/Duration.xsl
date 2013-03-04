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
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:exsl="http://exslt.org/common"
                xmlns:str="http://exslt.org/strings"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                version="1.0" exclude-result-prefixes="exsl str xi">

  <xsl:param name="adagio.submit.duration.phrase"/>
  <xsl:param name="adagio.submit.duration.ignore">no</xsl:param>
  <xsl:param name="adagio.submit.duration.where">where</xsl:param>
  <xsl:param name="adagio.submit.duration.howlong">how_long</xsl:param>

  <!-- ============================================================ -->
  <!--                                                              -->
  <!--                     Process Duration element                 -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template name="adagio.submit.duration.input"
                match="remark[@condition='adagio_submit_duration']|
                       section[@condition='adagio_submit_duration']">

    <!-- Duration value -->
    <xsl:param name="duration-value">
      <xsl:choose>
        <xsl:when test="*[@condition='duration']"><xsl:value-of
        select="*[@condition='duration']/text()"/></xsl:when>
        <xsl:otherwise>30</xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <xsl:param name="form-action"><xsl:value-of
    select="$adagio.submit.action.prefix"/><xsl:value-of
    select="*[@condition='action-suffix']"/></xsl:param>

    <!-- If the processing is enabled, proceed -->
    <xsl:if test="$adagio.submit.duration.ignore = 'no'">
      <!-- Name for the field -->
      <xsl:variable name="hierarchy">
        <xsl:call-template name="getHierarchy"/>
      </xsl:variable>

      <div class="adagio_submit_form_duration_select">
        <xsl:element name="form">
          <xsl:attribute name="id"><xsl:value-of
          select="$hierarchy"/></xsl:attribute>
          <xsl:attribute name="method">post</xsl:attribute>
          <xsl:attribute name="enctype">multipart/form-data</xsl:attribute>
          <xsl:attribute name="action"><xsl:value-of
          select="$form-action"/></xsl:attribute>
          <xsl:choose>
            <xsl:when test="$adagio.submit.duration.phrase and
                            ($adagio.submit.duration.phrase != '')">
              <xsl:value-of select="$adagio.submit.duration.phrase"/><xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$profile.lang='es'">Dedicación: </xsl:when>
                <xsl:otherwise>Dedication: </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>

	  <input type="hidden">
            <xsl:attribute name="name">
              <xsl:value-of select="$adagio.submit.duration.where"/>
            </xsl:attribute>
            <xsl:attribute name="value">
              <xsl:value-of select="$hierarchy"/>
            </xsl:attribute>
	  </input>

          <select>
            <xsl:attribute name="name">
              <xsl:value-of select="$adagio.submit.duration.howlong"/>
            </xsl:attribute>

            <!-- Less than haf of value -->
            <xsl:element name="option">
              <xsl:attribute name="value">LT-<xsl:value-of
              select="$duration-value * 0.5"/></xsl:attribute>
              <xsl:choose>
                <xsl:when test="profile.lang = 'es'">Menos de </xsl:when>
                <xsl:otherwise>Less than </xsl:otherwise>
              </xsl:choose>
              <xsl:value-of select="$duration-value * 0.5"/>
            </xsl:element>

            <!-- Half the given value -->
            <xsl:element name="option">
              <xsl:attribute name="value"><xsl:value-of select="$duration-value *
              0.5"/></xsl:attribute>
              <xsl:value-of select="$duration-value * 0.5"/>
            </xsl:element>

            <!-- 3/4 of given value -->
            <xsl:element name="option">
              <xsl:attribute name="value"><xsl:value-of select="$duration-value *
              0.75"/></xsl:attribute>
              <xsl:value-of select="$duration-value * 0.75"/>
            </xsl:element>

            <!-- Exact given value -->
            <xsl:element name="option">
              <xsl:attribute name="selected">selected</xsl:attribute>
              <xsl:attribute name="value"><xsl:value-of select="$duration-value"/></xsl:attribute>
              <xsl:attribute name ="selected">selected</xsl:attribute>
              <xsl:value-of select="$duration-value"/>
            </xsl:element>

            <!-- 1.25 times the given value -->
            <xsl:element name="option">
              <xsl:attribute name="value"><xsl:value-of select="$duration-value *
              1.25"/></xsl:attribute>
              <xsl:value-of select="$duration-value * 1.25"/>
            </xsl:element>

            <!-- 1.5 times the given value -->
            <xsl:element name="option">
              <xsl:attribute name="value"><xsl:value-of select="$duration-value *
              1.5"/></xsl:attribute>
              <xsl:value-of select="$duration-value * 1.5"/>
            </xsl:element>

            <!-- Greater than 1.5 times the given value -->
            <xsl:element name="option">
              <xsl:attribute name="value">GT-<xsl:value-of select="$duration-value *
              1.5"/></xsl:attribute>
              <xsl:choose>
                <xsl:when test="profile.lang = 'es'">Más de </xsl:when>
                <xsl:otherwise>More than </xsl:otherwise>
              </xsl:choose>
              <xsl:value-of select="$duration-value * 1.5"/>
            </xsl:element>
            </select> mins.

            <!-- Submit button -->
            <input type="submit">
              <xsl:if test="not(phrase[@condition='hide']) or
                            (phrase[@condition='hide'] = 'yes')">
                <xsl:attribute
                  name="onclick">this.form.target='adagio_submit_form_hidden_iframe_<xsl:value-of
                  select="$hierarchy"/>';this.form.style.display='none';</xsl:attribute>
              </xsl:if>
              <xsl:attribute name="value">Ok</xsl:attribute>
            </input>
            <xsl:if test="not(phrase[@condition='hide']) or
                          (phrase[@condition='hide'] = 'yes')">
              <!--
                  Invisible frame to receive the answer from the submission. This
                  trick is to avoid the page content being disturbed by the answer
                  received from the server -->
              <iframe src="about:blank"
                      style="display:none; width:0px; height:0px">
                <xsl:attribute
                  name="name">adagio_submit_form_hidden_iframe_<xsl:value-of select="$hierarchy"/></xsl:attribute>
              </iframe>
            </xsl:if>
        </xsl:element>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- Get the path to the current node using @id if exists -->
  <xsl:template name="getHierarchy">
    <xsl:for-each select="ancestor::*">
      <xsl:choose>
        <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="name()" />
        </xsl:otherwise>
        </xsl:choose><xsl:text>_</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- Ignore duration section for toc purposes -->
  <xsl:template match="section[@condition = 'adagio_submit_duration']" mode="toc"/>

</xsl:stylesheet>
