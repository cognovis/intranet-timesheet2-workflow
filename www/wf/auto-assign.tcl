ad_page_contract {
    @author Neophytos Demetriou
} {
    project_id:naturalnum
    task_id:naturalnum
    continue_url:notnull,trim
}

if {$project_id ne ""} {
    # make sure task and project are consistent
    set sql "select object_id_two from acs_rels where object_id_one=:project_id"
    set project_member_ids [db_list project_members $sql]
    set sql "
    select 1 
    from wf_task_assignments wta
    inner join wf_tasks t
    on (wta.task_id = t.task_id)
    where wta.task_id=:task_id 
    and wta.party_id in ([template::util::tcl_to_sql_list $project_member_ids]) 
    and t.workflow_key = 'timesheet_approval_wf'
    limit 1
"
    set task_in_project_p [db_string task_in_project_p $sql -default 0]
    if { !$task_in_project_p } {
	error "no such task in project"
    }

    set current_user_id [ad_get_user_id]

    set project_manager_p [im_biz_object_admin_p $current_user_id $project_id]

    if {$project_manager_p } { 
	db_exec_plsql assign_to_user \
	"select im_workflow__assign_to_user(:task_id,:current_user_id)"
    }

}

ad_returnredirect $continue_url
