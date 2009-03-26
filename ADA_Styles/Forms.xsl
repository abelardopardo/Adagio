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
  <xsl:import href="FormsParams.xsl"/>

  <!-- ============================================================ -->
  <!--                                                              -->
  <!--                     Create Generic Form                      -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template match="remark[@condition='ada_submit_textarea_form']|
                       remark[@condition='ada_submit_form']|
                       para[@condition='ada_submit_form']|
                       remark[@condition='ada_submit_duration_form']">
    <xsl:param name="form-id">
      <xsl:choose>
        <xsl:when test="*[@condition='form-id']"><xsl:value-of
        select="*[@condition='form-id']/text()"/></xsl:when>
        <xsl:otherwise>ada_submit_input</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="form-method">
      <xsl:choose>
        <xsl:when test="*[@condition='form-method']"><xsl:value-of
        select="*[@condition='form-method']/text()"/></xsl:when>
        <xsl:otherwise>post</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="form-enctype">
      <xsl:choose>
        <xsl:when test="*[@condition='form-enctype']"><xsl:value-of
        select="*[@condition='form-enctype']/text()"/></xsl:when>
        <xsl:otherwise>multipart/form-data</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="form-action"><xsl:value-of
    select="$ada.submit.action.prefix"/><xsl:value-of
    select="*[@condition='action-suffix']"/></xsl:param>

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
          <xsl:when test="@condition='ada_submit_textarea_form'">
            <xsl:call-template name="ada.submit.textarea.input"/>
          </xsl:when>
          <xsl:when test="@condition='ada_submit_duration_form'">
            <xsl:call-template name="ada.submit.duration.input"/>
          </xsl:when>
          <xsl:when test="@condition='ada_submit_form'">
            <xsl:apply-templates />
          </xsl:when>
        </xsl:choose>

        <!-- Submit button -->
        <div class="ada_submit_button">
          <input type="submit">
            <xsl:if test="phrase[@condition='hide'] = 'yes'">
              <xsl:attribute
                name="onclick">this.form.target='ada_submit_form_hidden_iframe';this.form.style.display='none';</xsl:attribute>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="phrase[@condition='submit']">
                <xsl:attribute name="value"><xsl:value-of
                select="phrase[@condition = 'submit']"/></xsl:attribute>
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
          <iframe name="ada_submit_form_hidden_iframe" src="about:blank"
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
  <xsl:template match="note[@condition='ada_submit_input']|
                       para[@condition='ada_submit_input']|
                       remark[@condition='ada_submit_input']">
    <input class="ada_submit_form_input">
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
  <!--                  Process INPUT/RADIO note/para/remark        -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template match="note[@condition='ada_submit_scale']|
                       para[@condition='ada_submit_scale']|
                       remark[@condition='ada_submit_scale']">

    <!-- Name for the field -->
    <xsl:param name="scale-name">
      <xsl:choose>
        <xsl:when test="*[@condition='name']"><xsl:value-of
        select="*[@condition='name']/text()"/></xsl:when>
        <xsl:otherwise>ada_submit_scale_name</xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <div class="ada_submit_scale_table">
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
                <input class="ada_submit_form_scale" type="radio">
                  <xsl:attribute name="name">
                    <xsl:value-of select="$scale-name"/>
                  </xsl:attribute>
                  <xsl:attribute name="value">
                    <xsl:apply-templates/>
                  </xsl:attribute>
                </input>
              </td>
            </xsl:for-each>
          </tr>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <!-- ============================================================ -->
  <!--                                                              -->
  <!--               Process TEXTAREA note/para/phrase              -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template
    name="ada.submit.textarea.input"
    match="note[@condition='ada_submit_textarea']|
           para[@condition='ada_submit_textarea']|
           remark[@condition='ada_submit_textarea']">
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
        <xsl:otherwise>ada_submit_textarea_input</xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <div class="ada_submit_form_textarea">
      <!-- Dump the element -->
      <xsl:element name="textarea"><xsl:attribute name="rows"><xsl:value-of
      select="$textarea-rows"/></xsl:attribute>
      <xsl:attribute name="cols"><xsl:value-of
      select="$textarea-cols"/></xsl:attribute>
      <xsl:attribute name="name"><xsl:value-of
      select="$textarea-name"/></xsl:attribute><xsl:copy-of
      select="text()"/></xsl:element>
    </div>
  </xsl:template>

  <!-- ============================================================ -->
  <!--                                                              -->
  <!--                     Process Duration element                 -->
  <!--                                                              -->
  <!-- ============================================================ -->
  <xsl:template name="ada.submit.duration.input"
    match="remark[@condition='ada_submit_duration']">
    <!-- Duration value -->
    <xsl:param name="duration-value">
      <xsl:choose>
        <xsl:when test="*[@condition='duration']"><xsl:value-of
        select="*[@condition='duration']/text()"/></xsl:when>
        <xsl:otherwise>30</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <!-- Name for the field -->
    <xsl:param name="duration-name">
      <xsl:choose>
        <xsl:when test="*[@condition='name']"><xsl:value-of
        select="*[@condition='name']/text()"/></xsl:when>
        <xsl:otherwise>ada_submit_duration_input</xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <div class="ada_submit_form_duration_select">
      <select>
        <xsl:attribute name="name">
          <xsl:value-of select="$duration-name"/>
        </xsl:attribute>

        <!-- Less than haf of value -->
        <xsl:element name="option">
          <xsl:attribute name="value">&lt;&lt;<xsl:value-of
          select="$duration-value * 0.5"/></xsl:attribute>
          &lt;&lt;<xsl:value-of select="$duration-value * 0.5"/>
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
          <xsl:attribute name="value"><xsl:value-of
          select="$duration-value"/></xsl:attribute>
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
            <xsl:attribute name="value">&gt;&gt;<xsl:value-of select="$duration-value *
            1.5"/></xsl:attribute>
            &gt;&gt;<xsl:value-of select="$duration-value * 1.5"/>
          </xsl:element>
        </select>
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

  <xsl:template match="phrase[@condition='action-suffix']"/>
  <xsl:template match="phrase[@condition='submit']"/>

</xsl:stylesheet>
