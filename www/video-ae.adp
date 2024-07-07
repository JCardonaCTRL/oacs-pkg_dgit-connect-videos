<style>
    .error.invalid-feedback {color:#c30000;}
</style>
<formtemplate id="video_ae"></formtemplate>

<br>
<script type="text/javascript" <if @::__csp_nonce@ not nil> nonce="@::__csp_nonce;literal@"</if>>
    
    $("#video_ae").validate({
        errorElement: 'span',
        errorPlacement: function (error, element) {
            error.addClass('invalid-feedback');
            error.appendTo(element.closest('span'));
        },
        highlight: function (element, errorClass, validClass) {
            $(element).addClass('is-invalid');
        },
        unhighlight: function (element, errorClass, validClass) {
            $(element).removeClass('is-invalid');
            $(element).addClass('is-valid');
        }
    });
</script>
