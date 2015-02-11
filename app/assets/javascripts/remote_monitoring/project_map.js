(function(RemoteMonitoring, google, window) {
  'use strict';

  function getFieldsFor(project) {
    return [
      { label: 'Inventory Type'  , value: project.inventory_type },
      { label: 'Beneficiaries'   , value: project.beneficiaries },
      { label: 'Location Type'   , value: project.location_type },
      { label: 'Partner'         , value: project.partner },
      { label: 'Deployment Code' , value: project.deployment_code },
      { label: 'Completion Date' , value: project.completion_date }
    ];
  }

  RemoteMonitoring.ProjectMap = function ProjectMap($el) {
    this.map = new RemoteMonitoring.MapFactory().getMap($el);
    this.setId($el.data('id'));
  };

  RemoteMonitoring.ProjectMap.prototype.setId = function setId(id) {
    this.id = id;
  };

  RemoteMonitoring.ProjectMap.prototype.projectsInBounds = function projectsInBounds() {
    this._projectsInBounds = this._projectsInBounds || new RemoteMonitoring.ProjectsInBounds(this);
    return this._projectsInBounds;
  };

  RemoteMonitoring.ProjectMap.prototype.projectInBoundsClickHandler = function projectInBoundsClickHandler(projectId) {
    var self = this;
    return function loadProject() {
      self.setId(projectId);
      self.reload();
    };
  };

  RemoteMonitoring.ProjectMap.prototype.reload = function reload() {
    var self = this;
    if (this.id) {
      var canonicalUrl = '/map/projects/' + this.id;
      window.history.pushState({}, '', canonicalUrl);

      $.get(canonicalUrl + '.json', function(project) {
        project.fields = getFieldsFor(project);
        self.setSelected(project);
        self.showProjectInfo(project);
        self.projectsInBounds().setup();
      });
    } else {
      self.projectsInBounds().setup();
    }
  };

  RemoteMonitoring.ProjectMap.prototype.showProjectInfo = function showProjectInfo(project) {
    $(document).trigger('projectSelect', project);
  };

  RemoteMonitoring.ProjectMap.prototype.setSelected = function setSelected(project) {
    var position = new google.maps.LatLng(project.latitude, project.longitude);

    if (this.selected) { this.selected.setMap(null); }
    this.selected = new google.maps.Marker({
      position: position,
      title: project.title,
      zIndex: google.maps.Marker.MAX_ZINDEX + 1,
      icon: RemoteMonitoring.configuration.icons.selected[project.status]
    });
    this.selected.setMap(this.map);
  };
})(RemoteMonitoring, google, window);
