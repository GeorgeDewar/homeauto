$( document ).on( "pageinit", function(){

    setActive();

    $('.no-radio input[type="radio"]').on("change", function(){
        setTimeout(setActive, 0);
    });

    function setActive(){
        $(".no-radio .ui-radio-off").removeClass("ui-btn-active");
        $(".no-radio .ui-radio-on").addClass("ui-btn-active");
    }

    submit = function(){
        $(this).closest('form').submit();
    }

    $('input[data-type="range"]').on('slidestop', submit);
    $('input[data-type!="range"]').on('change', submit);

    $('h2.name').click(function(){
        $(this).hide();
        $(this).parent().find('input.name-change').show().focus().select();
    });

    $('input.name-change').blur(function(){
        $(this).hide();
        $.ajax('/devices/' + $(this).parents('form').data('device-id') + '', {
            method: 'put',
            data: { 'device[name]': $(this).val() }
        });
        $(this).parents('form').find('h2.name').show();
    });

});
