<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:param name="latitude"/>
<xsl:param name="longitude"/>
<xsl:param name="ville"/>
<xsl:param name="currentDate"/>
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

      .sidebar {
        position: fixed;
        top: 0;
        left: 0;
        width: 0;
        height: 100%;
        background-color: #333;
        transition: 0.5s;
        overflow-x: hidden;
        z-index: 1;
      }
      
      .languette {
        position: fixed;
        top: 0;
        left: 0;
        width: 50px; /* Augmentez la largeur de la languette */
        height: 100%;
        background-color: #555;
        cursor: pointer;
        z-index: 2;
      }

      .arrow {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        width: 0;
        height: 0;
        border-top: 10px solid transparent;
        border-bottom: 10px solid transparent;
        border-left: 10px solid white; /* Crée une flèche vers la droite */
      }
      </style>
    </head>
    <body class="container mt-5">
      <h1>A bicyclette</h1>
      <!-- Informations de géolocalisation -->
      <h2>Informations de Géolocalisation</h2>
      <p>
          Latitude : 
          <xsl:value-of select="$latitude"/>
          / Longitude : 
          <xsl:value-of select="$longitude"/>
          / Ville : 
          <xsl:value-of select="$ville"/>
          / Date : 
          <xsl:value-of select="$currentDate"/>
      </p>
      <h2 class="mb-4">Informations Météorologiques</h2>
      <xsl:choose>
          <xsl:when test="/previsions/echeance/@timestamp = '1970-01-01 04:00:00 UTC'">
            <p>Erreur : les données météorologiques reçues ne sont pas valides.</p>
          </xsl:when>
          <xsl:otherwise>
            <div class="table-responsive">
                <table class="table">
                  <thead>
                      <tr>
                        <th scope="col">Heure</th>
                        <th scope="col">Température</th>
                        <th scope="col">Tendance</th>
                      </tr>
                  </thead>
                  <tbody>
                      <xsl:for-each select="/previsions/echeance[starts-with(@timestamp, $currentDate)]">
                        <tr>
                            <td>
                              <xsl:value-of select="@timestamp"/>
                            </td>
                            <td>
                              <xsl:value-of select="format-number(number(temperature/level[@val='2m']) - 273.15, '##.##')"/>
                              °C
                            </td>
                            <td>
                              <xsl:choose>
                                <!-- Si le risque de neige est 'oui', affichez l'icône de neige -->
                                <xsl:when test="risque_neige = 'oui'">
                                  <img src="/images/snow.png" alt="Risque de neige " width="50" height="50"/>
                                </xsl:when>
                                <!-- Sinon, si l'humidité est supérieure ou égale à 85, affichez l'icône de pluie -->
                                <xsl:when test="number(humidite/level[@val='2m']) >= 85">
                                  <img src="/images/rain.png" alt="Pluie " width="50" height="50"/>
                                </xsl:when>
                              </xsl:choose>
                              <xsl:if test="number(temperature/level[@val='2m']) - 273.15 &lt; 7">
                                  <img src="/images/cold.png" alt="Froid " width="50" height="50"/>
                              </xsl:if>
                              <xsl:if test="number(vent_moyen/level[@val='10m']) >= 60">
                                  <img src="/images/wind.png" alt="Vent fort " width="50" height="50"/>
                              </xsl:if>
                              <xsl:if test="number(pluie) &lt; 1 and number(temperature/level[@val='2m']) - 273.15 >= 10 and number(vent_moyen/level[@val='10m']) &lt; 20">
                                  <img src="/images/sun.png" alt="Ensoleillé " width="50" height="50"/>
                              </xsl:if>
                            </td>
                        </tr>
                      </xsl:for-each>
                  </tbody>
                </table>
            </div>
          </xsl:otherwise>
      </xsl:choose>

      <div class="sidebar">
        <div id="map" class="vh-100 vw-100 d-none"></div>
      </div>
      <div class="languette">
        <div class="arrow"></div>
      </div>

    </body>
    <script src="script.js"></script>
  </html>
</xsl:template>
</xsl:stylesheet>
