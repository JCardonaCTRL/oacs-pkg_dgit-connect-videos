#/packages/fgit/admin/video-list-ajax.tcl
ad_page_contract {
    Video List AJAX

    @creation-date: 2021-03-17
    @author: Josue Cardona <jcardona@mednet.ucla.edu>
} {
    package_id:integer
}

# -------------------------------------------------------------------------------
# Login Validation
# -------------------------------------------------------------------------------
set login_user_id   [auth::require_login]
set permission_p    [permission::permission_p -party_id $login_user_id -object_id $package_id -privilege "admin"]

## ------------------------------------------------------------------------------
## Initial settings
## ------------------------------------------------------------------------------
set videos_list_js    ""
db_foreach get_videos "" {
    ## Actions list
    set actions ""
    if {$permission_p} {
        append actions "<button \
                            class='btn btn-info btn-xs btn_videos' \
                            data-action_type='edit' \
                            data-title='Edit Video Link' \
                            data-btn_save_text='Edit' \
                            data-video_id='$video_id' \
                            title='Edit Video'>Edit\
                          </button>"


        append actions "&nbsp;<button \
                        class='btn btn-danger btn-xs btn_videos' \
                        data-action_type='delete' \
                        data-title='Remove Video Link' \
                        data-btn_save_text='Remove' \
                        data-video_id='$video_id' \
                        title='Remove Video'>Remove\
                      </button>"
    }
    if {$image_id ne ""} {
        set file_name [fs::get_object_name -object_id $image_id]
        set fs_url "/file/$image_id/$file_name"
        set thumbnail "<img src='$fs_url' width='100' height='100'>"
    } else {
        set thumbnail "No Image"
    }

    if {[string length $title] > 80} {
       set title_trim "[string range $title 0 80] <img src='/resources/images/note-full.png' width='30' height='21'>"
       set title    "$title_trim <span style='display:none';>$title</span> "
    }

    if {[string length $description] > 50} {
        set description_trim "[string range $description 0 50] <img src='/resources/images/note-full.png' width='30' height='21'>"
        set description "$description_trim <span style='display:none';>$description</span> "
     }
    ## Videos list
    set videos_list       ""
    lappend videos_list   [list thumbnail       "$thumbnail" ""]
    lappend videos_list   [list title           "$title" ""]
    lappend videos_list   [list video_id        "$video_id" ""]
    lappend videos_list   [list video_link      "$video_link" ""]
    lappend videos_list   [list description     "$description" ""]

    lappend videos_list   [list creation_date   "$creation_date" ""]
    lappend videos_list   [list last_modified   "$last_modified" ""]

    lappend videos_list   [list creation_user   "$creation_user" ""]
    lappend videos_list   [list modifying_user  "$modifying_user" ""]

    lappend videos_list   [list actions         "$actions" ""]

    ## Learners list Json Parse
    lappend videos_list_js    [list [ctrl::json::construct_record $videos_list]]
}

set result_array    [ctrl::json::construct_record [list [list "data" "$videos_list_js" "a"]]]
set result_object   [ctrl::json::construct_record [list [list "" "$result_array" "o"]]]

doc_return 200 text/json "$result_object"
