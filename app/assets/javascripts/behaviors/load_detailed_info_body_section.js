(function(RemoteMonitoring, $) {
  'use strict';

  RemoteMonitoring.loadDetailedInfoBodySection = function loadDetailedInfoBodySection($el) {
    $.get($el.data('url'), function successCallback(response) {
      $el.html(JST[$el.data('template')](response));
      Elemental.load($el.children());
    });
  };
})(RemoteMonitoring, jQuery);
