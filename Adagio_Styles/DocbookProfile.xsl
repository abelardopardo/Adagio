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
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">

  <!-- This stylesheet is to include some default extensions when using docbook
       -->
  <xsl:import
     href="http://docbook.sourceforge.net/release/xsl/current/xhtml/profile-docbook.xsl"/>
  <xsl:import
     href="http://docbook.sourceforge.net/release/xsl/current/xhtml/manifest.xsl"/>

  <xsl:import href="es-modify.xsl"/>

  <!--
       Allows the inclusion in the audience attribute a date/time range in which
       the element is visible
       -->
  <xsl:import href="AdagioProfile.xsl"/>

  <!-- Allows the inclusion of Flash videos and MP3 -->
  <xsl:import href="FLVObj.xsl"/>

  <!-- Allows the inclusion of Flash videos and MP3 -->
  <xsl:import href="SWFObj.xsl"/>

  <!-- Needed for backward compatibility with Docbook stylesheets -->
  <xsl:param name="html.append"/>

  <!-- Do not include inline styles for admonitions -->
  <xsl:param name="admon.style"/>

</xsl:stylesheet>
