(function(RemoteMonitoring) {
  'use strict';

  RemoteMonitoring.configurableDashboardItem = function configurableDashboardItem($el) {
    $el.on('click', '[data-dashboard-edit-button]', function(event) {
      if ($(event.target).is('a')) {
        event.preventDefault();
      }

      $el.find('[data-dashboard-edit]').toggleClass('hide');
    });
  };
})(RemoteMonitoring);
