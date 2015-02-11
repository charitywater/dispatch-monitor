describe('RemoteMonitoring.toggleElement', function() {
  'use strict';

  var $fixture, $element, $target;

  beforeEach(function() {
    var element = '<select data-behavior="toggleElement" data-target="#target"' +
      'data-visible="VisibleValue VisibleValue2">' +
      '<option>InvisibleValue</option>' +
      '<option>VisibleValue</option>' +
      '<option>VisibleValue2</option>' +
      '</select>';
    var target = '<div id="target"><input id="input"></div>';

    $fixture = setFixtures(element + target);
    $element = $fixture.find('[data-behavior="toggleElement"]');
    $target = $fixture.find('#target');
  });

  describe('on init', function() {
    describe('when the initial value matches "visible"', function() {
      it('does not hide or disable the target', function(){
        $element.val('VisibleValue');
        RemoteMonitoring.toggleElement($element);

        expect($target).not.toHaveClass('hide');
        expect($target.find('input')).not.toBeDisabled();
      });
    });
    describe('when the initial value does not match "visible"', function() {
      it('hides the target', function(){
        $element.val('InvisibleValue');
        RemoteMonitoring.toggleElement($element);

        expect($target).toHaveClass('hide');
        expect($target.find('input')).toBeDisabled();
      });
    });
  });

  describe('when the value changes', function() {
    beforeEach(function() {
      RemoteMonitoring.toggleElement($element);
    });

    it('shows the target when value matches "visible"', function() {
      $element.val('VisibleValue');
      $element.trigger('change');

      expect($target).not.toHaveClass('hide');
      expect($target.find('input')).not.toBeDisabled();
    });

    it('hides the target when value does not match "visible"', function() {
      $element.val('InvisibleValue');
      $element.trigger('change');

      expect($target).toHaveClass('hide');
      expect($target.find('input')).toBeDisabled();
    });
  });
});
