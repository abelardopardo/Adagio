<?xml version="1.0" encoding="UTF-8"?>

<!-- Stylesheet used only for testing purposes -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:output method="xml" indent="yes" encoding="UTF-8" />

  <xsl:template match="*">
      <xsl:copy>
          <xsl:copy-of select="@*" />
          <xsl:apply-templates select="node()" />
      </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
