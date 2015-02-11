describe('RemoteMonitoring.ProjectsInBounds', function() {
  'use strict';

  describe('#setup', function() {
    var projectsInBounds, map;

    beforeEach(function() {
      map = {};
      projectsInBounds = new RemoteMonitoring.ProjectsInBounds({map: map});

      spyOn(projectsInBounds, 'load');
      spyOn(google.maps.event, 'addListener');
    });

    it('adds a bounds_changed listener', function() {
      projectsInBounds.setup();

      expect(google.maps.event.addListener).toHaveBeenCalledWith(map, 'bounds_changed', jasmine.any(Function));
    });

    it('loads the nearby projects in setup', function() {
      projectsInBounds.setup();

      expect(projectsInBounds.load).toHaveBeenCalled();
    });

    describe('when the bounds change', function() {
      var boundsChangedHandler;

      beforeEach(function() {
        google.maps.event.addListener.and.callFake(function(___, ____, callback) {
          boundsChangedHandler = callback;
        });

        spyOn(_, 'debounce').and.callFake(function(callback) {
          return callback;
        });
      });

      it('loads the projects in bounds', function() {
        projectsInBounds.setup();
        projectsInBounds.load.calls.reset();

        boundsChangedHandler();
        expect(projectsInBounds.load).toHaveBeenCalled();
      });
    });

    describe('when the projectStatusFilterChange fires', function() {
      var pushedUrl;

      beforeEach(function() {
        spyOn(projectsInBounds.markerLayers.unknown, 'setVisibility');
        spyOn(projectsInBounds.markerLayers.needs_maintenance, 'setVisibility');
        spyOn(projectsInBounds.markerLayers.flowing, 'setVisibility');
        spyOn(projectsInBounds.markerLayers.inactive, 'setVisibility');
        spyOn(projectsInBounds.markerLayers.needs_visit, 'setVisibility');

        spyOn(history, 'pushState').and.callFake(function(__, ___, url) {
          pushedUrl = url;
        });
      });

      it('sets the status filter in the url', function() {
        projectsInBounds.setup();
        $(document).trigger('projectStatusFilterChange', projectsInBounds.statuses.UNKNOWN);

        expect(pushedUrl.indexOf('%5Bstatus%5D=unknown')).not.toBe(-1);
      });

      describe('when it fires with a status', function() {
        it('sets that layer to visible and the rest to invisible', function() {
          projectsInBounds.setup();

          $(document).trigger('projectStatusFilterChange', projectsInBounds.statuses.UNKNOWN);

          expect(projectsInBounds.markerLayers.unknown.setVisibility).toHaveBeenCalledWith(true);
          expect(projectsInBounds.markerLayers.needs_maintenance.setVisibility).toHaveBeenCalledWith(false);
          expect(projectsInBounds.markerLayers.flowing.setVisibility).toHaveBeenCalledWith(false);
          expect(projectsInBounds.markerLayers.inactive.setVisibility).toHaveBeenCalledWith(false);
          expect(projectsInBounds.markerLayers.needs_visit.setVisibility).toHaveBeenCalledWith(false);
        });

        describe('when it fires with no status', function() {
          it('sets all layers as visible', function() {
            projectsInBounds.setup();

            $(document).trigger('projectStatusFilterChange', "");

            expect(projectsInBounds.markerLayers.unknown.setVisibility).toHaveBeenCalledWith(true);
            expect(projectsInBounds.markerLayers.needs_maintenance.setVisibility).toHaveBeenCalledWith(true);
            expect(projectsInBounds.markerLayers.flowing.setVisibility).toHaveBeenCalledWith(true);
            expect(projectsInBounds.markerLayers.inactive.setVisibility).toHaveBeenCalledWith(true);
            expect(projectsInBounds.markerLayers.needs_visit.setVisibility).toHaveBeenCalledWith(true);
          });
        });
      });
    });

    describe('#load', function() {
      var projectsInBounds, map;

      beforeEach(function() {
        map = jasmine.createSpyObj('map', ['getBounds']);

        projectsInBounds = new RemoteMonitoring.ProjectsInBounds({map: map});

        spyOn($, 'get');
      });

      describe('when the map has bounds', function() {
        beforeEach(function() {
          map.getBounds.and.returnValue({toUrlValue: function() { return '1,2,3,4.2'; } });
        });

        it('requests the projects within the map bounds', function() {
          projectsInBounds.load();

          expect($.get).toHaveBeenCalledWith('/search/projects.json?bounds=1,2,3,4.2', jasmine.any(Function));
        });

        describe('when nearby projects are received', function() {
          var addNearbyCallback, project1, project2;

          beforeEach(function() {
            project1 = { id: 1 };
            project2 = { id: 2 };

            $.get.and.callFake(function(___, callback) {
              addNearbyCallback = callback;
            });

            spyOn(projectsInBounds, 'addNearby');
          });

          it('adds each nearby project', function() {
            projectsInBounds.load();

            addNearbyCallback([project1, project2]);

            expect(projectsInBounds.addNearby).toHaveBeenCalledWith(project1);
            expect(projectsInBounds.addNearby).toHaveBeenCalledWith(project2);
          });
        });
      });

      describe('when the map does not have bounds', function() {
        beforeEach(function() {
          map.getBounds.and.returnValue(undefined);
        });

        it('requests the projects within the map bounds', function() {
          projectsInBounds.load();

          expect($.get).not.toHaveBeenCalled();
        });
      });
    });

    describe('#addNearby', function() {
      var project, projectsInBounds, map, marker, projectMap, projectClickHandler;

      beforeEach(function() {
        project = {
          id: 3,
          latitude: 25,
          longitude: 52,
          status: 'flowing'
        };

        map = {};
        projectClickHandler = jasmine.createSpy('projectClickHandler');
        projectMap = jasmine.createSpyObj('projectMap', ['setId', 'reload', 'projectInBoundsClickHandler']);
        projectMap.projectInBoundsClickHandler.and.returnValue(projectClickHandler);
        projectMap.map = map;

        projectsInBounds = new RemoteMonitoring.ProjectsInBounds(projectMap);

        marker = jasmine.createSpyObj('marker', ['setMap', 'setVisible']);
        spyOn(google.maps, 'Marker').and.returnValue(marker);
      });

      describe('when the project has not yet been added', function() {
        it('adds a marker for the project', function() {
          projectsInBounds.addNearby(project);

          expect(google.maps.Marker).toHaveBeenCalledWith(jasmine.objectContaining({
            position: { lat: 25, lng: 52 },
            icon: '/assets/map_icons/flowing16x16.png'
          }));
        });

        it('listens to the marker click', function() {
          projectsInBounds.addNearby(project);

          expect(google.maps.event.addListener).toHaveBeenCalledWith(marker, 'click', projectClickHandler);
        });
      });

      describe('when the project has previously been added', function() {
        beforeEach(function() {
          projectsInBounds.addNearby(project);

          google.maps.Marker.calls.reset();
          google.maps.event.addListener.calls.reset();
        });

        it('does not add a marker for the project', function() {
          projectsInBounds.addNearby(project);

          expect(google.maps.Marker).not.toHaveBeenCalled();
        });

        it('does not listen to the marker click', function() {
          projectsInBounds.addNearby(project);

          expect(google.maps.event.addListener).not.toHaveBeenCalled();
        });
      });
    });
  });
});
