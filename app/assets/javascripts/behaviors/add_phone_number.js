(function(RemoteMonitoring) {
  'use strict';

  function getInput(index) {
    return JST['templates/projects/add_phone_number']({index: index});
  }

  RemoteMonitoring.addPhoneNumber = function addPhoneNumber($element) {
    $element.on('click', function() {
      var index = $element.siblings('input:text').length;
      $element.before(getInput(index));
    });
  };
})(RemoteMonitoring);
