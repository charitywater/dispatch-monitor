describe('RemoteMonitoring.rewire', function() {
  'use strict';

  var $element, children;

  beforeEach(function() {
    $element = $(
      '<div data-behavior="rewire">' +
      '</div>'
    );

    children = [{ id: 1 }];
    spyOn($element, 'children').and.returnValue(children);

    RemoteMonitoring.rewire($element);
  });

  it('reloads Elemental on ajax success', function() {
    spyOn(Elemental, 'load').and.callThrough();

    $(document).trigger('ajaxSuccess', [null, {url: 'http://example.com'}]);

    expect(Elemental.load).toHaveBeenCalledWith(children);
  });
});
