(function() {
  'use strict';

  window.RemoteMonitoring = {};

  var flashCallback;
  flashCallback = function() {
    $(".alert-box").fadeOut();
  };
  setTimeout(flashCallback, 4000);
})();
