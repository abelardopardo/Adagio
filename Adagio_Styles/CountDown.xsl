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
  version="1.0" exclude-result-prefixes="exsl">

  <xsl:param name="adagio.page.countdown.js"/>

  <xsl:template name="adagio.page.countdown.insert">
    <xsl:param name="countdown.year"/>
    <xsl:param name="countdown.month"/>
    <xsl:param name="countdown.day"/>
    <xsl:param name="countdown.hour"/>
    <xsl:param name="countdown.minute"/>
    <xsl:if test="$adagio.page.countdown.js">
      <xsl:variable name="countDownDate">
        <xsl:value-of
          select="concat('20',$countdown.year,',',$countdown.month -1,
                  ',', $countdown.day, ',', $countdown.hour, ',',
                  $countdown.minute, ',00')"/>
      </xsl:variable>
      <xsl:variable name="script.src">
        <xsl:value-of
          select="concat('dateFuture = new Date(',
                  $countDownDate, ');')"/>
      </xsl:variable>
      <script type="text/javascript">
        <xsl:attribute name="src"><xsl:value-of
        select="$adagio.page.countdown.js"/></xsl:attribute>
      </script>
      <script type="text/javascript">
        <xsl:comment>
          <xsl:text>
          </xsl:text>
          <xsl:value-of select="$script.src"/>
          <xsl:text>
            //</xsl:text>
        </xsl:comment>
      </script>
      <span id="countbox">
        <xsl:if test="$profile.lang">
          <xsl:attribute name="lang">
            <xsl:value-of select="$profile.lang"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$profile.lang='en'">
            <xsl:attribute name="class">Deadline in</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">Faltan</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </span>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
