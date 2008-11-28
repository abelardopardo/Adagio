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
  version="1.0" exclude-result-prefixes="exsl str xi">
  
  <xsl:import href="BasicFunctions.xsl"/>
  <xsl:strip-space elements="*"/>

  <xsl:preserve-space elements="xsl:text"/>
   
  <xsl:output method="text" encoding="UTF-8" indent="no"/>

  <xsl:variable name="rep-node-set1">
    <replacements>
      <replacement search="&#10;">&#10;#</replacement>
    </replacements>
  </xsl:variable>
  
  <xsl:variable name="rep-node-set2">
    <replacements>
      <replacement search="#  ">#</replacement>
    </replacements>
  </xsl:variable>
  
  <xsl:template match="/projects">#
# Copyright (C) 2008 Carlos III University of Madrid
# This file is part of the ADA: Agile Distributed Authoring Toolkit

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor
# Boston, MA  02110-1301, USA.

#
# List of properties to include in the file Properties.txt
#
#
# The values that appear next to the equal sign are the default values. You 
# only need to include a new definition if it is different from the default 
# value.
#
# Whenever a list of files is required, unless otherswise noted, it is a comma
# or space separated of filenames (no paths).
#
# The value ${basedir} refers to the same location where the Properties.txt 
# file is.
#
# The variables ada.home and ada.course.home are defined respectively to the
# directory where ADA is installed, and the parent directory of the current
# one where the file AdaCourseParams.xml has been found (if any).
<xsl:apply-templates select="project"/>
  </xsl:template>

  <xsl:template match="project">
    <xsl:if test="description">
###########################################################################
<xsl:choose>
  <xsl:when test="function-available('str:replace')"># <xsl:value-of select="str:replace(str:replace(description/text(), '&#10;', 
      '&#10;#'), '#  ', '#')" />
  </xsl:when>
  <xsl:otherwise><xsl:variable name="first-change">
  <xsl:call-template name="str:_replace"><xsl:with-param name="string"
  select="description/text()"/><xsl:with-param name="replacements" 
  select="exsl:node-set($rep-node-set1)/replacements/replacement" /></xsl:call-template></xsl:variable># <xsl:call-template name="str:_replace"><xsl:with-param name="string"
    select="$first-change"/><xsl:with-param name="replacements" 
    select="exsl:node-set($rep-node-set2)/replacements/replacement"
    /></xsl:call-template>
  </xsl:otherwise>
</xsl:choose>
###########################################################################</xsl:if>
    <xsl:for-each select="descendant::property[@description != '']">
# <xsl:value-of select="@description"/>
# <xsl:value-of select="@name"/>=<xsl:value-of select="@value"/><xsl:text>
</xsl:text>
  </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
