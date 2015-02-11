(function(RemoteMonitoring) {
  'use strict';

  RemoteMonitoring.toggleElement = function toggleElement($el) {
    var $target = $($el.data('target'));
    var visibleValues = $el.data('visible').toString().split(" ");

    function toggleTargetVisibility() {
      var hide;
      if (visibleValues.indexOf($el.val()) > -1) {
        hide = false;
      }
      else {
        hide = true;
      }
      $target.toggleClass('hide', hide)
        .find(':input')
        .prop('disabled', hide);
    }

    $el.change(toggleTargetVisibility);
    toggleTargetVisibility();
  };
})(RemoteMonitoring);
