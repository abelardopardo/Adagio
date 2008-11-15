<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0" exclude-result-prefixes="exsl str xi">
  
  <xsl:output method="xml" indent="yes" encoding="UTF-8"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <xsl:template match="project">
    <informaltable frame="all">
      <xsl:attribute name="id"><xsl:value-of select="@default"/>_vars</xsl:attribute>
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
          <xsl:for-each select="descendant::property[@description != '']">
            <row>
              <entry>
                <varname>
                  <xsl:value-of select="@name"/>
                </varname>
              </entry>
              <entry>
                <xsl:value-of select="str:replace(@description, '# ', '')"/>
              </entry>
              <entry>
                <xsl:value-of select="@value"/>
              </entry>
            </row>
          </xsl:for-each>
        </tbody>
      </tgroup>
    </informaltable>
  </xsl:template>
</xsl:stylesheet>
