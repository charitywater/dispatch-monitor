(function(RemoteMonitoring, $, google) {
  'use strict';

  function createSensorGraphDataTable(graphData) {
    var dataTable = new google.visualization.DataTable();
    dataTable.addColumn('date', 'Date');
    dataTable.addColumn('number', 'Water Flow (L)');

    graphData.forEach(function(day) {
      var date = new Date(day.date);
      var liters = day.liters;
      dataTable.addRow([date, liters]);
    });

    var dateFormatter = new google.visualization.DateFormat({ timeZone: 0 });
    dateFormatter.format(dataTable, 0);

    return dataTable;
  }

  function getMaxLiters(graphData) {
    var maxLiters = 0;
    graphData.forEach(function(day) {
      maxLiters = Math.max(day.liters, maxLiters);
    });
    return maxLiters * 1.2;
  }

  var defaultGraphOptions = {
    fontName: 'Proxima Nova',
    hAxis: {
      baselineColor: '#ffffff',
      format: 'yyyy-MM-dd',
      gridlines: {
        color: 'white'
      }
    },
    vAxis: {
      minValue: 0,
      gridlines: {
        color: 'f7f7f7'
      }
    },
    legend: { position: 'none' },
    chartArea: {
      left: 60,
      top: 10,
      width: '75%',
      height: '80%',
      backgroundColor: 'f7f7f7'
    },
    areaOpacity: '0.9',
    series: [{
      color: '51a583'
    }]
  };

  function getGraphOptions(graphData) {
    var maxLiters = Math.max(getMaxLiters(graphData), 1);
    var prefixes = ['L', 'KL', 'ML', 'GL', 'TL', 'PL'];
    var humanizedMaxLiters = humanize.intword(maxLiters, prefixes, 1000, 1);

    var minDate = new Date(_(graphData).first().date);
    var maxDate = new Date(_(graphData).last().date);

    return {
      hAxis: {
        ticks: [ minDate, maxDate ],
        viewWindow: { min: minDate, max: maxDate }
      },
      vAxis: {
        maxValue: maxLiters,
        ticks: [
          { v:0, f:'0' },
          { v: maxLiters, f: humanizedMaxLiters }
        ]
      }
    };
  }

  RemoteMonitoring.loadSensorGraph = function loadSensorGraph($el) {
    var graphData = $el.data('sensor').graph_data;
    var dataTable = createSensorGraphDataTable(graphData);

    var options = $.extend(
      true,
      getGraphOptions(graphData),
      defaultGraphOptions
    );

    var chart = new google.visualization.AreaChart($el.get(0));
    chart.draw(dataTable, options);
  };
})(RemoteMonitoring, jQuery, google);
