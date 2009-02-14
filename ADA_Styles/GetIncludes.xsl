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
  xmlns:html="http://www.w3.org/1999/xhtml"
  version="1.0" exclude-result-prefixes="exsl xi str">

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:template match="/">
    <xsl:apply-templates select="//*/xi:include[@href]"/>
    <xsl:apply-templates select="//*/xsl:import[@href]"/>
    <xsl:apply-templates select="document/material/include"/>
    <xsl:apply-templates select="//*/html:rss[@file]"/>
  </xsl:template>

  <xsl:template match="xi:include">
    <xsl:choose>
      <xsl:when test="@xml:base"><xsl:value-of
      select="@xml:base"/><xsl:if test="not(substring(@xml:base,
      string-length(@xml:base)) = '/')">/</xsl:if><xsl:value-of
      select="@href"/><xsl:text>
</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of
	  select="@href"/><xsl:text>
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xsl:import"><xsl:value-of
      select="@href"/><xsl:text>
    </xsl:text></xsl:template>

  <!-- match dependencies in prosper driver files -->
  <xsl:template match="document/material/include"><xsl:value-of
      select="normalize-space(text())"/><xsl:text>
    </xsl:text></xsl:template>

  <!-- match dependencies in prosper driver files -->
  <xsl:template match="document/material/include"><xsl:value-of
      select="normalize-space(text())"/><xsl:text>
</xsl:text></xsl:template>

  <!-- match RSS dependencies in XHTML files -->
  <xsl:template match="html:rss"><xsl:value-of
      select="@file"/><xsl:text>
</xsl:text></xsl:template>

</xsl:stylesheet>
