// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require underscore
//= require foundation
//= require elemental
//= require remote_monitoring
//= require js-routes
//= require humanize
//= require_tree ./remote_monitoring
//= require_tree ./behaviors
//= require_tree ./templates

(function($) {
  'use strict';

  window.refresh = function() {
    window.location.reload();
  };

  $(function() {
    var $document = $(document);
    $document.foundation();

    Elemental.addNamespace(RemoteMonitoring);
    Elemental.load(document);
  });
})(jQuery);
