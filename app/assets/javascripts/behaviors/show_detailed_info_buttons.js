(function(RemoteMonitoring, $, document) {
  'use strict';

  function projectSelectHandler(e, project) {
    var $el = e.data.$el;

    $el.html(JST['templates/projects/details_buttons'](project));
    Elemental.load($el.children());
  }

  RemoteMonitoring.showDetailedInfoButtons = function showDetailedInfoButtons($el) {
    $(document).on('projectSelect', null, {$el: $el}, projectSelectHandler);
  };
})(RemoteMonitoring, jQuery, document);
