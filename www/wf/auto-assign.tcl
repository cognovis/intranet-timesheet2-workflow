ad_page_contract {
    @author Neophytos Demetriou
} {
    task_id:naturalnum
    continue_url:notnull,trim
}

set current_user_id [ad_get_user_id]

db_exec_plsql assign_to_user \
    "select im_workflow__assign_to_user(:task_id,:current_user_id)"

ad_returnredirect $continue_url
