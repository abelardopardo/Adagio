<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl str xi">

  <xsl:param name="ada.asap.num.authors"       select="'2'"/>
  <!-- nia, email, none -->
  <xsl:param name="ada.asap.include.id"        select="'email'"/> 
  <xsl:param name="ada.asap.id.text"           select="'ID'"/>
  <xsl:param name="ada.asap.include.fullname"  select="'no'"/>
  <!-- all, none, one -->
  <xsl:param name="ada.asap.include.password"  select="'one'"/> 
  <xsl:param name="ada.asap.include.groupname" select="'no'"/>
  <!-- yes, no -->
  <xsl:param name="ada.asap.confirmation.email" select="'yes'"/>
    
</xsl:stylesheet>
