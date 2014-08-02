$(function(){
//    $('input[type="range"]').change(function(){
//       var id = $(this).attr('id');
//       $('#' + id + '-val').val($(this).val());
//    });

    var select = $( "#temp" );
    console.log(select);
    var slider = $('#temp-slider').slider({
        min: 16,
        max: 30,
        range: "min",
        value: select.val(),
        slide: function( event, ui ) {
            select.val(ui.value);
        }
    });
    select.change(function() {
        slider.slider( "value", $(this).val() );
    });

});
