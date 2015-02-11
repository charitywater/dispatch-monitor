(function(RemoteMonitoring, google, window) {
  'use strict';

  function parseBounds(rawBounds) {
    var southwest = new google.maps.LatLng(rawBounds[0], rawBounds[1]);
    var northeast = new google.maps.LatLng(rawBounds[2], rawBounds[3]);

    return new google.maps.LatLngBounds(southwest, northeast);
  }

  RemoteMonitoring.DashboardMap = function DashboardMap($el) {
    this.el = $el;
    var bounds = parseBounds($el.data('bounds'));

    var mapOptions = {
      center: bounds.getCenter(),
      zoom: 11,
      disableDefaultUI: true,
      zoomControl: true,
      mapTypeControl: true,
      mapTypeControlOptions: {
        position: google.maps.ControlPosition.TOP_LEFT
      },
      zoomControlOptions: {
        position: google.maps.ControlPosition.LEFT_TOP
      }
    };

    this.map = new google.maps.Map($el[0], mapOptions);
    this.map.fitBounds(bounds);
  };

  RemoteMonitoring.DashboardMap.prototype.reload = function reload() {
    var projectsInBounds = new RemoteMonitoring.ProjectsInBounds(this);
    projectsInBounds.setup();
  };

  /*jslint maxlen: 130 */
  RemoteMonitoring.DashboardMap.prototype.projectInBoundsClickHandler = function projectInBoundsClickHandler(projectId) {
    var self = this;

    return function loadProject() {
      var projectMap = new RemoteMonitoring.ProjectMap(self.el);
      projectMap.setId(projectId);
      projectMap.reload();
      window.refresh();
    };
  };

})(RemoteMonitoring, google, window);
