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
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl str xi">

  <xsl:output method="xml" indent="yes" encoding="UTF-8"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <xsl:template match="xsl:stylesheet">
    <informaltable frame="all">
      <tgroup rowsep="1" colsep="1" cols="3">
        <colspec colnum="1" colname="col1" align="left"/>
        <colspec colnum="2" colname="col2" align="left"/>
        <colspec colnum="3" colname="col3" align="center"/>
        <thead>
          <row>
            <entry align="center">Name</entry>
            <entry align="center">Description</entry>
            <entry align="center">Default value</entry>
          </row>
        </thead>
        <tbody>
          <xsl:for-each select="descendant::xsl:param[@description != '']">
            <row>
              <entry>
                <varname>
                  <xsl:value-of select="@name"/>
                </varname>
              </entry>
              <entry>
                <xsl:value-of select="@description"/>
              </entry>
              <entry>
                <xsl:choose>
                  <xsl:when test="@select">
                    <xsl:value-of select="@select"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="text()"/>
                  </xsl:otherwise>
                </xsl:choose>
              </entry>
            </row>
          </xsl:for-each>
        </tbody>
      </tgroup>
    </informaltable>
  </xsl:template>
</xsl:stylesheet>
