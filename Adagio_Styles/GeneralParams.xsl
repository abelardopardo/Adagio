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

  <!-- Customization variables and their default values -->
  <xsl:param name="adagio.publish.host"
             description="Host where the material is published"/>
  <xsl:param name="adagio.publish.dir"
             description="Directory in adagio.publish.host where the material is published"/>

  <xsl:param name="adagio.institution.name"
             description="Your institution name">Your institution name</xsl:param>

  <xsl:param name="adagio.institution.url" description="Your institution URL"/>

  <xsl:param name="adagio.project.home.url" description="URL pointing to the course"/>

  <xsl:param name="adagio.project.icon"
             description="Image representing the course icon (typically 16x16)"/>
  <xsl:param name="adagio.project.icon.type"
             description="mime-type of the previous file"
             select="'image/x-icon'" />

  <xsl:param name="adagio.project.degree"
             description="Degree to which this course belongs">Degree Name</xsl:param>

  <xsl:param name="adagio.project.degree.url"
             description="URL pointing to a page for the degree to which this course belongs"/>

  <xsl:param name="adagio.project.edition"
             description="Something such as Fall 20?? or Spring 20??"/>

  <xsl:param name="adagio.project.edition.url"
             description="URL pointing to this edition course"/>

  <xsl:param name="adagio.project.image"
             description="URL pointing to a larger image of the course"/>

  <xsl:param name="adagio.project.name"
             description="Course name">adagio.project.name</xsl:param>

  <xsl:param name="adagio.project.short.edition"
             description="Abbreviation of the course edition (e.g Fall??)"/>

  <xsl:param name="adagio.project.short.name"
             description="Abbreviation of the course name (e.g. CS4703)"/>

  <xsl:param name="adagio.project.year"
             description="Year where the course is taking place"/>

</xsl:stylesheet>
