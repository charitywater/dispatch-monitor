describe('RemoteMonitoring.ProjectMap', function() {
  'use strict';

  var $element, latLngBounds, map, mapFactory, marker,
    position, projectsInBounds;

  beforeEach(function() {
    $element = $(
      '<div data-behavior="loadProjectMap"' +
      ' data-id="3"' +
      '></div>'
    );

    map = jasmine.createSpyObj('google.maps.Map', ['panTo']);
    marker = jasmine.createSpyObj('google.maps.Marker', ['setMap']);
    position = { lat: 25, lng: 52 };
    spyOn(google.maps, 'Marker').and.returnValue(marker);
    spyOn(google.maps, 'LatLng').and.returnValue(position);
    spyOn(window.history, 'pushState');
    spyOn($, 'get');
    spyOn($.fn, 'trigger');

    projectsInBounds = jasmine.createSpyObj('projectsInBounds', ['setup']);
    spyOn(RemoteMonitoring, 'ProjectsInBounds').and.returnValue(projectsInBounds);

    mapFactory = jasmine.createSpyObj('MapFactory', ['getMap']);
    mapFactory.getMap.and.returnValue(map);

    spyOn(RemoteMonitoring, 'MapFactory').and.returnValue(mapFactory);

    google.maps.Marker.MAX_ZINDEX = 35;
  });

  it('gets the map from the map factory', function() {
    var _ = new RemoteMonitoring.ProjectMap($element);

    expect(mapFactory.getMap).toHaveBeenCalledWith($element);
  });

  describe('#reload', function() {
    var projectMap;

    describe('when there is no selected project', function() {
      beforeEach(function() {
        $element = $('<div data-behavior="loadProjectMap"></div>');
        projectMap = new RemoteMonitoring.ProjectMap($element);
      });

      it('sets up the projects in bounds', function() {
        projectMap.reload();

        expect(projectsInBounds.setup).toHaveBeenCalled();
      });

      it('does not request project details', function() {
        projectMap.reload();

        expect($.get).not.toHaveBeenCalled();
      });

      it('does not trigger the projectSelected event', function (){
        projectMap.reload();

        expect($.fn.trigger).not.toHaveBeenCalled();
      });
    });

    describe('when there is a selected project', function() {
      beforeEach(function() {
        projectMap = new RemoteMonitoring.ProjectMap($element);
      });

      it('requests the project details from the server', function() {
        projectMap.reload();

        expect($.get).toHaveBeenCalledWith('/map/projects/3.json', jasmine.any(Function));
      });

      it('pushes the project url to the history', function() {
        projectMap.reload();

        expect(window.history.pushState).toHaveBeenCalledWith(
          {}, '', '/map/projects/3'
        );
      });

      describe('when the project response comes back', function() {
        var project, nearbyProjects;

        beforeEach(function() {
          project = {
            id: 3,
            latitude: 25,
            longitude: 52,
            title: 'Project Title',
            status: 'needs_maintenance',
            activities: [],
            tickets: []
          };

          $.get.and.callFake(function(url, callback) {
            callback(project);
          });

          spyOn(projectMap, 'setSelected');
        });

        it('sets this project as the new selected project', function() {
          projectMap.reload();

          expect(projectMap.setSelected).toHaveBeenCalledWith(project);
        });

        it('sets up the projects in bounds', function() {
          projectMap.reload();

          expect(projectsInBounds.setup).toHaveBeenCalled();
        });

        it('triggers the projectSelect', function() {
          projectMap.reload();

          expect($.fn.trigger).toHaveBeenCalledWith('projectSelect', project);
        });
      });
    });
  });

  describe('#projectInBoundsClickHandler', function() {
    var projectMap;

    beforeEach(function() {
      projectMap = new RemoteMonitoring.ProjectMap($element);

      spyOn(projectMap, 'setId');
      spyOn(projectMap, 'reload');
    });

    it('returns a function that loads the project', function() {
      var callback = projectMap.projectInBoundsClickHandler(5);
      callback();

      expect(projectMap.setId).toHaveBeenCalledWith(5);
      expect(projectMap.reload).toHaveBeenCalled();
    });
  });

  describe('#setSelected', function() {
    var projectMap, project, oldSelected;

    beforeEach(function() {
      projectMap = new RemoteMonitoring.ProjectMap($element);
      project = {
        id: 3,
        latitude: 25,
        longitude: 52,
        title: 'Project Title',
        status: 'needs_maintenance',
        activities: [],
        tickets: []
      };

      oldSelected = jasmine.createSpyObj('oldSelected', ['setMap']);
      projectMap.selected = oldSelected;
    });

    it('clears the previous selected Marker', function() {
      projectMap.setSelected(project);

      expect(oldSelected.setMap).toHaveBeenCalledWith(null);
    });

    it('creates a new Marker with project’s info', function() {
      projectMap.setSelected(project);

      expect(google.maps.Marker).toHaveBeenCalledWith({
        position: position,
        title: 'Project Title',
        zIndex: 36,
        icon: '/assets/map_icons/selected_needs_maintenance16x16.png'
      });

    });

    it('adds the Marker to the map', function() {
      projectMap.setSelected(project);

      expect(marker.setMap).toHaveBeenCalledWith(map);
    });
  });
});
