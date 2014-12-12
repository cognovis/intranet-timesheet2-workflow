ad_page_contract {
    @author Neophytos Demetriou
} {
    task_id:naturalnum
    continue_url:notnull,trim
}

set current_user_id [ad_get_user_id]

if { ![im_permission $current_user_id view_hr] } { 
    # auto-assign.tcl page is only to be used by the project
    # approval component and so we require the same privileges
    # before we auto-assign the user to the given task, 
    # here we redirect and let the target page decide
    ad_returnredirct $continue_url
    ad_script_abort
    return
}

db_exec_plsql assign_to_user \
    "select im_workflow__assign_to_user(:task_id,:current_user_id)"

ad_returnredirect $continue_url
