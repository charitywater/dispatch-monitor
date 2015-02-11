(function(RemoteMonitoring) {
  'use strict';

  RemoteMonitoring.rewire = function rewire($el) {
    $(document).ajaxSuccess(function(__, ___, request) {
      if (request.url.indexOf('/search/projects.json') === -1) {
        Elemental.load($el.children());
      }
    });
  };
})(RemoteMonitoring);
