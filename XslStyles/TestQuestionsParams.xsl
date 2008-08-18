<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:exsl="http://exslt.org/common" 
  xmlns="http://www.w3.org/1999/xhtml" version="1.0">

  <!-- Show the qandadiv ID -->
  <xsl:param name="ada.testquestions.include.id" select="'no'"/>

  <!-- Insert history remarks -->
  <xsl:param name="ada.testquestions.include.history" select="'no'"/>

  <!-- Insert pagebreaks as specified in the sectioninfo -->
  <xsl:param name="ada.testquestions.insert.pagebreaks" select="'yes'"/>

  <!-- Render one question per page -->
  <xsl:param name="ada.testquestions.render.onequestionperpage" select="'no'"/>

  <!-- Size of the square to mark -->
  <xsl:param name="ada.testquestions.render.squaresize" select="'10pt'"/>

</xsl:stylesheet>
