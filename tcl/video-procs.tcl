# /packages/fgit/tcl/video-procs.tcl
ad_library {
    Set of TCL procedures to handle fgit_videos table

    @author: weixiayu@mednet.ucla.edu
    @creation-date: 2020-02-13
}

namespace eval dgit::connect_videos {}

ad_proc -public dgit::connect_videos::get_main_folder_id {
    -package_id:required
} {
    Return a folder_id of connect videos in file storage
} {

    set fs_package_id   [parameter::get -parameter "fileStorageID" -package_id $package_id]
    set root_folder_id  [fs::get_root_folder -package_id $fs_package_id]

    set folder_name     "connect-videos-$package_id"
    set folder_id       [fs::get_folder -name $folder_name -parent_id $root_folder_id]

    if {$folder_id eq ""} {
        set folder_id   [fs::new_folder \
                            -name       $folder_name \
                            -pretty_name $folder_name \
                            -parent_id  $root_folder_id \
                            -package_id $fs_package_id]
    }
    return $folder_id
}

ad_proc -public dgit::connect_videos::get_videos_folder_id {
    -package_id:required
} {
    Return a folder_id of videos in file storage
} {
    set fs_package_id   [parameter::get -parameter "fileStorageID" -package_id $package_id]
    set main_folder_id  [dgit::connect_videos::get_main_folder_id -package_id $package_id]

    set folder_name     "videos"
    set folder_id       [fs::get_folder -name $folder_name -parent_id $main_folder_id]

    if {$folder_id eq ""} {
        set folder_id   [fs::new_folder \
                            -name       $folder_name \
                            -pretty_name $folder_name \
                            -parent_id  $main_folder_id \
                            -package_id $fs_package_id]
    }
    return $folder_id
}

ad_proc -public dgit::connect_videos::new {
    -creation_user:required
    -title:required
    -package_id:required
    {-video_id      ""}
    {-image_id      ""}
    {-video_link    ""}
    {-description   ""}
} {
    Insert a new record into dgit_connect_videos table
} {

    if {$video_id eq ""} {
        set video_id    [db_nextval "dgit_connect_videos_id_seq"]
    }

    db_transaction {
        db_dml insert_video ""
    } on_error {
        db_abort_transaction
        error "An error occured while adding a video to dgit_connect_videos table. Error: $errmsg"
    }
    return $video_id
}

ad_proc -public dgit::connect_videos::edit {
    -video_id:required
    -modifying_user:required
    {-title}
    {-image_id}
    {-video_link}
    {-description}
} {
    Edit a record in dgit_connect_videos table
} {
    set success_p 1
    set sql_update_list     [list]
    set fields_to_update    [list image_id title video_link description]

    foreach field $fields_to_update {
        if {[info exists $field]} {
            lappend sql_update_list "$field = :$field"
        }
    }

    if {$sql_update_list ne ""} {
        set sql_update_list [join $sql_update_list ,]
        db_transaction {
            db_dml update_video ""
            set success_p 1
        } on_error {
            set success_p 0
            db_abort_transaction
        }
        if {!$success_p} {
            error "An error occured while editing video. Error: $errmsg"
        }
    }
    return $success_p
}

ad_proc -public dgit::connect_videos::get {
    {-video_id:required}
    {-column_array "video_info"}
} {
    Get all information for a specific record in dgit_connect_videos table
    Return an array of all column information
} {
    upvar $column_array row
    return [db_0or1row get_video_info "" -column_array row]
}

ad_proc -public dgit::connect_videos::delete {
    {-video_id:required}
} {
    Delete a record in dgit_connect_videos table
} {

    db_transaction {
        db_dml delete_video ""
        set success_p 1
    } on_error {
        set success_p 0
        db_abort_transaction
    }
    if {!$success_p} {
        error "An error occoured while deleting video. Error: $errmsg"
        ad_script_abort
    }
    return $success_p
}
