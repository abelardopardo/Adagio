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
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi str">

  <!-- Brings in all the default values -->
  <xsl:import href="Params.xsl"/>

<!--
    Prosper-specific params:
        * adagio.prosper.style: prosper style to apply.
        * adagio.prosper.lang: latex language to declare (e.g.: "es")
        * adagio.prosper.logo.enable: true to enable logo, false otherwise.
        * adagio.prosper.logo.width: scale the logo to the given width.
        * adagio.prosper.logo.pos: put the logo in the given position.
        * adagio.prosper.logo.file: eps/ps file of the logo.
-->

  <!-- Param defaults -->
  <xsl:param name="adagio.prosper.lang">en</xsl:param>
  <xsl:param name="adagio.prosper.logo.enable">no</xsl:param>
  <xsl:param name="adagio.prosper.logo.width">1cm</xsl:param>
  <xsl:param name="adagio.prosper.logo.pos">(-1.12,-1.25)</xsl:param>


  <xsl:output method="text" indent="no" encoding="UTF-8" />

  <xsl:template match="document">
\documentclass[pdf,<xsl:value-of select="$adagio.prosper.style"/>,slideColor,colorBG]{prosper}

\usepackage[utf8]{inputenc}


<xsl:if test="$adagio.prosper.lang='es'">
\usepackage[spanish,activeacute]{babel}
</xsl:if>

\usepackage{pstricks,pst-node,pst-text,pst-3d}
\usepackage{amsmath}

\usepackage{fancyvrb}

\newcommand{\todo}{\green [(pendiente)]}
\newcommand{\todom}[1]{\green[#1]}
  <xsl:apply-templates select="title" />

\subtitle{<xsl:value-of select="$adagio.project.name"/> (<xsl:value-of select="$adagio.project.edition"/>)}

  <xsl:apply-templates select="author" />
  <xsl:apply-templates select="institution" />

<xsl:if test="$adagio.prosper.logo.enable='true'">
\Logo<xsl:value-of select="$adagio.prosper.logo.pos"/>{\includegraphics[width=<xsl:value-of select="$adagio.prosper.logo.width"/>]{<xsl:value-of select="$adagio.prosper.logo.file"/>}}
</xsl:if>

\begin{document}
\maketitle
  <xsl:apply-templates select="material" />
\end{document}
  </xsl:template>

  <xsl:template match="title">
\title{<xsl:value-of select="text()" />}
  </xsl:template>

  <xsl:template match="author">
\author{<xsl:value-of select="text()" />
    <xsl:if test="count(@email) = 1">
\\ <xsl:value-of select="@email" />
    </xsl:if>
}
  </xsl:template>

  <xsl:template match="institution">
\institution{<xsl:value-of select="$adagio.institution.name" />}
  </xsl:template>

  <xsl:template match="material">
    <xsl:apply-templates select="include" />
  </xsl:template>

  <xsl:template match="include">
\input{<xsl:value-of select="text()" />}
  </xsl:template>

</xsl:stylesheet>
