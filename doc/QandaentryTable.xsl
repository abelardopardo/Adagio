<?xml version="1.0" encoding="ASCII"?>

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
    xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
    xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="doc"
    version="1.0">

  <xsl:import href="DocbookProfile.xsl"/>

  <xsl:import href="DublinCore.xsl"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <!-- Include DC descriptor -->
  <xsl:param name="ada.dc.include.descriptors">yes</xsl:param>

  <!-- Include DC descriptor -->
  <xsl:param name="ada.version" />

  <!-- Replace title placeholder by version number -->
  <xsl:template match="phrase[@condition = 'ada_version']">
    (Version <xsl:value-of select="$ada.version"/>)
  </xsl:template>

  <xsl:template match="qandaentry">
    <tr>
      <td>
        <table class="qandaentry">
          <xsl:apply-templates/>
          <tr>
            <td colspan="2">
              <a class="xref">
                <xsl:attribute name="href">#<xsl:value-of select="ancestor::section/@id"/></xsl:attribute>
                <xsl:attribute name="title"><xsl:value-of select="ancestor::section/title/text()"/></xsl:attribute>
                Top of the Section
              </a>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
