ad_library {
    Web Service API to handle DGSOM Connect App

    @creation-date: 2021-03-15
    @author: Josue Cardona <jcardona@mednet.ucla.edu>
}

namespace eval dgit::connect_videos::api {}

ad_proc -public dgit::connect_videos::api::get_videos {
    -appCode:required
} {
    set response_code       ""
    set response_message    ""
    set response_body       ""
    set continue_p          1

    ctrl::oauth::check_auth_header
    set user_id     $user_info(user_id)
    set token_str   $user_info(cust_acc_token)

    set tile_id     [dap::tile::getIdFromAppCode -app_code $appCode]
    set package_id  [dap::tile::getAppCustomProperty \
                            -tile_id $tile_id \
                            -property "refPackageId" \
                            -default_value -1]

    if {$user_id eq "" || $user_id == 0} {
        set response_code       "INVALID"
        set response_message    "Unauthorized : Undefined user"
        set continue_p 0
    }

    if {$continue_p} {
        set field_json      ""
        db_foreach select "" {
            set field_list      [list]
            set image64 ""
            if { $image_id ne ""} {
                set version_id  [content::item::get_live_revision -item_id $image_id]
                set path        [cr_fs_path $storage_area_key]
                set filename    [db_string select_filename "" -default ""]

                if {$filename ne ""} {
                    set fd [open $filename "r"]
                    fconfigure $fd -translation binary
                    set rawData [read $fd]
                    close $fd
                    package require base64
                    set image64     [base64::encode $rawData]
                    set image64     "[string map [list "\n" ""] $image64]"
                }
            }

            lappend field_list  [list title       "$title"      ""]
            lappend field_list  [list image64     "$image64"    ""]
            lappend field_list  [list video_link  "$video_link" ""]

            lappend field_json  [list [ctrl::json::construct_record $field_list]]
        }
        set body    [ctrl::json::construct_record   [list [list "videoList" "$field_json" "a"]]]

        set response_code       "Ok"
        set response_message    "Connect videos list"
        set response_body       $body
    }
    if {$response_body eq ""} {
        set return_data_json [ctrl::restful::api_return -response_code "$response_code" \
                                                        -response_message "$response_message" \
                                                        -response_body ""]
    } else {
        set return_data_json [ctrl::restful::api_return -response_code "$response_code" \
                                                        -response_message "$response_message" \
                                                        -response_body "$response_body" \
                                                        -response_body_value_p f]
    }
    doc_return 200 text/json $return_data_json
    ad_script_abort
}
