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

  <!-- Bring in all the parameters -->
  <xsl:import href="AsapAuthorBoxParams.xsl"/>

  <!-- ******************************************************************* -->
  <!--                                                                     -->
  <!-- Template to produce author box                                      -->
  <!--                                                                     -->
  <!-- ******************************************************************* -->
  <xsl:template name="adagio.asap.author.box">
    <div class="adagio_asap_author_box">
      <!-- for ( i = I ; i OPERATOR TESTVALUE; i += INCREMENT ) -->
      <!-- for ( i = 1 ; i &lt;= 4; i += 1 ) -->
      <xsl:call-template name="author.loop">
        <xsl:with-param name="i"         select="'1'"/>
        <xsl:with-param name="increment" select="'1'"/>
        <xsl:with-param name="operator"  select="'&lt;='"/>
        <xsl:with-param name="testValue" select="$adagio.asap.num.authors"/>
      </xsl:call-template>
      <xsl:if test="$adagio.asap.include.password = 'one'">
        <div class="adagio_asap_author_box_row_single_password">
          <div class="adagio_asap_author_box_data_a">
            <xsl:choose>
              <xsl:when test="$adagio.asap.num.authors &gt; 1">
                <xsl:choose>
                  <xsl:when test="$profile.lang='en'">
                    Any author password
                  </xsl:when>
                  <xsl:otherwise>Clave de un autor</xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="$profile.lang='en'">Password</xsl:when>
                  <xsl:otherwise>Clave</xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </div>
          <div class="adagio_asap_author_box_data_b">
            <input type="password" name="asap:password_0" size="20"/>
            <xsl:text> </xsl:text>
          </div>
        </div>
      </xsl:if>

      <xsl:if test="$adagio.asap.include.groupname = 'yes'">
        <div class="adagio_asap_author_box_row_groupname">
          <div class="adagio_asap_author_box_data_a">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">Group Nick</xsl:when>
              <xsl:otherwise>Nick de grupo</xsl:otherwise>
            </xsl:choose>
          </div>
          <div class="adagio_asap_author_box_data_b">
            <input type="text" name="__nick__" size="20">
              <xsl:if test="$adagio.asap.groupname.default.value != ''">
                <xsl:attribute name="value">
                  <xsl:value-of select="$adagio.asap.groupname.default.value"/>
                </xsl:attribute>
              </xsl:if>
            </input>
            <xsl:text> </xsl:text>
          </div>
        </div>
      </xsl:if>

      <xsl:if test="$adagio.asap.confirmation.email = 'yes'">
        <div class="adagio_asap_author_box_row_confirmation_email">
          <div class="adagio_asap_author_box_data_a">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">Confirmation Email</xsl:when>
              <xsl:otherwise>Email de confirmación</xsl:otherwise>
            </xsl:choose><sup>*</sup>
          </div>
          <div class="adagio_asap_author_box_data_b">
            <input type="text" name="asap:Email" size="40"/>
          </div>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- for ( i = I ; i OPERATOR TESTVALUE; i += INCREMENT ) -->
  <xsl:template name="author.loop">
    <!-- By default, this template does not perform any iteration -->
    <!-- for ( i = 1; i <= 0; i++) -->
    <xsl:param name="i"         select="1"/>
    <xsl:param name="increment" select="1"/>
    <xsl:param name="operator"  select="'&lt;='"/>
    <xsl:param name="testValue" select="0"/>

    <xsl:variable name="testPassed">
      <xsl:choose>
        <xsl:when test="starts-with($operator, '!=')">
          <xsl:if test="$i != $testValue">
            <xsl:text>true</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="starts-with($operator, '&lt;=')">
          <xsl:if test="$i &lt;= $testValue">
            <xsl:text>true</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="starts-with($operator, '&gt;=')">
          <xsl:if test="$i &gt;= $testValue">
            <xsl:text>true</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="starts-with($operator, '=')">
          <xsl:if test="$i = $testValue">
            <xsl:text>true</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="starts-with($operator, '&lt;')">
          <xsl:if test="$i &lt; $testValue">
            <xsl:text>true</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="starts-with($operator, '&gt;')">
          <xsl:if test="$i &gt; $testValue">
            <xsl:text>true</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">
            <xsl:text>Sorry, the loop emulator only </xsl:text>
            <xsl:text>handles six operators </xsl:text>
            <xsl:value-of select="$newline"/>
            <xsl:text>(&lt; | &gt; | = | &lt;= | &gt;= | !=). </xsl:text>
            <xsl:text>The value </xsl:text>
            <xsl:value-of select="$operator"/>
            <xsl:text> is not allowed.</xsl:text>
            <xsl:value-of select="$newline"/>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Within a valid iteration -->
    <xsl:if test="$testPassed='true'">
      <xsl:if test="$adagio.asap.num.authors &gt; 1">
        <div class="adagio_asap_author_box_row_author">
          <div class="adagio_asap_author_box_data_a">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">Author <xsl:value-of
              select="$i" /></xsl:when>
              <xsl:otherwise>Autor <xsl:value-of select="$i"/></xsl:otherwise>
            </xsl:choose>
          </div>
          <div class="adagio_asap_author_box_data_b"/>
        </div>
      </xsl:if>

      <!-- We cannot push the choose to the inside because there is
           always the possibility of having the value "none" which means,
           there should be no box with full name info
           -->
      <div class="adagio_asap_author_box_row_author_id">
        <xsl:choose>
          <xsl:when test="$adagio.asap.include.id = 'nia'">
            <div class="adagio_asap_author_box_data_a">
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">
                  Student ID (9 digits)
                </xsl:when>
                <xsl:otherwise>NIA (9 dígitos)</xsl:otherwise>
              </xsl:choose>
            </div>
            <div class="adagio_asap_author_box_data_b">
              <xsl:element name="input">
                <xsl:attribute name="type">text</xsl:attribute>
                <xsl:attribute name="size">25</xsl:attribute>
                <xsl:attribute name="maxlength">25</xsl:attribute>
                <xsl:attribute name="name">asap:id_<xsl:value-of select="$i - 1"/></xsl:attribute>
              </xsl:element>
            </div>
          </xsl:when>
          <xsl:when test="$adagio.asap.include.id = 'email'">
            <div class="adagio_asap_author_box_data_a">
              <xsl:choose>
                <xsl:when
                  test="$profile.lang='en'">Student Email</xsl:when>
                <xsl:otherwise>Correo de alumno</xsl:otherwise>
              </xsl:choose>
            </div>
            <div class="adagio_asap_author_box_data_b">
              <xsl:element name="input">
                <xsl:attribute name="type">text</xsl:attribute>
                <xsl:attribute name="size">25</xsl:attribute>
                <xsl:attribute name="maxlength">25</xsl:attribute>
                <xsl:attribute name="name">asap:id_<xsl:value-of select="$i - 1"/></xsl:attribute>
              </xsl:element>
            </div>
          </xsl:when>
          <xsl:when test="$adagio.asap.include.id = 'custom'">
            <div class="adagio_asap_author_box_data_a">
              <xsl:value-of select="$adagio.asap.id.text"/>
            </div>
            <div class="adagio_asap_author_box_data_b">
              <xsl:element name="input">
                <xsl:attribute name="type">text</xsl:attribute>
                <xsl:attribute name="size"><xsl:value-of
                select="$adagio.asap.id.field.length"/></xsl:attribute>
                <xsl:attribute name="maxlength"><xsl:value-of
                select="$adagio.asap.id.field.length"/></xsl:attribute>
                <xsl:attribute name="name">asap:id_<xsl:value-of select="$i - 1"/></xsl:attribute>
              </xsl:element>
            </div>
          </xsl:when>
        </xsl:choose>
      </div>

      <xsl:if test="$adagio.asap.include.password = 'all'">
        <div class="adagio_asap_author_box_row_password">
          <div class="adagio_asap_author_box_data_a">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">Password</xsl:when>
              <xsl:otherwise>Clave</xsl:otherwise>
            </xsl:choose>
          </div>
          <div class="adagio_asap_author_box_data_b">
            <xsl:element name="input">
              <xsl:attribute name="type">password</xsl:attribute>
              <xsl:attribute name="size">25</xsl:attribute>
              <xsl:attribute name="maxlength">25</xsl:attribute>
              <xsl:attribute name="name">asap:password_<xsl:value-of select="$i - 1"/></xsl:attribute>
            </xsl:element>
          </div>
        </div>
      </xsl:if>
      <xsl:if test="$adagio.asap.include.fullname = 'yes'">
        <div class="adagio_asap_author_box_row adagio_asap_author_box_fn">
          <div class="adagio_asap_author_box_data_a">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">First Name</xsl:when>
              <xsl:otherwise>Nombre</xsl:otherwise>
            </xsl:choose>
          </div>
          <div class="adagio_asap_author_box_data_b">
            <xsl:element name="input">
              <xsl:attribute name="type">text</xsl:attribute>
              <xsl:attribute name="size">20</xsl:attribute>
              <xsl:attribute name="name">asap:firstName_<xsl:value-of select="$i - 1"/></xsl:attribute>
            </xsl:element>
          </div>
        </div>
        <div class="adagio_asap_author_box_row_ln">
          <div class="adagio_asap_author_box_data_a">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">Last Name</xsl:when>
              <xsl:otherwise>Apellidos</xsl:otherwise>
            </xsl:choose>
          </div>
          <div class="adagio_asap_author_box_data_b">
            <xsl:element name="input">
              <xsl:attribute name="type">text</xsl:attribute>
              <xsl:attribute name="size">40</xsl:attribute>
              <xsl:attribute
                name="name">asap:lastName_<xsl:value-of select="$i - 1"/></xsl:attribute>
            </xsl:element>
          </div>
        </div>
      </xsl:if>

      <!-- Your logic should end here; don't change the rest of this        -->
      <!-- template!                                                        -->

      <!-- Now for the important part: we increment the index variable and  -->
      <!-- loop. Notice that we're passing the incremented value, not      -->
      <!-- changing the variable itself.                                   -->

      <xsl:call-template name="author.loop">
        <xsl:with-param name="i"         select="$i + $increment"/>
        <xsl:with-param name="increment" select="$increment"/>
        <xsl:with-param name="operator"  select="$operator"/>
        <xsl:with-param name="testValue" select="$testValue"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
