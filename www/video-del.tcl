ad_page_contract {
    Delete video

    @creation-date: 2021-03-17
    @author: Josue Cardona <jcardona@mednet.ucla.edu>
} {
    {video_id:integer,notnull}
}

dgit::connect_videos::get -video_id $video_id -column_array "video_info"

ad_form \
    -name video_del \
    -has_submit 1 -has_edit 1 \
    -export {video_id} \
    -form {
    {help_text:text(hidden),optional}
} -on_submit {
    db_transaction {
        dgit::connect_videos::delete -video_id $video_id
        #Return information
        set return_status   "success"
        set return_code     "0"
        set return_message  "Video removed"
        set return_debug    ""
    } on_error {
        #Return information
        set return_status   "error"
        set return_code     "-1"
        set return_message  "Video not removed"
        set return_debug    "$errmsg"
    }
} -after_submit {
    set record      [list]
    lappend record  [list code      $return_code    n]
    lappend record  [list status    $return_status  n]
    lappend record  [list message   $return_message n]

    if {$return_debug ne ""} {
        ns_log error "DGIT Connect Videos: $return_debug"
    }

    set response    [ctrl::json::construct_record  [list  [list "" [ctrl::json::construct_record $record] o]  ]  ]
    doc_return 200 text/json $response
    ad_script_abort
}
