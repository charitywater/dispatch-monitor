(function(RemoteMonitoring, $, document) {
  'use strict';

  RemoteMonitoring.selectMapLayer = function selectMapLayer($el) {
    $el.change(function() {
      $(document).trigger('projectStatusFilterChange', $el.val());
    });

    $el.change();
  };
})(RemoteMonitoring, jQuery, document);
