<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" version="1.0">

  <!-- Control the font size -->
  <xsl:param name="ada.exam.fontsize" select="'10pt'"/>

  <!-- Show the qandadiv ID -->
  <xsl:param name="ada.exam.include.id" select="'no'"/>

  <!-- Show the qandadiv ID -->
  <xsl:param name="ada.exam.render.separate.cover" select="'yes'"/>

  <!-- Author/s of the exam -->
  <xsl:param name="ada.exam.author" />

  <!-- Logo to use in the upper left corner -->
  <xsl:param name="ada.exam.topleft.image"/>
  <xsl:param name="ada.exam.topleft.image.alt"/>

</xsl:stylesheet>
