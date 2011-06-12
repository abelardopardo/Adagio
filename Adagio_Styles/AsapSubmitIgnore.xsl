<?xml version="1.0" encoding="UTF-8"?>

<!--
  Copyright (C) 2008 Carlos III University of Madrid
  This file is part of Adagio: Agile Distributed Authoring Integrated Toolkit

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

  <!-- Prevent these sections from appearing in TOC -->
  <xsl:template match="section[@condition='adagio.asap.submission.page']"
                mode="toc" />
  <xsl:template match="section[@condition = 'adagio_submit_info']" mode="toc" />

  <xsl:template match="section[@condition='adagio_submit_info']|
                       note[@condition='adagio_submit_info']"/>

  <!-- this is in Forms, no longer in AsapSubmit
  <xsl:template match="note[@condition='adagio_submit_input']|
                       para[@condition='adagio_submit_input']|
                       remark[@condition='adagio_submit_input']"/>

  <xsl:template match="remark[@condition='adagio_submit_textarea_form']|
                       remark[@condition='adagio_submit_form']|
                       remark[@condition='adagio_submit_duration_form']"/>
  -->
  <xsl:template match="note[@condition = 'AdminInfo']"/>

  <!-- skip entirely processing of the submit sections -->
  <xsl:template match="section[@condition='adagio.asap.submission.page']"/>
  <xsl:template match="note[@condition='text.before.author.box']"/>
  <xsl:template match="note[@condition='text.before.payload.box']"/>

</xsl:stylesheet>
