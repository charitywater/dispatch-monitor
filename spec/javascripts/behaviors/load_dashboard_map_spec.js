describe('RemoteMonitoring.loadDashboardMap', function() {
  'use strict';

  var $element, dashboardMap;

  beforeEach(function() {
    $element = $(
      '<div data-behavior="loadDashboardMap"' +
        ' data-bounds="[10, 20, 50, 60]"' +
      '></div>'
    );

    dashboardMap = jasmine.createSpyObj('dashboardMap', ['reload']);
    spyOn(RemoteMonitoring, 'DashboardMap').and.returnValue(dashboardMap);
  });

  it('initializes the dashboard map', function() {
    RemoteMonitoring.loadDashboardMap($element);

    expect(RemoteMonitoring.DashboardMap).toHaveBeenCalledWith($element);
    expect(dashboardMap.reload).toHaveBeenCalled();
  });
});
