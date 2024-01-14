<?php

$opts = array(
    'http' => array('proxy' => 'tcp://127.0.0.1:8080', 'request_fulluri' => true),
    'ssl' => array('verify_peer' => false, 'verify_peer_name' => false)
);

$context = stream_context_create($opts);

// Partie 1: Géolocalisation
// Obtenir l'adresse IP publique du client
$clientIP = $_SERVER['REMOTE_ADDR'];

if ($clientIP == '::1') {
    // Si l'adresse IP est ::1 (localhost en IPv6), utilisez une adresse IP de test
    $clientIP = '193.50.135.206'; // Remplacez ceci par l'adresse IP réelle que vous souhaitez utiliser
}

// Initialiser cURL pour l'API de géolocalisation ipapi
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
curl_setopt($chMeteo, CURLOPT_URL, "https://www.infoclimat.fr/public-api/gfs/xml?_ll={$latitude},{$longitude}&_auth=UUtQRwJ8BiQCLwM0VyELIlY%2BU2ZeKAQjCnZVNl04XiMGbVIzUjIAZlI8UC1VelZgVHlQM1xnAzMHbFcvXy0AYVE7UDwCaQZhAm0DZld4CyBWeFMyXn4EIwpgVTNdLl48BmNSP1IvAGNSO1A2VXtWY1RkUDlcfAMkB2VXN18yAGZRMlA8AmMGYgJkA2RXeAsgVmNTNl4wBD0KblVkXTReOgZiUjRSMQA3UjxQMlV7VmBUZFAyXGsDMgdtVzZfMwB8US1QTQISBnkCLQMjVzILeVZ4U2ZePwRo&_c=7ad857e368077e9c63f7f8d93f9ed065&lang=fr");
curl_setopt($chMeteo, CURLOPT_RETURNTRANSFER, 1);

// Exécuter la requête cURL
$meteoXML = curl_exec($chMeteo);

// Vérifier les erreurs cURL
if ($meteoXML === false) {
    die("Erreur cURL: " . curl_error($chMeteo));
} else if (curl_getinfo($chMeteo, CURLINFO_HTTP_CODE) !== 200) {
    die("Erreur HTTP: " . curl_getinfo($chMeteo, CURLINFO_HTTP_CODE));
}

// Fermer la ressource cURL
curl_close($chMeteo);

// Charger la feuille de style XSL pour les prévisions météo
$xslMeteoDoc = new DOMDocument;
$xslMeteoDoc->load('meteo.xsl');

// Charger le XML de prévisions météo dans un objet SimpleXMLElement
$meteoXmlObj = simplexml_load_string($meteoXML);

// Vérifier si la réponse est un XML bien formé
if ($meteoXmlObj === false) {
    $htmlMeteo = "Erreur : la réponse de l'API météo n'est pas un XML bien formé.";
} else {
    // Initialiser le processeur XSLT
    $proc = new XSLTProcessor;

    // Charger la feuille de style XSL
    $xslMeteoDoc = new DOMDocument;
    $xslMeteoDoc->load('meteo.xsl');
    $proc->importStylesheet($xslMeteoDoc);

    // Ajouter les informations de géolocalisation et la date du jour comme des paramètres XSLT
    $proc->setParameter('', 'latitude', $latitude);
    $proc->setParameter('', 'longitude', $longitude);
    $proc->setParameter('', 'ville', $ville);
    $proc->setParameter('', 'currentDate', date('Y-m-d'));

    // Transformer le XML de prévisions météo en HTML
    try {
        $htmlMeteo = $proc->transformToXml($meteoXmlObj);
    } catch (Exception $e) {
        $htmlMeteo = "Une erreur est survenue lors de la récupération des informations météorologiques.";
    }
}

echo $htmlMeteo;
?>
