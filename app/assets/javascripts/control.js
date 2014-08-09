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

});
