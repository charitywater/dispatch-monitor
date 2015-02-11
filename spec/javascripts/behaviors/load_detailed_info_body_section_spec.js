describe('RemoteMonitoring.loadDetailedInfoBodySection', function() {
  'use strict';

  beforeEach(function() {
    var el = '<div ' +
      'data-behavior="loadDetailedInfoBodySection" ' +
      'data-url="/any/path" ' +
      'data-template="templates/tickets/section" ' +
      '></div>';
    this.$el = $(el);
    this.children = [{id: 1}];

    spyOn(this.$el, 'children').and.returnValue(this.children);
    spyOn($, 'get');
    spyOn(Elemental, 'load');
  });

  it('loads the data from the url', function() {
    RemoteMonitoring.loadDetailedInfoBodySection(this.$el);

    expect($.get).toHaveBeenCalledWith(
      '/any/path',
      jasmine.any(Function)
    );
  });

  describe('when the data are successfully fetched', function() {
    beforeEach(function() {
      this.tickets = {
        allows_new_ticket: true,
        project_id: 5,
        tickets: [{
          completed_at: null,
          due_at: null,
          generated_by_sensor: 4,
          id: 423,
          manually_completed_by: null,
          manually_created_by: null,
          started_at: '2014-07-30',
          status: 'in_progress'
        }]
      };

      var self = this;
      $.get.and.callFake(function(__, callback) {
        callback(self.tickets);
      });
    });

    it('renders the section', function() {
      RemoteMonitoring.loadDetailedInfoBodySection(this.$el);

      expect(this.$el).toContainText('2014-07-30');
      expect(this.$el).toContainText('#423 In Progress');
      expect(this.$el).toContainText('sensor');
      expect(this.$el).toContainText('+ Ticket');
    });

    it('reloads elemental for the children', function() {
      RemoteMonitoring.loadDetailedInfoBodySection(this.$el);

      expect(Elemental.load).toHaveBeenCalledWith(this.children);
    });
  });
});
