<master>
<property name="doc(title)">@title;literal@</property>
<property name="title">@title;literal@</property>
<property name="context">@context;literal@</property>

<div class="container">
    <div class="row">
      <div class="col-sm-4"><h1>@header@</h1></div>
      <div class="col-sm-8" style="padding-top:20px;">
        <button type="button"
                class='btn btn-success btn_videos'
                data-action_type='add'
                data-title='@action;literal@'
                data-btn_save_text='Add'
                title='@action;literal@'>@action;literal@</button>
      </div>
    </div>
	<hr>
    <div id="message"></div>
    <div class="table-responsive">
      <table cellpadding="0" cellspacing="0" border="0" class="table table-condensed table-striped" id="videos_list" width="100%"> </table>
    </div>
</div>

<script type="text/javascript" src="/resources/dgit-connect-videos/js/jquery.bootstrap.js" <if @::__csp_nonce@ not nil> nonce="@::__csp_nonce;literal@"</if>></script>
<script type="text/javascript" <if @::__csp_nonce@ not nil> nonce="@::__csp_nonce;literal@"</if>>
    // ---- Used for upload file in a dialog ----
    (function($) {
        $.fn.serializefiles = function() {
            var obj = $(this);
            /* ADD FILE TO PARAM AJAX */
            var formData = new FormData();
            $.each($(obj).find("input[type='file']"), function(i, tag) {
                $.each($(tag)[0].files, function(i, file) {
                    formData.append(tag.name, file);
                });
            });
            var params = $(obj).serializeArray();
            $.each(params, function (i, val) {
                formData.append(val.name, val.value);
            });
            return formData;
        };
    })(jQuery);

    $(document).ready(function() {
        $('#videos_list').DataTable ({
          "columns": [
              {"data": "thumbnail",     "title": "Thumbnail",   "orderable": true,  "class": "center", "width":"120px"},
              {"data": "title",         "title": "Title",       "orderable": true,  "class": "left"},
              {"data": "video_link",    "title": "URL",         "orderable": true,  "class": "left"},
              {"data": "description",   "title": "Description", "orderable": true,  "class": "left"},
              {"data": "creation_user", "title": "Created By",  "orderable": true,  "class": "left"},
              {"data": "creation_date", "title": "Created At",  "orderable": true,  "class": "left"},
              {"data": "modifying_user","title": "Modified By", "orderable": true,  "class": "left"},
              {"data": "last_modified", "title": "Modified At", "orderable": true,  "class": "left"},
              {"data": "actions",       "title": "Actions",     "orderable": false, "class": "center"}
          ],
          "processing": false,
          "serverSide": false,
          "ajax": {
              "url":"@ajax_url;literal@",
          },
          "order": []
        });
    });

    //Binding functions
    $(document).on('click', '.btn_videos', function() {
        //Local Variables
        let title           = $(this).data('title');
        let btn_save_text   = $(this).data('btn_save_text');
        let video_id        = $(this).data('video_id');
        let action_type     = $(this).data('action_type');
        let url             = "";
        //URL Transformation
        switch (action_type) {
            case 'add':
            case 'edit':
                url = "@video_ae_url;literal@";
            break;
            case 'delete':
                url = "@video_del_url;literal@";
            break;
        }
        //Modal Creation
        var $dialog = $('<div id="modal_video"></div>')
        .load(
            url,
            {video_id: video_id, package_id: @package_id@},
            function (responseText, textStatus, req) {
                if (textStatus == "error") {
                    mainMessage('danger', 'Loading Error', responseText);
                    window.location.reload();
                }
            }
        ).dialog({
            autoOpen: true,
            dialogClass: "no-close",
            title: title,
            modal: true,
            resizable: false,
            backdrop: 'static',
            keyboard: false,
            buttons: [
                {
                    text: "Close",
                    'class': "btn btn-secondary mr-auto",
                    click: function() {
                        $(this).dialog("destroy");
                    }
                },
                {
                    text: btn_save_text,
                    'class': "btn btn-primary btn_save",
                    click: function() {
                        if ($("#modal_video form").valid()) {
                            $(".btn_save").prop('disabled','disabled');
                            $.ajax({
                                type: "POST",
                                enctype: 'multipart/form-data',
                                processData: false, // Important!
                                contentType: false,
                                url: $("#modal_video form").attr('action'),
                                data: $("#modal_video form").serializefiles(),
                                success: function (data, textStatus, jqXHR) {
                                    var ct = jqXHR.getResponseHeader("content-type") || "";
                                    //  Handle json response
                                    if (ct.indexOf('json') > -1) {
                                       //var result = JSON.parse(data);
                                       if (data.code == 0) {
                                            //Success
                                            mainMessage('success','Submission Success', data.message,5000);
                                            $('#videos_list').DataTable().ajax.reload();
                                        } else {
                                            //Error
                                            mainMessage('danger', 'Submission Error', data.message,10000);
                                        }
                                    } else {
                                        //Bad format error
                                        mainMessage('warning', 'Format Error', 'Submission returned an invalid format',10000);
                                    }
                                    $dialog.dialog("destroy");
                                },
                                beforeSend: function() {
                                    //console.log("Sending ...");
                                },
                                error: function (jqXHR, textStatus, errorThrown) {
                                    console.log('jqXHR', jqXHR);
                                    console.log('textStatus', textStatus);
                                    console.log('errorThrown', errorThrown);
                                    if (errorThrown == 'Unauthorized') {
                                        mainMessage('danger', 'Loading Error', jqXHR.responseText,10000);
                                        window.location.reload();
                                    } else {
                                        mainMessage('danger', 'Loading Error', 'Page not found',10000);
                                    }
                                    $dialog.dialog("destroy");
                                }
                            });
                        }
                    }
                }
            ]
        });

        $dialog.dialog('open');
        //JC: we need this to destroy the modal on close so the form validation gets triggered always
        $('.modal [data-dismiss="modal"]').click(function () {
            $dialog.dialog("destroy");
        });
    });

    function mainMessage(alert_class, title, message, time) {
        $('<div class="alert alert-'+alert_class+'"> '+
          '<a href="#" class="close" data-dismiss="alert" aria-label="close" style="text-decoration:none;">&times;</a>'+
          '<strong>'+title+'!</strong> '+message+'.</div>').
        appendTo("#message").
        fadeTo(time, 500).slideUp(500, function(){
            $(this).alert('close');
        });
    }
</script>
