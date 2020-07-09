export let Hooks = {}
Hooks.AddPosition = {
    mounted() {
        $('#position_stock_mobile:visible, #position_stock:visible').focus();
    }
}