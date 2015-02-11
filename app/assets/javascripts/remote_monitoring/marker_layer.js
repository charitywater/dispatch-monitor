(function(RemoteMonitoring, google, $, _) {
  'use strict';

  RemoteMonitoring.MarkerLayer = function MarkerLayer(id) {
    this.id = id;
    this.visible = true;
    this.markers = {};
  };

  RemoteMonitoring.MarkerLayer.prototype.add = function add(projectId, marker) {
    this.markers[projectId] = marker;
    marker.setVisible(this.visible);
  };

  RemoteMonitoring.MarkerLayer.prototype.setVisibility = function setVisibility(v) {
    if (this.visible === v) { return; }

    for (var id in this.markers) {
      this.markers[id].setVisible(v);
    }
    this.visible = v;
  };
})(RemoteMonitoring, google, jQuery, _);

