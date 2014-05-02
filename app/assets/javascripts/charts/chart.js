var dataConvert = function() {
    var cardsAndLogs = $('#chart_div').data('card_and_log');
    var convertedArray = [];
    $.each(cardsAndLogs, function(key, value) {
        if (key == 'logs' && value != null) {
            $.each(value, function (key, value) {
                var date = new Date(key * 1000);
                var tooltip = value;
                convertedArray.push([date, 0.5, tooltip, null, null]);
            });
        } else if (key == 'cards' && value != null) {
            $.each(value, function (key, value) {
                var date = new Date(key * 1000);
                var tooltip = value;
                convertedArray.push([date, null, null, 1, tooltip]);
            });
        }
    });

    return convertedArray;
};

function drawChart() {
    var data = new google.visualization.DataTable();
    data.addColumn('date', 'Date');
    data.addColumn('number', 'Logs');
    data.addColumn({type: 'string', role: 'tooltip'});
    data.addColumn('number', 'Cards');
    data.addColumn({type: 'string', role: 'tooltip', p: {'html': true}});
    data.addRows(dataConvert());

    var options = {
        tooltip: {isHtml: true, trigger: 'both'},
        vAxis: { textPosition: 'none', baselineColor: '#CCCCCC', gridlines: { count: 3 } },
        hAxis: { baselineColor: '#CCCCCC' },
        min: 0,
        max: 1,
        crosshair: { trigger: 'selection' },
        explorer: {},
        legend: { textStyle: { color: '#444444', fontName: 'Verdana', fontSize: '12' } }
    };

    var chart = new google.visualization.ScatterChart(document.getElementById('chart_div'));
    chart.draw(data, options);
}

google.load("visualization", "1", {packages:["corechart"]});
google.setOnLoadCallback(drawChart);
