describe('RemoteMonitoring.loadSensorGraph', function() {
  'use strict';

  beforeEach(function() {
    var sensor = {
      id: 1,
      project_id: 2,
      graph_data: [
        { date: '2014-07-01T00:00:00.000Z', liters: 300 },
        { date: '2014-07-08T00:00:00.000Z', liters: 1000 },
        { date: '2014-07-15T00:00:00.000Z', liters: 500 }
      ]
    };

    var el = '<div ' +
      'data-behavior="loadSensorGraph" ' +
      'data-sensor=\'' + JSON.stringify(sensor) + '\' ' +
      '></div>';
    this.$el = $(el);

    this.dataTable = jasmine.createSpyObj('google.visualization.DataTable', [
      'addColumn',
      'addRow'
    ]);

    this.areaChart = jasmine.createSpyObj('google.visualization.AreaChart', [
      'draw'
    ]);

    this.dateFormatter = jasmine.createSpyObj(
      'google.visualization.DateFormat',
      [ 'format' ]
    );

    spyOn(google.visualization, 'DataTable').and.returnValue(this.dataTable);
    spyOn(google.visualization, 'AreaChart').and.returnValue(this.areaChart);
    spyOn(google.visualization, 'DateFormat').and.returnValue(this.dateFormatter);
  });

  it('adds the columns to the data table', function() {
    RemoteMonitoring.loadSensorGraph(this.$el);

    expect(this.dataTable.addColumn).toHaveBeenCalledWith('date', 'Date');
    expect(this.dataTable.addColumn).toHaveBeenCalledWith('number', 'Water Flow (L)');
  });

  it('formats the date column in GMT', function() {
    RemoteMonitoring.loadSensorGraph(this.$el);

    expect(google.visualization.DateFormat).toHaveBeenCalledWith({
      timeZone: 0
    });
    expect(this.dateFormatter.format).toHaveBeenCalledWith(
      this.dataTable, 0
    );
  });

  it('adds a row for each graph data point', function() {
    RemoteMonitoring.loadSensorGraph(this.$el);

    expect(this.dataTable.addRow).toHaveBeenCalledWith([new Date('2014-07-01'), 300]);
    expect(this.dataTable.addRow).toHaveBeenCalledWith([new Date('2014-07-08'), 1000]);
    expect(this.dataTable.addRow).toHaveBeenCalledWith([new Date('2014-07-15'), 500]);
  });

  it('draws an area chart with the sensor graph data', function() {
    RemoteMonitoring.loadSensorGraph(this.$el);

    expect(this.areaChart.draw).toHaveBeenCalledWith(
      this.dataTable,
      jasmine.objectContaining({
        vAxis: jasmine.objectContaining({
          ticks: [
            { v:0, f:'0' },
            { v: 1200, f: '1.2KL' }
          ]
        })
      })
    );
  });

  it('draws an area chart within the date range given', function() {
    var minDate = new Date('2014-07-01T00:00:00.000Z');
    var today = new Date('2014-07-15T00:00:00.000Z');

    RemoteMonitoring.loadSensorGraph(this.$el);

    expect(this.areaChart.draw).toHaveBeenCalledWith(
      this.dataTable,
      jasmine.objectContaining({
        hAxis: jasmine.objectContaining({
          ticks: [ minDate, today ],
          viewWindow: { min: minDate, max: today }
        })
      })
    );
  });
});
