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
  version="1.0" exclude-result-prefixes="exsl str xi">

  <xsl:param name="ada.asap.num.authors"       select="'2'"/>
  <!-- nia, email, none -->
  <xsl:param name="ada.asap.include.id"        select="'email'"/> 
  <xsl:param name="ada.asap.id.text"           select="'ID'"/>
  <xsl:param name="ada.asap.include.fullname"  select="'no'"/>
  <!-- all, none, one -->
  <xsl:param name="ada.asap.include.password"  select="'one'"/> 
  <xsl:param name="ada.asap.include.groupname" select="'no'"/>
  <xsl:param name="ada.asap.groupname.default.value"></xsl:param>
  <!-- yes, no -->
  <xsl:param name="ada.asap.confirmation.email" select="'yes'"/>
    
</xsl:stylesheet>
