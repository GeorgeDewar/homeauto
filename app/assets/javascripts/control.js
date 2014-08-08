$(function(){

    setActive();

    $('.no-radio input[type="radio"]').on("change", function(){
        setTimeout(setActive, 0);
    });

    function setActive(){
        $(".no-radio .ui-radio-off").removeClass("ui-btn-active");
        $(".no-radio .ui-radio-on").addClass("ui-btn-active");
    }

});
