<?php

$opts = array(
    'http' => array('proxy' => 'tcp://127.0.0.1:8080', 'request_fulluri' => true),
    'ssl' => array('verify_peer' => false, 'verify_peer_name' => false)
);

$context = stream_context_create($opts);

// Obtenir l'adresse IP du client
$clientIP = $_SERVER['REMOTE_ADDR'];

if ($clientIP == '127.0.0.1') {
    $clientIP = '193.50.135.206';
}

// Partie 1: Géolocalisation
// Initialiser cURL pour la première API de géolocalisation
$chGeo = curl_init();
curl_setopt($chGeo, CURLOPT_URL, "https://ipapi.co/{$clientIP}/xml/");
curl_setopt($chGeo, CURLOPT_RETURNTRANSFER, 1);
$geoXML = curl_exec($chGeo);
curl_close($chGeo);

// Charger le XML de géolocalisation dans un objet SimpleXMLElement
$geoXmlObj = simplexml_load_string($geoXML);

// Extraire la latitude, la longitude, la ville et la timezone
$latitude = $geoXmlObj->latitude;
$longitude = $geoXmlObj->longitude;
$ville = $geoXmlObj->city;
$timezone = $geoXmlObj->timezone;

// Partie 2: Prévisions Météo
// Initialiser cURL pour la deuxième API de prévisions météo
$chMeteo = curl_init();
$meteoApiUrl = "http://www.infoclimat.fr/public-api/gfs/xml?_ll={$latitude},{$longitude}&_auth=UUtQR1IsXH5SfwYxBnACK1M7UmdeKAgvC3cAY1o%2FVSgGbVU0UTEHYVU7VyoOIVFnByoFZg41BDRXPFYuCXtTMlE7UDxSOVw7Uj0GYwYpAilTfVIzXn4ILwtpAG5aNFUoBmBVMVEsB2RVOVcwDiBRZwc0BWAOLgQjVzVWNglkUzRROlA9UjBcP1I5Bm0GKQIpU2ZSN15oCGULYQBkWjdVYgZsVTJRNgdkVTtXNA4gUW0HNgVkDjkEPFc8VjUJYlMvUS1QTVJCXCNSfQYmBmMCcFN9UmdePwhk&_c=50405dba53ebc6195952cd0b4a4eba28";
curl_setopt($chMeteo, CURLOPT_URL, $meteoApiUrl);
curl_setopt($chMeteo, CURLOPT_RETURNTRANSFER, 1);
$meteoXML = curl_exec($chMeteo);
curl_close($chMeteo);

// Vérifiez si la réponse est un XML bien formé
if (simplexml_load_string($meteoXML) === false) {
    die("Erreur : la réponse de l'API météo n'est pas un XML bien formé.");
}

// Charger la feuille de style XSL pour les prévisions météo
$xslMeteoDoc = new DOMDocument;
$xslMeteoDoc->load('meteo.xsl');

// Charger le XML de prévisions météo dans un objet SimpleXMLElement
$meteoXmlObj = simplexml_load_string($meteoXML);

// Initialiser le processeur XSLT
$xsltMeteoProc = new XSLTProcessor;
$xsltMeteoProc->importStylesheet($xslMeteoDoc);

// Appliquer la transformation XSL pour les prévisions météo
$meteoResult = $xsltMeteoProc->transformToXML($meteoXmlObj);

?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Informations Géolocalisation et Météo</title>
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
<body>
    <h1>C'est la météo de Gulli</h1>

    <!-- Informations de géolocalisation -->
    <h2>Informations de Géolocalisation</h2>
    <table>
        <tr>
            <th>Information</th>
            <th>Valeur</th>
        </tr>
        <tr>
            <td>Latitude</td>
            <td><?php echo $latitude; ?></td>
        </tr>
        <tr>
            <td>Longitude</td>
            <td><?php echo $longitude; ?></td>
        </tr>
        <tr>
            <td>Ville</td>
            <td><?php echo $ville; ?></td>
        </tr>
        <tr>
            <td>Timezone</td>
            <td><?php echo $timezone; ?></td>
        </tr>
    </table>

    <!-- Informations météorologiques générées par XSL -->
    <?php echo $meteoResult; ?>

    <!-- Ajoutez ici le code pour la carte Leaflet et autres parties de votre page -->

</body>
</html>
