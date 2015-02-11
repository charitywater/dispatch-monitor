describe('RemoteMonitoring.addPhoneNumber', function() {
  'use strict';

  var $fixture, $element;

  beforeEach(function() {
    $fixture = setFixtures(
      '<div>' +
      '<a href="#" id="add-phone-number-button" data-behavior="addPhoneNumber">Click me!</a>' +
      '</div>'
    );

    $element = $fixture.find('#add-phone-number-button');

    RemoteMonitoring.addPhoneNumber($element);
  });

  describe('when clicking the element', function() {
    it('adds a new phone number input', function() {
      $element.click();

      var $input = $fixture.find('input:text');
      expect($input.attr('id')).toEqual('project_contact_phone_numbers_0');
      expect($input.attr('name')).toEqual('project[contact_phone_numbers][0]');
      expect($input.val()).toEqual('');
    });

    describe('when clicking again', function() {
      it('adds another new phone number input', function() {
        $element.click();
        $element.click();

        expect($fixture.find('input:text').length).toEqual(2);

        var $input = $fixture.find('input:text').last();
        expect($input.attr('id')).toEqual('project_contact_phone_numbers_1');
        expect($input.attr('name')).toEqual('project[contact_phone_numbers][1]');
        expect($input.val()).toEqual('');
      });
    });
  });

});
