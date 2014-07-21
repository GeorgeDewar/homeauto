$(function(){
    $('input[type="range"]').change(function(){
       var id = $(this).attr('id');
       $('#' + id + '-val').val($(this).val());
    });
});
