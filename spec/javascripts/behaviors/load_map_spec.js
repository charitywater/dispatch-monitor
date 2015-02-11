describe('RemoteMonitoring.loadProjectMap', function() {
  'use strict';

  var $element, projectMap;

  beforeEach(function() {
    $element = $(
      '<div data-behavior="loadProjectMap"' +
        ' data-id="3"' +
        ' data-latitude="25"' +
        ' data-longitude="52"' +
      '></div>'
    );

    projectMap = jasmine.createSpyObj('projectMap', ['reload']);
    spyOn(RemoteMonitoring, 'ProjectMap').and.returnValue(projectMap);
  });

  it('initializes the project map', function() {
    RemoteMonitoring.loadProjectMap($element);

    expect(RemoteMonitoring.ProjectMap).toHaveBeenCalledWith($element);
    expect(projectMap.reload).toHaveBeenCalled();
  });
});
