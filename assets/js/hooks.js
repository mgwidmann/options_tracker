import { TimeSeriesChart } from './charts';

export let Hooks = {}
Hooks.AddPosition = {
    mounted() {
        $('#position_stock_mobile:visible, #position_stock:visible').focus();
    }
};
Hooks.ClosePosition = {
    mounted() {
        $('#position_exit_price').focus();
    }
}
Hooks.CopyClipboard = {
    mounted() {
        let button = $("#copy-clipboard-button");
        let input = $("#copy-clipboard-input");
        let copyClipboard = () => {
            input.focus();
            input[0].select();
            input[0].setSelectionRange(0, 99999);
            document.execCommand("copy");
            input.attr('data-tooltip', "Copied!");
            button.attr('data-tooltip', "Copied!");
        };
        button.on('click', copyClipboard);
        input.on('click', copyClipboard);
    }
}
Hooks.ShowNotes = {
    mounted() {
        $(this.el).next('.notes').add($(this.el)).click((evt) => {
            if (evt.target.tagName != "A" && evt.target.tagName != "I") {
                const notes = $(this.el).next('.notes')
                notes.toggleClass('show');
            }
        });
    }
}
Hooks.StatisticsChart = {
    mounted() {
        this.initChart();
    },

    updated() {
        this.initChart();
    },

    initChart() {
        if (this.chart) {
            this.chart.destroy();
        }
        var ctx = $('#chart');
        var pl = JSON.parse(ctx.attr('data-profit-loss'));
        var wins = JSON.parse(ctx.attr('data-wins'));
        var weightedWins = JSON.parse(ctx.attr('data-weighted-wins'));
        this.chart = new TimeSeriesChart(ctx, {
            leftAxis: 'Profit / Loss',
            leftAxisColor: "rgb(72, 199, 0)", // #48C700 text-success
            rightAxis: 'Weighted Win %',
            rightAxisColor: "rgb(50, 152, 220)", // #3298dc text-info
            title: 'Profit / Loss vs Weighted Win %',
            leftAxisData: pl,
            rightAxisData: weightedWins,
        });
    }
}