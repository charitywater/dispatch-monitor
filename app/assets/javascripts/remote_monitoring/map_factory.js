(function(RemoteMonitoring, google) {
  'use strict';

  function parseBounds(rawBounds) {
    var southwest = new google.maps.LatLng(rawBounds[0], rawBounds[1]);
    var northeast = new google.maps.LatLng(rawBounds[2], rawBounds[3]);

    return new google.maps.LatLngBounds(southwest, northeast);
  }

  function parseMapData(projectData) {
    if (projectData.bounds) {
      var bounds = parseBounds(projectData.bounds);

      return { bounds: bounds, center: bounds.getCenter() };
    } else {
      var latitude = parseFloat(projectData.latitude);
      var longitude = parseFloat(projectData.longitude);

      if (!isNaN(latitude) && !isNaN(longitude)) {
        return { center: { lat: latitude, lng: longitude } };
      }
    }
  }

  RemoteMonitoring.MapFactory = function MapFactory() {
  };

  RemoteMonitoring.MapFactory.prototype.getMap = function getMap($el) {
    var mapData = parseMapData($el.data());

    var mapOptions = {
      zoom: 11,
      center: mapData.center,
      panControl: false,
      streetViewControl: false,
      mapTypeControlOptions: {
        position: google.maps.ControlPosition.TOP_LEFT
      },
      zoomControlOptions: {
        position: google.maps.ControlPosition.LEFT_TOP
      }
    };

    var map = new google.maps.Map($el[0], mapOptions);

    if (mapData.bounds) {
      map.fitBounds(mapData.bounds);
    }

    return map;
  };
})(RemoteMonitoring, google);
