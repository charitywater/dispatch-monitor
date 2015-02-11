describe('RemoteMonitoring.DashboardMap', function() {
  'use strict';

  var $element, map, southwest, northeast, bounds, projectsInBounds, projectMap;

  beforeEach(function() {
    $element = $(
      '<div data-behavior="loadDashboardMap"' +
        ' id="nothing"' +
        ' data-bounds="[10, 20, 50, 60]"' +
      '></div>'
    );

    map = jasmine.createSpyObj('google.maps.Map', ['fitBounds']);
    southwest = jasmine.createSpyObj('google.maps.LatLng', ['']);
    northeast = jasmine.createSpyObj('google.maps.LatLng', ['']);
    bounds = jasmine.createSpyObj('google.maps.LatLngBounds', ['getCenter']);
    bounds.getCenter.and.returnValue({ lat: 30, lng: 40 });
    spyOn(google.maps, 'Map').and.returnValue(map);
    spyOn(google.maps, 'LatLng').and.callFake(function(latitude, longitude) {
      return latitude === 10 ? southwest : northeast;
    });
    spyOn(google.maps, 'LatLngBounds').and.returnValue(bounds);

    projectsInBounds = jasmine.createSpyObj('projectsInBounds', ['setup']);
    spyOn(RemoteMonitoring, 'ProjectsInBounds').and.returnValue(projectsInBounds);

    projectMap = jasmine.createSpyObj('projectMap', ['reload', 'setId']);
    spyOn(RemoteMonitoring, 'ProjectMap').and.returnValue(projectMap);
    spyOn(window, 'refresh');
  });

  it('creates a map centered in the bounds from the element data', function() {
    var _ = new RemoteMonitoring.DashboardMap($element);

    expect(google.maps.Map).toHaveBeenCalledWith($element[0], {
      center: { lat: 30, lng: 40 },
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
    });
  });

  it('fits the map to the specified bounds', function() {
    var _ = new RemoteMonitoring.DashboardMap($element);

    expect(map.fitBounds).toHaveBeenCalledWith(bounds);
  });

  describe('#reload', function() {
    it('sets up the projects in bounds', function() {
      var dashboardMap = new RemoteMonitoring.DashboardMap($element);
      dashboardMap.reload();

      expect(projectsInBounds.setup).toHaveBeenCalled();
    });
  });

  describe('#projectInBoundsClickHandler', function() {
    it('loads the project map when a marker is clicked', function() {
      var dashboardMap = new RemoteMonitoring.DashboardMap($element);
      dashboardMap.reload();

      var callback = dashboardMap.projectInBoundsClickHandler(123);
      callback();

      expect(projectMap.setId).toHaveBeenCalledWith(123);
      expect(projectMap.reload).toHaveBeenCalled();
      expect(window.refresh).toHaveBeenCalled();
    });
  });
});
