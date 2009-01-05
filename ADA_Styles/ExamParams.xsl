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
  xmlns="http://www.w3.org/1999/xhtml" version="1.0">

  <xsl:param name="section.autolabel" select="0"/>
  <xsl:param name="chapter.autolabel" select="0"/>

  <!-- Control the font family and size -->
  <xsl:param name="ada.exam.fontfamily" select="'Verdana'"/>
  <xsl:param name="ada.exam.fontsize" select="'10pt'"/>

  <!-- Show the qandadiv ID -->
  <xsl:param name="ada.exam.include.id" select="'no'"/>

  <!-- Insert a page break after the cover -->
  <xsl:param name="ada.exam.render.separate.cover" select="'yes'"/>

  <!-- Logo to use in the upper left corner -->
  <xsl:param name="ada.exam.topleft.image"/>
  <xsl:param name="ada.exam.topleft.image.alt"/>

  <!-- Text to include in the top left (next to icon) -->
  <xsl:param name="ada.exam.topleft.toptext"/>

  <!-- Text to include in the center left (next to icon) -->
  <xsl:param name="ada.exam.topleft.centertext"/>

  <!-- Text to include in the bottom left (next to icon) -->
  <xsl:param name="ada.exam.topleft.bottomtext"/>

  <!-- Text to include in the top right (next to icon) -->
  <xsl:param name="ada.exam.topright.toptext"/>

  <!-- Text to include in the center right (next to icon) -->
  <xsl:param name="ada.exam.topright.centertext"/>

  <!-- Text to include in the bottom right (next to icon) -->
  <xsl:param name="ada.exam.topright.bottomtext"/>

  <!-- Label to precede each exercise in a regular exam. -->
  <xsl:param name="ada.exam.exercise.name">VALUE OF ada.exam.exercise.name</xsl:param>
</xsl:stylesheet>
