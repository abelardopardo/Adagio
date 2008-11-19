<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi str">
  
  <!-- Brings in all the default values -->
  <xsl:import href="Params.xsl"/>

<!-- 
    Prosper-specific params:
        * ada.prosper.style: prosper style to apply.
        * ada.prosper.lang: latex language to declare (e.g.: "es")
        * ada.prosper.logo.enable: true to enable logo, false otherwise.
        * ada.prosper.logo.width: scale the logo to the given width.
        * ada.prosper.logo.pos: put the logo in the given position.
        * ada.prosper.logo.file: eps/ps file of the logo.
-->

  <!-- Param defaults -->
  <xsl:param name="ada.prosper.lang">en</xsl:param>
  <xsl:param name="ada.prosper.logo.enable">no</xsl:param>
  <xsl:param name="ada.prosper.logo.width">1cm</xsl:param>
  <xsl:param name="ada.prosper.logo.pos">(-1.12,-1.25)</xsl:param>


  <xsl:output method="text" indent="no" encoding="UTF-8" />

  <xsl:template match="document">
\documentclass[pdf,<xsl:value-of select="$ada.prosper.style"/>,slideColor,colorBG]{prosper}

\usepackage[utf8]{inputenc}


<xsl:if test="$ada.prosper.lang='es'">
\usepackage[spanish,activeacute]{babel}
</xsl:if>

\usepackage{pstricks,pst-node,pst-text,pst-3d}
\usepackage{amsmath}

\usepackage{fancyvrb}

\newcommand{\todo}{\green [(pendiente)]}
\newcommand{\todom}[1]{\green[#1]}
  <xsl:apply-templates select="title" />

\subtitle{<xsl:value-of select="$ada.course.name"/> (<xsl:value-of select="$ada.course.edition"/>)}

  <xsl:apply-templates select="author" />
  <xsl:apply-templates select="institution" />

<xsl:if test="$ada.prosper.logo.enable='true'">
\Logo<xsl:value-of select="$ada.prosper.logo.pos"/>{\includegraphics[width=<xsl:value-of select="$ada.prosper.logo.width"/>]{<xsl:value-of select="$ada.prosper.logo.file"/>}}
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
\institution{<xsl:value-of select="$ada.institution.name" />}
  </xsl:template>

  <xsl:template match="material">
    <xsl:apply-templates select="include" />
  </xsl:template>

  <xsl:template match="include">
\input{<xsl:value-of select="text()" />}
  </xsl:template>

</xsl:stylesheet>