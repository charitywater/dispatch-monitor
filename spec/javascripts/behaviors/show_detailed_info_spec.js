describe('RemoteMonitoring.showDetailedInfo', function() {
  'use strict';

  beforeEach(function() {
    this.$element = $('<div data-behavior="showDetailedInfo"></div>');

    this.children = [{ id: 1 }];
    spyOn(this.$element, 'children').and.returnValue(this.children);
    spyOn(Elemental, 'load');
  });

  describe('when the projectSelect event is triggered', function() {
    beforeEach(function() {
      this.project = {
        id: 25,
        beneficiaries: '250',
        community_name: 'Fancy Community',
        completion_date: '2014-01-01',
        country: 'Fancy Australia',
        deployment_code: 'Deployment Code',
        inventory_type: 'Inventory Type',
        location_type: 'Location Type',
        partner: 'Fancy Partner',
        contact_name: 'Fancy Contact',
        contact_email: 'email@example.com',
        contact_phone_numbers: [],
        has_sensor: true
      };
    });

    it('renders the project information', function() {
      RemoteMonitoring.showDetailedInfo(this.$element);
      $(document).trigger('projectSelect', this.project);

      expect(this.$element).toContainText('Fancy Community');
      expect(this.$element).toContainText('Fancy Australia');
    });

    it('loads Elemental for the new children', function() {
      RemoteMonitoring.showDetailedInfo(this.$element);
      $(document).trigger('projectSelect', this.project);

      expect(Elemental.load).toHaveBeenCalledWith(this.children);
    });
  });
});
