<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  version="1.0" exclude-result-prefixes="exsl">

  <xsl:template name="str:_replace">
     <xsl:param name="string"
                select="''" />
     <xsl:param name="replacements"
                select="/.." />
     <xsl:choose>
        <xsl:when test="not($string)" />
        <xsl:when test="not($replacements)">
           <xsl:value-of select="$string" />
        </xsl:when>
        <xsl:otherwise>
           <xsl:variable name="replacement"
                         select="$replacements[1]" />
           <xsl:variable name="search"
                         select="$replacement/@search" />
           <xsl:choose>
              <xsl:when test="not(string($search))">
                 <xsl:value-of select="substring($string, 1, 1)" />
                 <xsl:copy-of select="$replacement/node()" />
                 <xsl:call-template name="str:_replace">
                    <xsl:with-param name="string"
                                    select="substring($string, 2)" />
                    <xsl:with-param name="replacements"
                                    select="$replacements" />
                 </xsl:call-template>
              </xsl:when>
              <xsl:when test="contains($string, $search)">
                 <xsl:call-template name="str:_replace">
                    <xsl:with-param name="string"
                                    select="substring-before($string, $search)" />
                    <xsl:with-param name="replacements"
                                    select="$replacements[position() > 1]" />
                 </xsl:call-template>
                 <xsl:copy-of select="$replacement/node()" />
                 <xsl:call-template name="str:_replace">
                    <xsl:with-param name="string"
                                    select="substring-after($string, $search)" />
                    <xsl:with-param name="replacements"
                                    select="$replacements" />
                 </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                 <xsl:call-template name="str:_replace">
                    <xsl:with-param name="string"
                                    select="$string" />
                    <xsl:with-param name="replacements"
                                    select="$replacements[position() > 1]" />
                 </xsl:call-template>
              </xsl:otherwise>
           </xsl:choose>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
