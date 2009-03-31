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
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">

  <xsl:import href="AdaProfile.xsl" />

  <xsl:param name="mergesheets.file.to.fold" select="''"/>

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <!-- Params needed by AdaProfile -->
  <xsl:param name="stylesheet.result.type" select="'xhtml'"/>
  <xsl:param name="profile.baseuri.fixup" select="false()"/>

  <xsl:param name="ada.profile.suppress.profiling.attributes">yes</xsl:param>

  <xsl:template match="xsl:stylesheet">
    <xsl:variable name="mergesheet_files">
      <tokens xmlns="">
        <xsl:copy-of
          select="str:tokenize(normalize-space($mergesheets.master.style),
                  ' ')"/>
      </tokens>
    </xsl:variable>

    <xsl:copy>
      <xsl:copy-of select="@*"/>
      
      <xsl:element name="xsl:import">
        <xsl:attribute name="href">
          <xsl:value-of select="$mergesheets.file.to.fold"/>
        </xsl:attribute>
      </xsl:element>

      <xsl:for-each select="exsl:node-set($mergesheet_files)/tokens/token">
        <xsl:element name="xsl:import">
          <xsl:attribute name="href">
            <xsl:value-of select="text()"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
