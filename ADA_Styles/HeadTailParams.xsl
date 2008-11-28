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
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">
  
  <!-- Customization variables for Head and Tail -->
  <xsl:param name="ada.page.author" 
    description="Author to include in the meta element in HTML head"/>
  <xsl:param name="ada.page.cssstyle.url" 
    description="URL pointing to a CSS file to include in the HTML head"/>
  <xsl:param name="ada.page.google.analytics.account" 
    description="Account to include in the Google Analytics HTML snippet."/>
  <xsl:param name="ada.page.google.gadget.url" 
    description="Link pointing to a Google Gadget to be included in the upper
                 left corner of the page"/>
  <xsl:param name="ada.page.head.bigtitle" 
    description="yes/no to enable a big title on top of the page">no</xsl:param>
  <xsl:param name="ada.page.head.center.bottom" 
    description="Text to insert at the bottom row of the Header table"/>
  <xsl:param name="ada.page.head.center.top.logo" 
    description="URL to the image to show in the top center of the table
                 header"/>
  <xsl:param name="ada.page.head.center.top.logo.alt" 
    description="Alt attribute for the previous image"/>
  <xsl:param name="ada.page.head.center.top.logo.url" 
    description="URL to make the image a link"/>
  <xsl:param name="ada.page.head.left.logo"
    description="URL to the image to show in the left side of the table header"/>
  <xsl:param name="ada.page.head.left.logo.alt" 
    description="Alt attribute for the previous image"/>
  <xsl:param name="ada.page.head.left.logo.url"
    description="URL to make the image a link"/>
  <xsl:param name="ada.page.head.right.logo"
    description="URL to the image to show in the right side of the table header"/>
  <xsl:param name="ada.page.head.right.logo.alt" 
    description="Alt attribute for the previous image"/>
  <xsl:param name="ada.page.head.right.logo.url" 
    description="URL to make the image a link"/>
  <xsl:param name="ada.page.refresh.rate" 
    description="Include a refresh rate in the page header"/>
  <xsl:param name="ada.page.license.institution" select="'&#169; Carlos III University of Madrid, Spain'"/>
  <xsl:param name="ada.page.license" 
    description="Yes/no to include license information at the bottom of the
                 page">no</xsl:param>
  <xsl:param name="ada.page.license.name"
    description="Name of the license"/>
  <xsl:param name="ada.page.license.logo"
    description="URL to an image to accompany the license information"/>
  <xsl:param name="ada.page.license.alt" 
    description="Alt attribute for the previous image"/>
  <xsl:param name="ada.page.license.url" 
    description="URL to point when clicking in the license image"/>
  <xsl:param name="ada.page.show.lastmodified" 
    description="yes/no controlling if the last modified info is shown at
                 bottom">no</xsl:param>
</xsl:stylesheet>
