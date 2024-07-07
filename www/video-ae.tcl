ad_page_contract {
    Add / Edit Video Form

    @creation-date: 2021-03-17
    @author: Josue Cardona <jcardona@mednet.ucla.edu>
} {
    {package_id}
    {video_id:integer,optional}
}

## ------------------------------------------------------------------------------
## Initial settings
## ------------------------------------------------------------------------------
set login_user_id   [auth::require_login]
set fs_package_id   [parameter::get -parameter "fileStorageID" -package_id $package_id]
set video_folder_id [dgit::connect_videos::get_videos_folder_id -package_id $package_id]
set thumbnail       ""

if {[info exists video_id]} {
    set old_image_id    [db_string get_image_id "" -default ""]
    if { $old_image_id ne ""} {
        set file_name   [fs::get_object_name -object_id $old_image_id]
        set fs_url      "/file/$old_image_id/$file_name"
        set thumbnail   "Current image: <img src='$fs_url' width='100' height='100'>"
    }
}

ad_form -name video_ae -export {package_id} -html {enctype "multipart/form-data"} -has_submit 1 -has_edit 1  -form {
    {video_id:key}
    {upload_image_file:file(file),optional
        {label "Upload Thumbnail:"}
        {help_text "Valid image types are: .gif .jpg .jpeg .jpe .png "}
        {after_html "$thumbnail"}
    }
    {title:text
        {label "Title:"}
        {html {size 81 maxlength 300 required required}}
    }
    {video_link:text(url)
        {label "URL:"}
        {html {size 81 maxlength 300 required required}}
        {help_text "Example: https://youtu.be/dQw4w9WgXcQ?si=UMgbbBzGYj7CZ5Yn"}
    }
    {description:text(textarea),optional
        {label "Description:"}
        {html {rows 4 cols 80 maxlength 500}}
    }
} -edit_request {
    if [dgit::connect_videos::get -video_id $video_id -column_array "video_info"] {
        set image_id    $video_info(image_id)
        set title       $video_info(title)
        set video_link  $video_info(video_link)
        set description $video_info(description)
    }
} -new_data {
    db_transaction {
        set continue_p 1
        if {"$upload_image_file" ne ""} {
            set file_name   [template::util::file::get_property filename $upload_image_file]
            set tmpfile     [template::util::file::get_property tmp_filename $upload_image_file]
            set mime_type   [cr_filename_to_mime_type -create $file_name]
            set image_ext [file extension $file_name]
            
            if {$image_ext != ".gif" &&
                $image_ext != ".jpg" &&
                $image_ext != ".jpeg" &&
                $image_ext != ".jpe" &&
                $image_ext != ".png" } {
                
                set return_status   "error"
                set return_code     "-1"
                set return_message  "Invalid image type $image_ext."
                set return_debug    "The upload file has a wrong image file type $image_ext"
                set continue_p 0
            }

            if $continue_p {
                # Get the dimensions of the image
                lassign [ctrl::image::dimensions -file $tmpfile] width height

                # Resize the image if it is too big
                if {$width >= 1024 || $height >= 768} {
                    # Resize the image so that neither dimension is exceeds the limits above.
                    # This will preserve aspect ratio.
                    set new_tmpfile [ns_mktemp "/tmp/dgit_connect_video_scaled_event_photoXXXXXX"]
                    exec convert $tmpfile -strip -resize 1024x768 $new_tmpfile
                    file rename -force $new_tmpfile $tmpfile
                }
                set revision_id [fs::add_file \
                                -name           $file_name \
                                -parent_id      $video_folder_id \
                                -package_id     $fs_package_id \
                                -tmp_filename   $tmpfile \
                                -mime_type      $mime_type]

                set image_id    [content::revision::item_id -revision_id $revision_id]
                content::item::rename -item_id $image_id -name "${file_name}"
            }
        } else {
            set image_id ""
        }

        if $continue_p {
            dgit::connect_videos::new \
                -creation_user  $login_user_id \
                -package_id     $package_id \
                -image_id       $image_id \
                -title          $title \
                -video_link     $video_link \
                -description    $description
        
                #Return information
            set return_status   "success"
            set return_code     "0"
            set return_message  "Video added"
            set return_debug    ""
        }
    } on_error {
        #Return information
        set return_status   "error"
        set return_code     "-1"
        set return_message  "Video not added"
        set return_debug    "$errmsg"
    }
} -edit_data {
    db_transaction {
        set continue_p 1
        if {"$upload_image_file" ne ""} {
            set file_name   [template::util::file::get_property filename $upload_image_file]
            set tmpfile     [template::util::file::get_property tmp_filename $upload_image_file]
            set mime_type   [cr_filename_to_mime_type -create $file_name]
            set image_ext [file extension $file_name]

            if {$image_ext != ".gif" &&
                $image_ext != ".jpg" &&
                $image_ext != ".jpeg" &&
                $image_ext != ".jpe" &&
                $image_ext != ".png" } {

                set return_status   "error"
                set return_code     "-1"
                set return_message  "Invalid image type $image_ext."
                set return_debug    "The upload file has a wrong image file type $image_ext"
                set continue_p 0
            }

            if $continue_p {
                # Get the dimensions of the image
                lassign [ctrl::image::dimensions -file $tmpfile] width height

                # Resize the image if it is too big
                if {$width >= 1024 || $height >= 768} {
                    # Resize the image so that neither dimension is exceeds the limits above.
                    # This will preserve aspect ratio.
                    set new_tmpfile [ns_mktemp "/tmp/dgit_connect_video_scaled_event_photoXXXXXX"]
                    exec convert $tmpfile -strip -resize 1024x768 $new_tmpfile
                    file rename -force $new_tmpfile $tmpfile
                }

                set image_id [db_string get_image_id "" -default ""]

                if {$image_id ne ""} {
                    set revision_id [fs::add_version \
                                    -package_id     $fs_package_id \
                                    -name           $file_name  \
                                    -item_id        $image_id \
                                    -tmp_filename   $tmpfile \
                                    -mime_type      $mime_type]
                } else {
                    set revision_id [fs::add_file \
                                    -package_id     $fs_package_id \
                                    -parent_id      $video_folder_id \
                                    -name           $file_name \
                                    -tmp_filename   $tmpfile \
                                    -mime_type      $mime_type]
                }

                set image_id [content::revision::item_id -revision_id $revision_id]
                content::item::rename -item_id $image_id -name "${file_name}"
            }
        } else {
            set image_id [db_string get_image_id "" -default ""]
        }

        if $continue_p {
            if {"$image_id" eq ""} {
                dgit::connect_videos::edit \
                    -video_id       $video_id \
                    -title          $title \
                    -video_link     $video_link \
                    -description    $description \
                    -modifying_user $login_user_id
            } else {
                dgit::connect_videos::edit \
                    -video_id       $video_id \
                    -image_id       $image_id \
                    -title          $title \
                    -video_link     $video_link \
                    -description    $description \
                    -modifying_user $login_user_id
            }
            #Return information
            set return_status   "success"
            set return_code     "0"
            set return_message  "Video updated"
            set return_debug    ""
        }
    } on_error {
        #Return information
        set return_status   "error"
        set return_code     "-1"
        set return_message  "Video not updated"
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
