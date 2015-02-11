(function(RemoteMonitoring, google, $, _, Modernizr) {
  'use strict';

  RemoteMonitoring.ProjectsInBounds = function ProjectsInBounds(mapContainer) {
    this.mapContainer = mapContainer;
    this.statuses = {
      UNKNOWN: 'unknown',
      NEEDS_MAINTENANCE: 'needs_maintenance',
      FLOWING: 'flowing',
      INACTIVE: 'inactive',
      NEEDS_VISIT: 'needs_visit'
    };

    this.nearby = {};
    this.markerLayers = {
      unknown: new RemoteMonitoring.MarkerLayer(this.statuses.UNKNOWN),
      needs_maintenance:  new RemoteMonitoring.MarkerLayer(this.statuses.NEEDS_MAINTENANCE),
      flowing: new RemoteMonitoring.MarkerLayer(this.statuses.FLOWING),
      inactive: new RemoteMonitoring.MarkerLayer(this.statuses.INACTIVE),
      needs_visit: new RemoteMonitoring.MarkerLayer(this.statuses.NEEDS_VISIT)
    };
  };

  RemoteMonitoring.ProjectsInBounds.prototype.setup = function setup() {
    var self = this;

    google.maps.event.addListener(
      this.mapContainer.map,
      'bounds_changed',
      _.debounce(function() { self.load(); }, 150)
    );
    this.load();

    $(document).on('projectStatusFilterChange', function(e, status) {
      var type, layer;
      for (type in self.markerLayers) {
        layer = self.markerLayers[type];
        layer.setVisibility(status === "" || status === layer.id);
      }

      if (Modernizr.history) {
        var currentUrl = [location.protocol, '//', location.host, location.pathname].join('');
        history.pushState({}, '', currentUrl + '?filters%5Bstatus%5D=' + status);
      }
    });
  };

  RemoteMonitoring.ProjectsInBounds.prototype.load = function load() {
    var self = this;

    var bounds = this.mapContainer.map.getBounds();
    if (bounds) {
      $.get('/search/projects.json?bounds=' + bounds.toUrlValue(), function(projects) {
        projects.forEach(function(project) {
          self.addNearby(project);
        });
      });
    }
  };

  RemoteMonitoring.ProjectsInBounds.prototype.addNearby = function addNearby(n) {
    if (!_(this.nearby).has(n.id)) {
      var marker = new google.maps.Marker({
        position: { lat: n.latitude, lng: n.longitude },
        animation: RemoteMonitoring.configuration.nearbyAnimation,
        icon: RemoteMonitoring.configuration.icons.secondary[n.status]
      });
      this.nearby[n.id] = marker;
      this.markerLayers[n.status].add(n.id, marker);

      marker.setMap(this.mapContainer.map);

      if (this.mapContainer.projectInBoundsClickHandler) {
        google.maps.event.addListener(
          this.nearby[n.id],
          'click',
          this.mapContainer.projectInBoundsClickHandler(n.id)
        );
      }
    }
  };
})(RemoteMonitoring, google, jQuery, _, Modernizr);
