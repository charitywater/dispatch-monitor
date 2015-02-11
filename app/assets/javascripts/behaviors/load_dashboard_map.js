(function(RemoteMonitoring, google, window) {
  'use strict';

  RemoteMonitoring.loadDashboardMap = function loadDashboardMap($el) {
    var dashboardMap = new RemoteMonitoring.DashboardMap($el);
    dashboardMap.reload();
  };
})(RemoteMonitoring, google, window);
