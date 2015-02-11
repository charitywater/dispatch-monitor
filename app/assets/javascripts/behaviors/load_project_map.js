(function(RemoteMonitoring, google, window) {
  'use strict';

  RemoteMonitoring.loadProjectMap = function loadProjectMap($el) {
    var projectMap = new RemoteMonitoring.ProjectMap($el);
    projectMap.reload();
  };
})(RemoteMonitoring, google, window);
