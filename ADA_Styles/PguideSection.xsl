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
  
  <!-- Include professor guide text --> 
  <xsl:param name="professorguide.include.guide" select="'no'"/>

  <!-- Background color for the professor guide box  --> 
  <xsl:param name="exercisesubmit.pguide.background.color" select="'#CCD0D6'"/>

  <!-- Prevent this section from appearing in TOC -->
  <xsl:template match="section[@condition='professorguide']" mode="toc" />

  <!-- Conditionally process the notes labeled with condition
       professorguide -->
  <xsl:template match="section[@condition = 'professorguide'] |
                       note[@condition = 'professorguide']">
    <xsl:if test="$professorguide.include.guide = 'yes'">
      <p>
        <table class="ada_pguide_table" cellpadding="10">
          <tr>
            <td>
              <xsl:choose>
                <xsl:when test="$profile.lang='en'">
                  <p><b>Professor Guide:</b></p>
                </xsl:when>
                <xsl:otherwise>
                  <p><b>Guía del profesor</b></p>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:apply-templates select="node()"/>
            </td>
          </tr>
        </table>
      </p>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
