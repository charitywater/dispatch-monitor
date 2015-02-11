(function(RemoteMonitoring, google, $) {
  'use strict';

  describe('RemoteMonitoring.MapFactory', function() {
    describe('#getMap', function() {
      var factory, map, $el;

      beforeEach(function() {
        factory = new RemoteMonitoring.MapFactory();
        map = jasmine.createSpyObj('map', ['fitBounds']);
        spyOn(google.maps, 'Map').and.returnValue(map);
      });

      describe('when the bounds are specified', function() {
        var latLng, latLngBounds, center;

        beforeEach(function() {
          $el = $(
            '<div ' +
            'data-bounds="[10, 20, 50, 60]" ' +
            '></div>'
          );

          latLng = jasmine.createSpy('latLng');
          center = jasmine.createSpy('center');

          latLngBounds = jasmine.createSpyObj('latLngBounds', ['getCenter']);
          latLngBounds.getCenter.and.returnValue(center);

          spyOn(google.maps, 'LatLng').and.returnValue(latLng);
          spyOn(google.maps, 'LatLngBounds').and.returnValue(latLngBounds);
        });

        it('calculates the center of the bounds', function() {
          factory.getMap($el);

          expect(google.maps.LatLng.calls.argsFor(0)).toEqual([10, 20]);
          expect(google.maps.LatLng.calls.argsFor(1)).toEqual([50, 60]);
        });

        it('centers the map within the bounds', function() {
          factory.getMap($el);

          expect(google.maps.Map).toHaveBeenCalledWith($el[0], {
              center: center,
              zoom: 11,
              panControl: false,
              streetViewControl: false,
              mapTypeControlOptions: {
                position: google.maps.ControlPosition.TOP_LEFT
              },
              zoomControlOptions: {
                position: google.maps.ControlPosition.LEFT_TOP
              }
            }
          );
        });

        it('fits the map to the bounds', function() {
          factory.getMap($el);

          expect(map.fitBounds).toHaveBeenCalledWith(latLngBounds);
        });
      });

      describe('when a lat/lng point is specified', function() {
        beforeEach(function() {
          $el = $(
            '<div ' +
            'data-latitude="30" ' +
            'data-longitude="40" ' +
            '></div>'
          );
        });

        it('centers the map on the point', function() {
          factory.getMap($el);

          expect(google.maps.Map).toHaveBeenCalledWith($el[0], {
              center: { lat: 30, lng: 40 },
              zoom: 11,
              panControl: false,
              streetViewControl: false,
              mapTypeControlOptions: {
                position: google.maps.ControlPosition.TOP_LEFT
              },
              zoomControlOptions: {
                position: google.maps.ControlPosition.LEFT_TOP
              }
            }
          );
        });

        it('does not fit the map to the (non-existent) bounds', function() {
          factory.getMap($el);

          expect(map.fitBounds).not.toHaveBeenCalled();
        });
      });
    });
  });
})(RemoteMonitoring, google, jQuery);
