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
  version="1.0" exclude-result-prefixes="exsl str xi">

  <xsl:import href="SubmitFormParams.xsl"/>

  <xsl:template name="ada.asap.submission.form">
    <xsl:param name="id">submit.form</xsl:param>
    <xsl:param name="method">post</xsl:param>
    <xsl:param name="enctype">multipart/form-data</xsl:param>
    <xsl:param name="action"><xsl:value-of
    select="$ada.form.default.action"/></xsl:param>
    <xsl:param name="onsubmit"/>

    <xsl:element name="form">
      <xsl:attribute name="id"><xsl:value-of
      select="$ada.form.default.form.id"/></xsl:attribute>
      <xsl:attribute name="method"><xsl:value-of select="$method"/></xsl:attribute>
      <xsl:attribute name="action"><xsl:value-of select="$action"/></xsl:attribute>
      <xsl:if test="$onsubmit and ($onsubmit != '')">
        <xsl:attribute name="onsubmit"><xsl:value-of
        select="$onsubmit"/></xsl:attribute>
      </xsl:if>
      <xsl:attribute name="enctype"><xsl:value-of
        select="$enctype"/></xsl:attribute>

      <!--
           If there is a note with the condition text.before.author.box
           render it
           -->
      <xsl:apply-templates
        select="descendant::note[@condition='text.before.author.box']/node()"/>

      <xsl:call-template name="ada.asap.author.box"/>

      <xsl:if test="$ada.submit.add.comment.textarea = 'yes'">
        <hr/>

        <table width="95%">
          <tr>
            <td align="center">
              <xsl:choose>
                <xsl:when test="$profile.lang='es'">
                  <h3>Comentarios</h3>
                </xsl:when>
                <xsl:otherwise>
                  <h3>Remarks</h3>
                </xsl:otherwise>
              </xsl:choose>
              <textarea name="comentarios" cols="80" rows="5"/>
            </td>
          </tr>
        </table>
      </xsl:if>

      <p class="ada_submit_button">
        <xsl:choose>
          <xsl:when test="$profile.lang='en'">
            <input value="Submit" type="submit"></input>
          </xsl:when>
          <xsl:otherwise>
            <input value="Enviar" type="submit"></input>
          </xsl:otherwise>
        </xsl:choose>
      </p>
    </xsl:element>
  </xsl:template>

  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  <xsl:template match="remark[@condition='teacher-comments']">
    <xsl:element name="form">
      <xsl:attribute name="id">submitDurationForm</xsl:attribute>
      <xsl:attribute name="method">post</xsl:attribute>
      <xsl:attribute name="enctype">multipart/form-data</xsl:attribute>
      <xsl:attribute name="action"><xsl:value-of
      select="$ada.fancyheading.feedback.url"/><xsl:value-of
      select="text()"/></xsl:attribute>

      <textarea cols="100" rows="20" name="teacher-comments"></textarea>

      <xsl:element name="input">
        <xsl:attribute name="type">hidden</xsl:attribute>
        <xsl:attribute name="name">teacher-comment-id</xsl:attribute>
        <xsl:attribute name="value"><xsl:value-of
        select="preceding::*[position()=1 and
        @condition='teacher-comment-id']/text()"/></xsl:attribute>
      </xsl:element>

      <input type="submit" value="Send"
      onclick="this.form.target='hiddeniFrame';this.form.style.display='none';"/>
      <iframe name="hiddeniFrame" src="about:blank"
        style="display:none; width:0px; height:0pxl"></iframe>
    </xsl:element>

  </xsl:template>


  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
  <xsl:template match="remark[@condition='duration-feedback']">
    <div class="duration-feedback">
      <xsl:element name="form">
        <xsl:attribute name="class">submitDurationForm</xsl:attribute>
        <xsl:attribute name="method">post</xsl:attribute>
        <xsl:attribute name="enctype">multipart/form-data</xsl:attribute>
        <xsl:attribute name="action"><xsl:value-of
        select="$ada.fancyheading.feedback.url"/><xsl:value-of
        select="text()"/></xsl:attribute>
        <select name="duration-feedback" >
          <xsl:element name="option">
            <xsl:attribute name="value">&lt;&lt;<xsl:value-of
            select="preceding::remark[@condition='duration' and
            position()='1']/text()*0.5"/>
            </xsl:attribute>
            &lt;&lt;<xsl:value-of select="preceding::remark[@condition='duration'
            and position()='1']/text()*0.5"/>
          </xsl:element>
          <xsl:element name="option">
            <xsl:attribute name="value">
              <xsl:value-of select="preceding::remark[@condition='duration' and
                                    position()='1']/text()*0.5"/>
            </xsl:attribute>
            <xsl:value-of select="preceding::remark[@condition='duration' and
                                  position()='1']/text()*0.5"/>
          </xsl:element>
          <xsl:element name="option">
            <xsl:attribute name="value">
              <xsl:value-of select="preceding::remark[@condition='duration' and
                                    position()='1']/text()*0.75"/>
            </xsl:attribute>
            <xsl:value-of select="preceding::remark[@condition='duration' and
                                  position()='1']/text()*0.75"/>
          </xsl:element>
          <xsl:element name="option">
            <xsl:attribute name="selected">selected</xsl:attribute>
            <xsl:attribute name="value">
              <xsl:value-of select="preceding::remark[@condition='duration' and
                                    position()='1']/text()"/>
            </xsl:attribute>
            <xsl:value-of select="preceding::remark[@condition='duration' and
                                  position()='1']/text()"/>
          </xsl:element>
          <xsl:element name="option">
            <xsl:attribute name="value">
              <xsl:value-of select="preceding::remark[@condition='duration' and
                                    position()='1']/text()*1.25"/>
            </xsl:attribute>
            <xsl:value-of select="preceding::remark[@condition='duration' and
                                  position()='1']/text()*1.25"/>
          </xsl:element>
          <xsl:element name="option">
            <xsl:attribute name="value">
              <xsl:value-of select="preceding::remark[@condition='duration' and
                                    position()='1']/text()*1.5"/>
            </xsl:attribute>
            <xsl:value-of select="preceding::remark[@condition='duration' and
                                  position()='1']/text()*1.5"/>
          </xsl:element>
          <xsl:element name="option">
            <xsl:attribute name="value">
              &gt;&gt;<xsl:value-of
              select="preceding::remark[@condition='duration' and
              position()='1']/text()*1.5"/>
            </xsl:attribute>
            &gt;&gt;<xsl:value-of select="preceding::remark[@condition='duration'
            and position()='1']/text()*1.5"/>
          </xsl:element>
        </select>
        <xsl:element name="input">
          <xsl:attribute name="type">hidden</xsl:attribute>
          <xsl:attribute name="name">title-hierarchy</xsl:attribute>
          <xsl:attribute name="value"><xsl:call-template
          name="printHierarchy"/></xsl:attribute>
        </xsl:element>

        <xsl:element name="input">
          <xsl:attribute name="type">hidden</xsl:attribute>
          <xsl:attribute name="name">duration</xsl:attribute>
          <xsl:attribute name="value">
            <xsl:value-of select="preceding::remark[@condition='duration' and
                                  position()='1']/text()"/>
          </xsl:attribute>
        </xsl:element>
        <input type="submit" value="Send"
          onclick="this.form.target='hiddeniFrame';this.form.style.display='none';"
          />
        <iframe name="hiddeniFrame" src="about:blank"
          style="display:none; width:0px; height:0pxl"></iframe>
      </xsl:element>
    </div>
  </xsl:template>

  <xsl:template name="printHierarchy">
      <xsl:for-each select="ancestor::section">
          <xsl:if test="ancestor::*[position()=1 and local-name()='chapter']">
               <xsl:value-of select="ancestor::*[position()=1 and local-name()='chapter']/title/phrase/text()" />
          </xsl:if>
          <xsl:text>--</xsl:text><xsl:value-of select="title/phrase/text()" />
      </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
