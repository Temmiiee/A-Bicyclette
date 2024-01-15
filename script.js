document.querySelector('.languette').addEventListener('click', function() {
    var sidebar = document.querySelector('.sidebar');
    if (sidebar.style.width === '0px') {
        sidebar.style.width = '250px';
        document.getElementById('map').classList.remove('d-none');
        // Initialisez votre carte Leaflet ici
    } else {
        sidebar.style.width = '0px';
        document.getElementById('map').classList.add('d-none');
    }
});