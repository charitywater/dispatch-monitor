describe('RemoteMonitoring.autoSubmit', function() {
  'use strict';

  var $element, form;

  beforeEach(function() {
    $element = $('<select data-behavior="autoSubmit"></select>');
    form = jasmine.createSpyObj('form', ['submit']);

    spyOn($element, 'parents').and.returnValue(form);
  });

  describe('when the select changes', function() {
    it('submits the form', function() {
      RemoteMonitoring.autoSubmit($element);

      expect($element.parents).not.toHaveBeenCalled();
      expect(form.submit).not.toHaveBeenCalled();

      $element.trigger('change');

      expect($element.parents).toHaveBeenCalledWith('form');
      expect(form.submit).toHaveBeenCalled();
    });
  });
});
