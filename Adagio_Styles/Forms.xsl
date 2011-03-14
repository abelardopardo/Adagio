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
  <xsl:import href="FormsParams.xsl"/>
  <xsl:import href="Duration.xsl"/>

  <!-- ============================================================ -->
  <!--                                                              -->
  <!--                     Create Generic Form                      -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template match="section[@condition='adagio_submit_form']|
                       para[@condition='adagio_submit_form']|
                       remark[@condition='adagio_submit_textarea_form']|
                       remark[@condition='adagio_submit_form']">
    <xsl:variable name="form-id">
      <xsl:choose>
        <xsl:when test="*[@condition='form-id']"><xsl:value-of
        select="*[@condition='form-id']/text()"/></xsl:when>
        <xsl:otherwise>adagio_submit_input</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="form-method">
      <xsl:choose>
        <xsl:when test="*[@condition='form-method']"><xsl:value-of
        select="*[@condition='form-method']/text()"/></xsl:when>
        <xsl:otherwise>post</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="form-enctype">
      <xsl:choose>
        <xsl:when test="*[@condition='form-enctype']"><xsl:value-of
        select="*[@condition='form-enctype']/text()"/></xsl:when>
        <xsl:otherwise>multipart/form-data</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="submit-onclick">
      <xsl:choose>
        <xsl:when test="*[@condition='submit-onclick']"><xsl:value-of
        select="*[@condition='submit-onclick']/text()"/></xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="form-action"><xsl:value-of
    select="$adagio.submit.action.prefix"/><xsl:value-of
    select="*[@condition='action-suffix']"/></xsl:variable>

    <!-- Create div element surrounding the form with class=@condition -->
    <div>
      <xsl:attribute name="class"><xsl:value-of select="@condition"/></xsl:attribute>
      <!-- Create the form -->
      <xsl:element name="form">
        <xsl:attribute name="id"><xsl:value-of select="$form-id"/></xsl:attribute>
        <xsl:attribute name="method"><xsl:value-of
        select="$form-method"/></xsl:attribute>
        <xsl:attribute name="enctype"><xsl:value-of
        select="$form-enctype"/></xsl:attribute>
        <xsl:attribute name="action"><xsl:value-of
        select="$form-action"/></xsl:attribute>

        <!-- Select among the different single item forms -->
        <xsl:choose>
          <xsl:when test="@condition='adagio_submit_textarea_form'">
            <xsl:call-template name="adagio.submit.textarea.input"/>
          </xsl:when>
          <xsl:when test="@condition='adagio_submit_form'">
            <xsl:apply-templates />
          </xsl:when>
        </xsl:choose>

        <!-- Submit button -->
        <div class="adagio_submit_button">
          <input type="submit">
	    <xsl:choose>
	      <xsl:when test="phrase[@condition='hide'] = 'yes'">
		<xsl:attribute
		  name="onclick">this.form.target='adagio_submit_form_hidden_iframe';this.form.style.display='none';<xsl:value-of select="$submit-onclick"/></xsl:attribute>
	      </xsl:when>
	      <xsl:when test="$submit-onclick != ''">
		<xsl:attribute name="onclick"><xsl:value-of
		  select="$submit-onclick"/></xsl:attribute>
	      </xsl:when>
	    </xsl:choose>

            <xsl:choose>
              <xsl:when test="*[@condition='submit']">
                <xsl:attribute name="value"><xsl:value-of select="*[@condition =
                'submit']"/></xsl:attribute><xsl:attribute
                name="name"><xsl:choose><xsl:when test="*[@condition =
                'submit']/@id"><xsl:value-of select="*[@condition =
                'submit']/@id"/></xsl:when><xsl:otherwise>submit</xsl:otherwise></xsl:choose></xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="$profile.lang='es'">
                    <xsl:attribute name="value">Enviar</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="value">Submit</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
		<xsl:attribute name="name">submit</xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
          </input>
        </div>

        <xsl:if test="phrase[@condition='hide'] = 'yes'">
          <!--
               Invisible frame to receive the answer from the submission. This
               trick is to avoid the page content being disturbed by the answer
               received from the server

               -->
          <iframe name="adagio_submit_form_hidden_iframe" src="about:blank"
            style="display:none; width:0px; height:0px"></iframe>
        </xsl:if>
      </xsl:element>
    </div>
  </xsl:template>

  <!-- ============================================================ -->
  <!--                                                              -->
  <!--                  Process INPUT note/para/phrase              -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template match="note[@condition='adagio_submit_input']|
                       para[@condition='adagio_submit_input']|
                       remark[@condition='adagio_submit_input']">
    <input class="adagio_submit_form_input">
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
    </input>
  </xsl:template>

  <!-- ============================================================ -->
  <!--                                                              -->
  <!--    Process INPUT/RADIO note/para/remark in its own table     -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template match="note[@condition='adagio_submit_scale']|
                       para[@condition='adagio_submit_scale']|
                       remark[@condition='adagio_submit_scale']">

    <!-- Name for the field -->
    <xsl:variable name="scale-name">
      <xsl:choose>
        <xsl:when test="*[@condition='name']"><xsl:value-of
        select="*[@condition='name']/text()"/></xsl:when>
        <xsl:otherwise>adagio_submit_scale_name</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div class="adagio_submit_scale_table">
      <table>
        <colgroup>
          <xsl:for-each select="phrase[@condition = 'value']">
            <col />
          </xsl:for-each>
        </colgroup>
        <thead>
          <tr>
            <xsl:choose>
              <xsl:when test="phrase[@condition = 'value-name']">
                <th><xsl:apply-templates /></th>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="phrase[@condition = 'value']">
                  <th><xsl:apply-templates /></th>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </tr>
        </thead>
        <tbody>
          <tr>
            <xsl:for-each select="phrase[@condition = 'value']">
              <td>
                <xsl:call-template name="adagio_render_scale_elements">
                  <xsl:with-param name="scale-name"><xsl:value-of
                  select="$scale-name"/></xsl:with-param>
                </xsl:call-template>
              </td>
            </xsl:for-each>
          </tr>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <!-- ============================================================ -->
  <!--                                                              -->
  <!--               Process INPUT/RADIO basic element              -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template match="para[@condition='adagio_submit_scale_element']|
                       remark[@condition='adagio_submit_scale_element']|
                       phrase[@condition='adagio_submit_scale_element']"
    name="adagio_render_scale_elements">
    <!-- Name for the field -->
    <xsl:variable name="scale-name">
      <xsl:choose>
        <xsl:when test="*[@condition='name']"><xsl:value-of
        select="*[@condition='name']/text()"/></xsl:when>
        <xsl:otherwise>adagio_submit_scale_name</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <input class="adagio_submit_form_scale" type="radio">
      <xsl:attribute name="name"><xsl:value-of
      select="$scale-name"/></xsl:attribute>
      <xsl:attribute name="value"><xsl:apply-templates
      select="*[@condition='value']"/></xsl:attribute><xsl:if
      test="@id"><xsl:attribute name="id"><xsl:value-of
      select="@id"/></xsl:attribute></xsl:if>
    </input>
  </xsl:template>
  <!-- ============================================================ -->
  <!--                                                              -->
  <!--               Process TEXTAREA note/para/phrase              -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template
    name="adagio.submit.textarea.input"
    match="note[@condition='adagio_submit_textarea']|
           para[@condition='adagio_submit_textarea']|
           remark[@condition='adagio_submit_textarea']">
    <!-- Number of columns: default 80 -->
    <xsl:param name="textarea-cols">
      <xsl:choose>
        <xsl:when test="*[@condition='cols']"><xsl:value-of
        select="*[@condition='cols']/text()"/></xsl:when>
        <xsl:otherwise>80</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <!-- Number of rows: default 20 -->
    <xsl:param name="textarea-rows">
      <xsl:choose>
        <xsl:when test="*[@condition='rows']"><xsl:value-of
        select="*[@condition='rows']/text()"/></xsl:when>
        <xsl:otherwise>20</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <!-- Name for the field -->
    <xsl:param name="textarea-name">
      <xsl:choose>
        <xsl:when test="*[@condition='name']"><xsl:value-of
        select="*[@condition='name']/text()"/></xsl:when>
        <xsl:otherwise>adagio_submit_textarea_input</xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <!-- On key up -->
    <xsl:param name="onKeyUp">
      <xsl:if test="*[@condition='onkeyup']"><xsl:value-of
      select="*[@condition='onkeyup']/text()"/></xsl:if>
    </xsl:param>
    <!-- On key down -->
    <xsl:param name="onKeyDown">
      <xsl:if test="*[@condition='onkeydown']"><xsl:value-of
      select="*[@condition='onkeydown']/text()"/></xsl:if>
    </xsl:param>

    <div class="adagio_submit_form_textarea">
      <!-- Dump the element -->
      <xsl:element name="textarea"><xsl:attribute name="rows"><xsl:value-of
      select="$textarea-rows"/></xsl:attribute><xsl:attribute
      name="cols"><xsl:value-of
      select="$textarea-cols"/></xsl:attribute><xsl:attribute
      name="name"><xsl:value-of
      select="$textarea-name"/></xsl:attribute><xsl:if
      test="not(normalize-space($onKeyUp) = '')"><xsl:attribute
      name="onKeyUp"><xsl:value-of
      select="$onKeyUp"/></xsl:attribute></xsl:if><xsl:if
      test="not(normalize-space($onKeyDown) = '')"><xsl:attribute
      name="onKeyDown"><xsl:value-of
      select="$onKeyDown"/></xsl:attribute></xsl:if><xsl:copy-of
      select="text()"/></xsl:element>
    </div>
  </xsl:template>

  <!-- ============================================================ -->
  <!--                                                              -->
  <!--                  Process SELECT note/para                    -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template match="note[@condition='adagio_submit_select']|
                       para[@condition='adagio_submit_select']">

    <!-- Name for the field -->
    <xsl:variable name="select-name">
      <xsl:choose>
        <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
        <xsl:otherwise>adagio_submit_select_input</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div class="adagio_submit_form_select">
      <xsl:call-template name="adagio_select_basic_processing">
        <xsl:with-param name="select-name">
          <xsl:value-of select="$select-name"/>
        </xsl:with-param>
      </xsl:call-template>
    </div>
  </xsl:template>

  <!-- ============================================================ -->
  <!--                                                              -->
  <!--           Process SELECT remark or basic elements            -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template name="adagio_select_basic_processing"
    match="remark[@condition='adagio_submit_select']">
    <!-- Name for the field -->
    <xsl:param name="select-name">
      <xsl:choose>
        <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
        <xsl:otherwise>adagio_submit_select_input</xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <select>
      <xsl:attribute name="name">
        <xsl:value-of select="$select-name"/>
      </xsl:attribute>
      <xsl:for-each select="*">
        <xsl:element name="option">
          <!-- If there is a condition attribute, turn it into value -->
          <xsl:if test="@condition">
            <xsl:attribute name="value"><xsl:value-of
            select="@condition"/></xsl:attribute>
          </xsl:if>
          <!-- Check the value given in role attribute -->
          <xsl:if test="contains(@role, 'selected')">
            <xsl:attribute name="selected">selected</xsl:attribute>
          </xsl:if>
          <xsl:if test="contains(@role, 'disabled')">
            <xsl:attribute name="disabled">disabled</xsl:attribute>
          </xsl:if>
          <xsl:apply-templates />
        </xsl:element>
      </xsl:for-each>
    </select>
  </xsl:template>

  <!-- The title of the section is to be ignored -->
  <xsl:template match="section[@condition='adagio_submit_form']/title"/>

  <xsl:template
    match="phrase[@condition='action-suffix']|para[@condition='action-suffix']"/>
  <xsl:template match="phrase[@condition='submit']|para[@condition='submit']"/>
  <xsl:template match="phrase[@condition='hide']|para[@condition='hide']"/>
  <xsl:template match="phrase[@condition='submit-onclick']|para[@condition='submit-onclick']"/>

  <xsl:template match="section[@condition = 'adagio_submit_form']" mode="toc"/>

</xsl:stylesheet>
