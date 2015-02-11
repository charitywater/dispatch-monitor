(function(RemoteMonitoring) {
  'use strict';

  RemoteMonitoring.autoSubmit = function autoSubmit($el) {
    $el.on('change', function() {
      $el.parents('form').submit();
    });
  };
})(RemoteMonitoring);
