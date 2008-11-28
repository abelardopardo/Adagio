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
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="exsl" version="1.0">
  
  <!-- Include the solutions for the exercises --> 
  <xsl:param name="solutions.include.guide" select="'no'"/>

  <!-- Prevent this section from appearing in TOC -->
  <xsl:template match="section[@condition='solution']"       mode="toc" />

  <!-- Conditionally process the sections/paragraphs labeled with condition
       solution -->
  <xsl:template match="section[@condition='solution'] | 
                       phrase[@condition='solution'] | 
                       note[@condition='solution']">
    <xsl:if test="$solutions.include.guide = 'yes'">
      <table class="ada_solution_table">
        <tr>
          <td style="border-right: 0.5pt solid ; border-bottom: 0.5pt solid ;">
            <xsl:choose>
              <xsl:when test="$profile.lang='en'">
                <p><b>Solution:</b></p>
              </xsl:when>
              <xsl:otherwise>
                <p><b>Solución:</b></p>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()"/>
          </td>
        </tr>
      </table>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
