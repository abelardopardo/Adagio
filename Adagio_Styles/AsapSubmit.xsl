<?xml version="1.0" encoding="UTF-8"?>

<!--
  Copyright (C) 2008 Carlos III University of Madrid
  This file is part of the Adagio: Agile Distributed Authoring Toolkit

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
  <xsl:import href="AsapSubmitParams.xsl"/>
  <xsl:import href="Forms.xsl"/>

  <!-- ============================================================ -->
  <!--                                                              -->
  <!--         Create a form to submit data through ASAP            -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template match="chapter[contains(@condition, 'adagio.asap.submission.page')]|
                       section[contains(@condition, 'adagio.asap.submission.page')]">
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
        <h3 class="adagio_asap_submit_deadline">
          <xsl:choose>
            <xsl:when test="$profile.lang='es'">Fecha de entrega: </xsl:when>
            <xsl:otherwise>Deadline: </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates
            select="note[@condition='AdminInfo']/para[@condition='handindate']/node()"/>
        </h3>
      </xsl:if>

      <!-- Insert countdown if proper element is found in the text -->
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
        <p class="adagio_countdown">
          <xsl:call-template name="adagio.page.countdown.insert">
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

      <!-- Insert the defined header links in HeaderLinks -->
      <xsl:call-template name="adagio.insert.header.links"/>

      <!-- If a verification JS is given, insert the script element -->
      <xsl:if test="$adagio.submit.asap.verifyemail.js != ''">
        <xsl:element name="script">
          <xsl:attribute name="type">text/javascript</xsl:attribute>
          <xsl:attribute name="src"><xsl:value-of
          select="$adagio.submit.asap.verifyemail.js"/></xsl:attribute>
          <xsl:text> </xsl:text>
        </xsl:element>
      </xsl:if>

      <!-- Create the submission form -->
      <xsl:element name="form">
        <xsl:attribute name="id">submit_form</xsl:attribute>
        <xsl:attribute name="method">post</xsl:attribute>
        <!-- Action is taken from the document element -->
        <xsl:attribute name="action">
          <xsl:value-of
            select="note[@condition='AdminInfo']/para[@condition='processor']/text()"/>
        </xsl:attribute>
        <!-- onsubmit is manipulated to execute the email verifier -->
        <xsl:if test="$adagio.submit.asap.verifyemail.js != ''">
          <xsl:attribute name="onsubmit">return check_form(this)</xsl:attribute>
        </xsl:if>
        <xsl:attribute name="enctype">multipart/form-data</xsl:attribute>

        <!--
             If there is a note with the condition text.before.author.box
             render it
             -->
        <xsl:apply-templates
          select="descendant::note[@condition='text.before.author.box']/node()"/>

        <!-- Create the author box -->
        <xsl:call-template name="adagio.asap.author.box"/>

        <!-- Div element with the payload to be submitted -->
        <xsl:variable name="submit.count"
          select="count(//section[@condition='adagio_submit_info']) +
                  count(//note[@condition='adagio_submit_info'])"/>

        <xsl:if test="$submit.count != 0">
          <!--
               If there is a note with the condition text.before.author.box
               render it
               -->
          <xsl:apply-templates
            select="descendant::note[@condition='text.before.payload.box']/node()"/>

          <div class="adagio_asap_payload_box">
            <xsl:for-each select="//section[@condition='adagio_submit_info']|
                                  //note[@condition='adagio_submit_info']">
              <div class="adagio_asap_author_box_row_payload">
                <xsl:choose>
                  <xsl:when test="$submit.count &gt; 1">
                    <div class="adagio_asap_author_box_data_a">
                      <xsl:apply-templates select="title/node()"/>
                    </div>
                    <div class="adagio_asap_author_box_data_b">
                      <xsl:apply-templates/>
                    </div>
                  </xsl:when>
                  <xsl:otherwise>
                    <div class="adagio_asap_author_box_data">
                      <xsl:apply-templates/>
                    </div>
                  </xsl:otherwise>
                </xsl:choose>
              </div>
            </xsl:for-each>
          </div>
        </xsl:if>

        <!-- If a generic comment text area is requested, introduce it -->
        <xsl:if test="$adagio.submit.add.textarea.comment = 'yes'">
          <div class="adagio_submit_textarea_comment">
            <p>
              <xsl:choose>
                <xsl:when test="$profile.lang='es'">Comentarios</xsl:when>
                <xsl:otherwise>Remarks</xsl:otherwise>
              </xsl:choose>
            </p>

            <textarea name="adagio_submit_form_remarks" cols="80" rows="5"/>
          </div>
        </xsl:if>

        <!-- Submit button -->
        <div class="adagio_asap_submit_button">
          <xsl:choose>
            <xsl:when test="$profile.lang='es'">
              <input value="Enviar" type="submit" name="submit"></input>
            </xsl:when>
            <xsl:otherwise>
              <input value="Submit" type="submit" name="submit"></input>
            </xsl:otherwise>
          </xsl:choose>
        </div>
      </xsl:element> <!-- End of form element -->

      <!-- If confirmation email has been inserted, render the explanation -->
      <xsl:if test="$adagio.asap.confirmation.email = 'yes'">
        <div class="adagio_asap_submit_confirmation_email">
          <sup>*</sup>
          <xsl:choose>
            <xsl:when test="$profile.lang='es'">
              Dirección a la que se envía un correo con los datos
              entregados. Las direcciones deben ser <i>completas</i> y
              <i>separadas por comas</i>.
            </xsl:when>
            <xsl:otherwise>
              Address to send an email with the submitted
              data. Include only
              <i>complete</i> and <i>comma separated</i>
              email addresses.
            </xsl:otherwise>
          </xsl:choose>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

</xsl:stylesheet>
