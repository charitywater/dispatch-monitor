(function(RemoteMonitoring, $, document) {
  'use strict';

  function projectSelectHandler(e, project) {
    var $el = e.data.$el;

    $el.html(JST['templates/projects/details'](project));
    Elemental.load($el.children());
  }

  RemoteMonitoring.showDetailedInfo = function showDetailedInfo($el) {
    $(document).on('projectSelect', null, {$el: $el}, projectSelectHandler);
  };
})(RemoteMonitoring, jQuery, document);
