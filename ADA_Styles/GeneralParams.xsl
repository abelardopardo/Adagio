<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl xi">
  
  <!-- Customization variables and their default values -->
  <xsl:param name="ada.publish.host" 
    description="Host where the material is published"/>
  <xsl:param name="ada.publish.dir" 
    description="Directory in ada.publish.host where the material is published"/>

  <xsl:param name="ada.institution.name"
    description="Your institution name">Your institution name</xsl:param>

  <xsl:param name="ada.course.home.url" 
    description="URL pointing to the course"/>

  <xsl:param name="ada.course.icon" 
    description="Image representing the course icon (typically 16x16)"/>
  <xsl:param name="ada.course.icon.type" 
    description="mime-type of the previous file"
    select="'image/x-icon'" />

  <xsl:param name="ada.course.degree" 
    description="Degree to which this course belongs"/>

  <xsl:param name="ada.course.edition" 
    description="Something such as Fall 20?? or Spring 20??"/>

  <xsl:param name="ada.course.image" 
    description="URL pointing to a larger image of the course"/>
  <xsl:param name="ada.course.name"
    description="Course name">ada.course.name</xsl:param>
  <xsl:param name="ada.course.short.edition" 
    description="Abbreviation of the course edition (e.g Fall??)"/>
  <xsl:param name="ada.course.short.name" 
    description="Abbreviation of the course name (e.g. CS4703)"/>
  <xsl:param name="ada.course.year" 
    description="Year where the course is taking place"/>

</xsl:stylesheet>
