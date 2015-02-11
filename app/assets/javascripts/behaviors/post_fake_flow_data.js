(function(RemoteMonitoring, $, JSON, window) {
  'use strict';

  RemoteMonitoring.postFakeFlowData = function postFakeFlowData($el) {
    $el.on('click', function(event) {
      event.preventDefault();

      var data = RemoteMonitoring.fakeSensorData[$el.data('source')];
      data.ts = Date.now();

      $.post(
        RemoteMonitoring.routes.sensors_receive_path({ format: 'json' }),
        JSON.stringify(data),
        function() {
          window.refresh();
        }
      );
    });
  };
})(RemoteMonitoring, jQuery, JSON, window);
