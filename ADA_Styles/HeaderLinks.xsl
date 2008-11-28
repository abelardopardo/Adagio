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
  version="1.0" exclude-result-prefixes="exsl">

  <xsl:import href="AdaProfile.xsl"/>

  <xsl:param name="ada.page.header.links"/>

  <!-- Variable that takes either a para with
       condition="ada.page.header.links" or the value of the parameter (in
       this order) -->
  <xsl:template name="ada.insert.header.links">
    <xsl:variable name="ada.page.header.links.var">
      <xsl:choose>
        <xsl:when test="//*/note[@condition='AdminInfo']/para[@condition='ada.page.header.links']">
          <xsl:copy-of select="//*/note[@condition='AdminInfo']/para[@condition='ada.page.header.links']/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="exsl:node-set($ada.page.header.links)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:if test="$ada.page.header.links.var != ''">
      <div class="noprint head-center">
        <xsl:call-template name="ada.profile.subtree">
          <xsl:with-param name="subtree" 
            select="exsl:node-set($ada.page.header.links.var)/node()"/>
        </xsl:call-template>
        <hr class="head-center"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template 
    match="note[@condition='AdminInfo']"/>
</xsl:stylesheet>
