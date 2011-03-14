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
  version="1.0" exclude-result-prefixes="exsl">

  <xsl:template name="str:_replace">
     <xsl:param name="string"
                select="''" />
     <xsl:param name="replacements"
                select="/.." />
     <xsl:choose>
        <xsl:when test="not($string)" />
        <xsl:when test="not($replacements)">
           <xsl:value-of select="$string" />
        </xsl:when>
        <xsl:otherwise>
           <xsl:variable name="replacement"
                         select="$replacements[1]" />
           <xsl:variable name="search"
                         select="$replacement/@search" />
           <xsl:choose>
              <xsl:when test="not(string($search))">
                 <xsl:value-of select="substring($string, 1, 1)" />
                 <xsl:copy-of select="$replacement/node()" />
                 <xsl:call-template name="str:_replace">
                    <xsl:with-param name="string"
                                    select="substring($string, 2)" />
                    <xsl:with-param name="replacements"
                                    select="$replacements" />
                 </xsl:call-template>
              </xsl:when>
              <xsl:when test="contains($string, $search)">
                 <xsl:call-template name="str:_replace">
                    <xsl:with-param name="string"
                                    select="substring-before($string, $search)" />
                    <xsl:with-param name="replacements"
                                    select="$replacements[position() > 1]" />
                 </xsl:call-template>
                 <xsl:copy-of select="$replacement/node()" />
                 <xsl:call-template name="str:_replace">
                    <xsl:with-param name="string"
                                    select="substring-after($string, $search)" />
                    <xsl:with-param name="replacements"
                                    select="$replacements" />
                 </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                 <xsl:call-template name="str:_replace">
                    <xsl:with-param name="string"
                                    select="$string" />
                    <xsl:with-param name="replacements"
                                    select="$replacements[position() > 1]" />
                 </xsl:call-template>
              </xsl:otherwise>
           </xsl:choose>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
