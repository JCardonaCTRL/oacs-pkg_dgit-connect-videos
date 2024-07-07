#/packages/fgit/www/index.tcl
ad_page_contract {
    Connect Videos Main Page

    @creation-date: 2021-03-15
    @author: Josue Cardona <jcardona@mednet.ucla.edu>
} {

}

## -------------------------------------------------------------------------------
##   Permission
## -------------------------------------------------------------------------------
set login_user_id   [auth::require_login]
set package_id      [ad_conn package_id]
set package_url     [ad_conn package_url]
set return_url      [ad_return_url]
set header          [ad_conn instance_name]

set title           "Video Links"
set action          "Add Video Link"
set context         [list $title]

set ajax_url        "${package_url}video-list-ajax?[export_vars {package_id}]"
set video_ae_url    "${package_url}video-ae"
set video_del_url   "${package_url}video-del"

template::head::add_css -href "//cdn.datatables.net/2.0.3/css/dataTables.dataTables.min.css" -order 99
template::head::add_javascript -src "//cdn.datatables.net/2.0.3/js/dataTables.min.js" -order 99
template::head::add_javascript -src "//cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.19.1/jquery.validate.min.js" -order 100

security::csp::require script-src cdn.datatables.net
security::csp::require style-src cdn.datatables.net

security::csp::require script-src "'strict-dynamic' 'unsafe-eval'"

security::csp::require style-src cdnjs.cloudflare.com
security::csp::require style-src cdn.datatables.net
security::csp::require style-src www.gravatar.com

security::csp::require script-src cdnjs.cloudflare
security::csp::require script-src cdn.datatables.net
security::csp::require script-src cdn.jsdelivr.net
security::csp::require script-src www.gravatar.com

security::csp::require img-src cdn.datatables.net
