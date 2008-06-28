<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi str">
  
  <!-- Brings in all the default values -->
  <xsl:import href="Params.xsl"/>

  <xsl:output method="text" indent="no" encoding="UTF-8" />

  <xsl:template match="document">
\documentclass[pdf,uc3m,slideColor,colorBG]{prosper}

\usepackage[utf8]{inputenc}
\usepackage[spanish,activeacute]{babel}

\usepackage{pstricks,pst-node,pst-text,pst-3d}
\usepackage{amsmath}

\usepackage{fancyvrb}

\newcommand{\todo}{\green [(pendiente)]}
\newcommand{\todom}[1]{\green[#1]}
  <xsl:apply-templates select="title" />

\subtitle{<xsl:value-of select="$ada.course.name"/> (<xsl:value-of select="$ada.course.edition"/>)}

  <xsl:apply-templates select="author" />
  <xsl:apply-templates select="institution" />

\Logo(-1.12,-1.25){\includegraphics[width=1cm]{<xsl:value-of 
                                               select="$ada.prosper.logo"/>}}

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
