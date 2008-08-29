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

  <!-- Text to include in the top left (next to icon) -->
  <xsl:param name="ada.exam.topleft.toptext"/>
  <xsl:param name="ada.exam.topleft.toptext.en"/>

  <!-- Text to include in the center left (next to icon) -->
  <xsl:param name="ada.exam.topleft.centertext"/>
  <xsl:param name="ada.exam.topleft.centertext.en"/>

  <!-- Text to include in the bottom left (next to icon) -->
  <xsl:param name="ada.exam.topleft.bottomtext"/>
  <xsl:param name="ada.exam.topleft.bottomtext.en"/>

  <!-- Text to include in the top right (next to icon) -->
  <xsl:param name="ada.exam.topright.toptext"/>
  <xsl:param name="ada.exam.topright.toptext.en"/>

  <!-- Text to include in the center right (next to icon) -->
  <xsl:param name="ada.exam.topright.centertext"/>
  <xsl:param name="ada.exam.topright.centertext.en"/>

  <!-- Text to include in the bottom right (next to icon) -->
  <xsl:param name="ada.exam.topright.bottomtext"/>
  <xsl:param name="ada.exam.topright.bottomtext.en"/>

</xsl:stylesheet>
