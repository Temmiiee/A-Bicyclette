<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes"/>

<xsl:template match="/">
  <html>
    <head>
      <title>Informations Géolocalisation et Météo</title>
    </head>
    <body>
      <!-- Informations météorologiques -->
      <h2>Informations Météorologiques</h2>
      <xsl:for-each select="/previsions/echeance">
         <div>
            <h3>Heure: <xsl:value-of select="@hour"/></h3>
            <p>Température: <xsl:value-of select="temperature/level[@val='2m']"/> °C</p>
            <p>Précipitation: <xsl:value-of select="pluie"/> mm</p>
            <!-- Ajoutez d'autres informations météorologiques au besoin -->
         </div>
      </xsl:for-each>
    </body>
  </html>
</xsl:template>

</xsl:stylesheet>
