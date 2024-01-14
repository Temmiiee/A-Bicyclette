<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:param name="latitude"/>
<xsl:param name="longitude"/>
<xsl:param name="ville"/>
<xsl:param name="currentDate"/>
<xsl:variable name="matin" select="concat($currentDate, ' 07:00:00 UTC')"/>
<xsl:variable name="midi" select="concat($currentDate, ' 13:00:00 UTC')"/>
<xsl:variable name="soir" select="concat($currentDate, ' 19:00:00 UTC')"/>

  <xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/">
    <html lang="fr">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Informations Géolocalisation et Météo</title>
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css"/>
        <style>
          body {
            font-family: Arial, sans-serif;
          }
          table {
            border-collapse: collapse;
            width: 100%;
          }
          th, td {
            border: 1px solid #dddddd;
            text-align: left;
            padding: 8px;
          }
          th {
            background-color: #f2f2f2;
          }
        </style>
      </head>
      <body class="container mt-5">
        <h1>C'est la météo de Gulli</h1>

        <!-- Informations de géolocalisation -->
        <h2>Informations de Géolocalisation</h2>
        <p>Latitude : <xsl:value-of select="$latitude"/> / Longitude : <xsl:value-of select="$longitude"/> / Ville : <xsl:value-of select="$ville"/> / Date : <xsl:value-of select="$currentDate"/></p>

        <h2 class="mb-4">Informations Météorologiques</h2>

        <xsl:choose>
          <xsl:when test="/previsions/echeance/@timestamp = '1970-01-01 04:00:00 UTC'">
            <p>Erreur : les données météorologiques reçues ne sont pas valides.</p>
          </xsl:when>
          <xsl:otherwise>
            <div class="row">
              <xsl:for-each select="/previsions/echeance[@timestamp = $matin or @timestamp = $midi or @timestamp = $soir]">
                <div class="col-md-4 mb-4">
                  <div class="card">
                    <div class="card-body">
                      <h3 class="card-title">
                        <xsl:choose>
                          <xsl:when test="substring(@timestamp, 12, 2) = '07'">Matin</xsl:when>
                          <xsl:when test="substring(@timestamp, 12, 2) = '13'">Midi</xsl:when>
                          <xsl:when test="substring(@timestamp, 12, 2) = '19'">Soir</xsl:when>
                        </xsl:choose>
                      </h3>
                      <p class="card-text">
                        <xsl:value-of select="format-number(number(temperature/level[@val='2m']) - 273.15, '##.##')"/> °C
                      </p>
                      <xsl:if test="number(pluie) >= 1">
                        <img src="/images/rain.png" alt="Rain Icon" width="50" height="50"/>
                      </xsl:if>
                      <xsl:if test="number(temperature/level[@val='2m']) - 273.15 &lt; 10">
                        <img src="/images/cold.png" alt="Cold Icon" width="50" height="50"/>
                      </xsl:if>
                      <xsl:if test="number(vent_moyen/level[@val='10m']) >= 20">
                        <img src="/images/wind.png" alt="Wind Icon" width="50" height="50"/>
                      </xsl:if>
                      <xsl:if test="number(pluie) &lt; 1 and number(temperature/level[@val='2m']) - 273.15 >= 10 and number(vent_moyen/level[@val='10m']) &lt; 20">
                        <img src="/images/sun.png" alt="Sunny Icon" width="50" height="50"/>
                      </xsl:if>
                    </div>
                  </div>
                </div>
              </xsl:for-each>
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
