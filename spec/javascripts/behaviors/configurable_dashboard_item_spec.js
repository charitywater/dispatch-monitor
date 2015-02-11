describe('RemoteMonitoring.configurableDashboardItem', function() {
  'use strict';

  var $element, $form, $values, $editButton;

  beforeEach(function() {
    $element = $(
      '<div data-behavior="configurable-dashboard-item">' +
        '<form class="hide" data-dashboard-edit="true"></form>' +
        '<section data-dashboard-edit="true"></section>' +
        '<a href="#" data-dashboard-edit-button="true"></a>' +
      '</div>'
    );

    $form = $element.find('form');
    $values = $element.find('section');
    $editButton = $element.find('a');

    RemoteMonitoring.configurableDashboardItem($element);
  });

  describe('when clicking on a dashboard edit button', function() {
    it('toggles .hide', function() {
      expect($form).toHaveClass('hide');
      expect($values).not.toHaveClass('hide');

      $editButton.click();

      expect($form).not.toHaveClass('hide');
      expect($values).toHaveClass('hide');

      $editButton.click();

      expect($form).toHaveClass('hide');
      expect($values).not.toHaveClass('hide');
    });
  });
});
