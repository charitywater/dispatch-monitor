describe('RemoteMonitoring.postFakeFlowData', function() {
  'use strict';

  beforeEach(function() {
    var el = '<a href="#" data-behavior="postFakeFlowData" data-source="weeklyNormalFlow">Click</a>';
    this.$el = $(el);

    this.url = RemoteMonitoring.routes.sensors_receive_path({ format: 'json' });

    RemoteMonitoring.postFakeFlowData(this.$el);
  });

  describe('when clicked', function() {
    beforeEach(function() {
      var self = this;

      spyOn($, 'post').and.callFake(function(__, ___, sensorReceiveCallback) {
        self.sensorReceiveCallback = sensorReceiveCallback;
      });

      this.$el.click();
    });

    it('posts the data', function() {
      expect($.post).toHaveBeenCalledWith(
        this.url,
        JSON.stringify(RemoteMonitoring.fakeSensorData.weeklyNormalFlow),
        jasmine.any(Function)
      );
    });

    describe('when the post is successful', function() {
      beforeEach(function() {
        spyOn(window, 'refresh');

        this.sensorReceiveCallback();
      });

      it('reloads the page', function() {
        expect(window.refresh).toHaveBeenCalled();
      });
    });
  });
});
