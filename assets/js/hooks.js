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