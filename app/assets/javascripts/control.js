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
    $('input[data-type!="range"]').not('.name-change').on('change', submit);

    $('h2.name').click(function(){
        $(this).hide();
        $(this).parent().find('input.name-change').show().focus().select();
    });

    $('input.name-change').blur(function(){
        $(this).hide();
        $.ajax('/devices/' + $(this).parents('form').data('device-id') + '', {
            method: 'put',
            data: { 'device[name]': $(this).val() },
            success: function(){
                location.reload();
            }
        });
        $(this).parents('form').find('h2.name').show();
    });

    $('input.task-enabled').click(function(){
        $this = $(this);
        $.ajax('/tasks/' + $this.data('task-id'), {
            method: 'put',
            data: { 'task[enabled]': $(this).prop('checked') },
            success: function(){
                toast('Task ' + ($this.prop('checked') ? 'enabled' : 'disabled'));
            },
            error: function(){
                toast('Failed to ' + ($this.prop('checked') ? 'enable' : 'disable') + ' your task');
                $this.prop('checked', !$this.prop('checked'));
            }
        });
    });

});

var toast=function(msg){
    $("<div class='ui-loader ui-overlay-shadow ui-body-e ui-corner-all'><h3>"+msg+"</h3></div>")
        .css({ display: "block",
            opacity: 0.90,
            position: "fixed",
            padding: "7px",
            "text-align": "center",
            width: "270px",
            left: ($(window).width() - 284)/2,
            top: $(window).height()/2 })
        .appendTo( $.mobile.pageContainer ).delay( 1500 )
        .fadeOut( 400, function(){
            $(this).remove();
        });
}