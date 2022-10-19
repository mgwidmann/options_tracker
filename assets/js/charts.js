export let Charts = {};

export class TimeSeriesChart {
  constructor(element, options = {}) {
    this.element = element;
    this.options = options;

    this.chart = Chart.Line(this.element, {
      data: {
        datasets: [{
          label: this.options.leftAxis,
          borderColor: this.options.leftAxisColor,
          backgroundColor: this.options.leftAxisColor,
          fill: false,
          data: this.options.leftAxisData,
          yAxisID: 'left-axis',
        }, {
          label: this.options.rightAxis,
          borderColor: this.options.rightAxisColor,
          backgroundColor: this.options.rightAxisColor,
          fill: false,
          data: this.options.rightAxisData,
          yAxisID: 'right-axis'
        }]
      },
      options: {
        responsive: true,
        hoverMode: 'index',
        stacked: false,
        title: {
          display: true,
          text: this.options.title,
        },
        scales: {
          xAxes: [{
            type: 'time',
            time: {
              displayFormats: {
                day: 'MM/DD',
                week: 'MMM D',
                month: 'MMM',
              }
            },
            distribution: 'series'
          }],
          yAxes: [{
            type: 'linear',
            display: true,
            position: 'left',
            id: 'left-axis',
          }, {
            type: 'linear',
            display: true,
            position: 'right',
            id: 'right-axis',

            gridLines: {
              drawOnChartArea: false, // only want the grid lines for one axis to show up
            },
          }],
        }
      }
    });
  }

  destroy() {
    this.chart.destroy();
  }
}