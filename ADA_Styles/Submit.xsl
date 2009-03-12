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
  
  <xsl:import href="HeadTail.xsl"/>
  <xsl:import href="CountDown.xsl"/>
  <xsl:import href="HeaderLinks.xsl"/>
  <xsl:import href="AsapAuthorBox.xsl"/>

  <xsl:import href="SubmitParams.xsl"/>

  <!-- NUKE ONCE EVERYTHING HAS BEEN IMPLEMENTED -->
  <xsl:variable name="ada.fancyheading.feedback.url"/>

  <!-- ============================================================ -->
  <!--                                                              -->
  <!--         Create a form to submit data through ASAP            -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template match="chapter[@condition='ada.asap.submission.page']|
                       section[@condition='ada.asap.submission.page']">
    <div>
      <xsl:apply-templates select="." mode="class.attribute"/>

      <!-- Title if present -->
      <xsl:choose>
        <xsl:when test="name()='section'">
          <xsl:call-template name="section.titlepage"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="chapter.titlepage"/>
        </xsl:otherwise>
      </xsl:choose>

      <!-- Insert a header with the deadline if present in the document -->
      <xsl:if
        test="note[@condition='AdminInfo']/para[@condition='handindate']/text() != ''">
        <h3 class="head-center">
          <xsl:choose>
            <xsl:when test="$profile.lang='en'">Deadline: </xsl:when>
            <xsl:otherwise>Fecha de entrega: </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates
            select="note[@condition='AdminInfo']/para[@condition='handindate']/node()"/>
        </h3>
      </xsl:if>

      <!-- Insert countdown here -->
      <xsl:if
        test="note[@condition='AdminInfo']/para[@condition='deadline.format']/text()">
        <xsl:variable name="deadlineparts">
          <tokens xmlns="">
            <xsl:copy-of
              select="str:tokenize(normalize-space(note[@condition =
                      'AdminInfo']/para[@condition = 'deadline.format']/text()),
                      ' /')"/>
          </tokens>
        </xsl:variable>
        <p class="ada_countdown">
          <xsl:call-template name="ada.page.countdown.insert">
            <xsl:with-param name="countdown.year">
              <xsl:value-of
                select="exsl:node-set($deadlineparts)/tokens/token[position() =
                        4]/text()"/>
            </xsl:with-param>
            <xsl:with-param name="countdown.month">
              <xsl:value-of
                select="exsl:node-set($deadlineparts)/tokens/token[position() =
                        3]/text()"/>
            </xsl:with-param>
            <xsl:with-param name="countdown.day">
              <xsl:value-of
                select="exsl:node-set($deadlineparts)/tokens/token[position() =
                        2]/text()"/>
            </xsl:with-param>
            <xsl:with-param name="countdown.hour">
              <xsl:value-of
                select="exsl:node-set($deadlineparts)/tokens/token[position() =
                        5]/text()"/>
            </xsl:with-param>
            <xsl:with-param name="countdown.minute">
              <xsl:value-of
                select="exsl:node-set($deadlineparts)/tokens/token[position() =
                        6]/text()"/>
            </xsl:with-param>
          </xsl:call-template>
        </p>
      </xsl:if>

      <xsl:call-template name="ada.insert.header.links"/>

      <xsl:if test="$ada.submit.asap.verifyemail.js != ''">
        <xsl:element name="script">
          <xsl:attribute name="type">text/javascript</xsl:attribute>
          <xsl:attribute name="src"><xsl:value-of
          select="$ada.submit.asap.verifyemail.js"/></xsl:attribute>
          <xsl:text> </xsl:text>
        </xsl:element>
      </xsl:if>


      <xsl:element name="form">
        <xsl:attribute name="id">submit.form</xsl:attribute>
        <xsl:attribute name="method">post</xsl:attribute>
        <xsl:attribute name="action">
          <xsl:value-of
            select="note[@condition='AdminInfo']/para[@condition='processor']/text()"/>
        </xsl:attribute>
        <xsl:if test="$ada.submit.asap.verifyemail.js != ''">
          <xsl:attribute name="onsubmit">return check_form(this)</xsl:attribute>
        </xsl:if>
        <xsl:attribute name="enctype">multipart/form-data</xsl:attribute>

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
                  <xsl:when test="$profile.lang='en'">
                    <h3>Remarks</h3>
                  </xsl:when>
                  <xsl:otherwise>
                    <h3>Comentarios</h3>
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

      <xsl:if test="$ada.asap.confirmation.email = 'yes'">
        <p>
          <sup>*</sup>
          <xsl:choose>
            <xsl:when test="$profile.lang='en'">
              Address to send an email with the submitted
              data. Include only
              <i>complete</i> and <i>comma separated</i>
              email addresses.
            </xsl:when>
            <xsl:otherwise>Dirección a la que se envía un correo con los
              datos entregados. Las direcciones deben
              ser <i>completas</i> y <i>separadas por comas</i>.
            </xsl:otherwise>
          </xsl:choose>
        </p>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- ============================================================ -->
  <!--                                                              -->
  <!--                  Process INPUT note/para/phrase              -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template match="note[@condition='input']|
                       para[@condition='input']|
                       phrase[@condition='input']">
    <xsl:if test="ancestor-or-self::*/@condition = 'submit'">
      <xsl:element name="input">
        <xsl:if test="*[@condition='type']">
          <xsl:attribute name="type">
            <xsl:value-of select="*[@condition='type']/text()"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="*[@condition='size']">
          <xsl:attribute name="size">
            <xsl:value-of select="*[@condition='size']/text()"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="*[@condition='maxlength']">
          <xsl:attribute name="maxlength">
            <xsl:value-of select="*[@condition='maxlength']/text()"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="*[@condition='accept']">
          <xsl:attribute name="accept">
            <xsl:value-of select="*[@condition='accept']/text()"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="*[@condition='name']">
          <xsl:attribute name="name">
            <xsl:value-of select="*[@condition='name']/text()"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="*[@condition='id']">
          <xsl:attribute name="id">
            <xsl:value-of select="*[@condition='id']/text()"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="*[@condition='value']">
          <xsl:attribute name="value">
            <xsl:value-of select="*[@condition='value']/text()"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <!-- ============================================================ -->
  <!--                                                              -->
  <!--               Process TEXTAREA note/para/phrase              -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template match="note[@condition='textarea']|
                       para[@condition='textarea']|
                       phrase[@condition='textarea']">
    <xsl:if test="ancestor-or-self::*/@condition = 'submit'">
      <xsl:element name="textarea">
        <xsl:if test="*[@condition='rows']">
          <xsl:attribute name="rows">
            <xsl:value-of select="*[@condition='rows']/text()"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="*[@condition='cols']">
          <xsl:attribute name="cols">
            <xsl:value-of select="*[@condition='cols']/text()"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="*[@condition='name']">
          <xsl:attribute name="name">
            <xsl:value-of select="*[@condition='name']/text()"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="text()"/>
      </xsl:element>
    </xsl:if>
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

  <!-- The title of the section is to be ignored -->
  <xsl:template match="section[@condition='submit']/title"/>

</xsl:stylesheet>
