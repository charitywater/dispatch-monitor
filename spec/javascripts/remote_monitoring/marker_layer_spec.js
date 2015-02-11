describe('RemoteMonitoring.MarkerLayer', function() {
  'use strict';

  describe('#add', function() {
    var projectId, marker, markerLayer;

    beforeEach(function() {
      projectId = 0;
      marker = jasmine.createSpyObj('marker', ['setVisible']);

      markerLayer = new RemoteMonitoring.MarkerLayer('unknown');
      markerLayer.visible = false;
    });

    it('adds the marker to the layer’s markers', function() {
      markerLayer.add(projectId, marker);

      expect(markerLayer.markers[projectId]).toEqual(marker);
    });

    it('sets the marker’s visibility', function() {
      markerLayer.add(projectId, marker);

      expect(marker.setVisible).toHaveBeenCalledWith(false);
    });
  });

  describe('#setVisibility', function() {
    var markerLayer;

    describe('when changing visibility', function() {
      var markers = {};

      beforeEach(function() {
        markerLayer = new RemoteMonitoring.MarkerLayer('unknown');

        markers.a = jasmine.createSpyObj('alpha', ['setVisible']);
        markers.b = jasmine.createSpyObj('bravo', ['setVisible']);
        markerLayer.markers = markers;

        spyOn(markerLayer, 'visible');
      });

      it('changes its markers visibility', function() {
        var v = !markerLayer.visible;
        markerLayer.setVisibility(v);

        expect(markers.a.setVisible).toHaveBeenCalledWith(v);
        expect(markers.b.setVisible).toHaveBeenCalledWith(v);
      });

      it('stores its own visibility', function() {
        var v = !markerLayer.visible;
        markerLayer.setVisibility(v);

        expect(markerLayer.visible).toBe(v);
      });
    });

    describe('when same visibility is set', function() {
      beforeEach(function() {
        markerLayer = new RemoteMonitoring.MarkerLayer('0');

        spyOn(markerLayer, 'markers');
        spyOn(markerLayer, 'visible');
      });

      it('does nothing', function() {
        var v = markerLayer.visible;
        markerLayer.setVisibility(v);

        expect(markerLayer.markers).not.toHaveBeenCalled();
        expect(markerLayer.visible).toBe(v);
      });
    });
  });
});
