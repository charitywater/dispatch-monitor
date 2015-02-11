describe('RemoteMonitoring.selectMapLayer', function() {
  'use strict';

  var $element, event;

  beforeEach(function() {
    $element = $(
      '<select data-behavior="selectMapLayer">' +
        '<option value="a">A</option>' +
        '<option value="b" selected="selected">B</option>' +
      '</select>'
    );
    event = spyOnEvent(document, 'projectStatusFilterChange');
  });

  it('fires the event on setup', function() {
    RemoteMonitoring.selectMapLayer($element);

    expect('projectStatusFilterChange').toHaveBeenTriggeredOnAndWith(document, 'b');
  });

  describe('when the select changes', function() {
    it('fires the event', function() {
      RemoteMonitoring.selectMapLayer($element);
      event.reset();

      expect(event).not.toHaveBeenTriggered();

      $element.trigger('change');

      expect('projectStatusFilterChange').toHaveBeenTriggeredOnAndWith(document, 'b');
    });
  });
});
