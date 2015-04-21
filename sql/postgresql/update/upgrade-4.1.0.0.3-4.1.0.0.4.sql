SELECT acs_log__debug('/packages/intranet-timesheet2-workflow/sql/postgresql/upgrade/upgrade-4.1.0.0.3-4.1.0.0.4.sql','');

    select workflow__add_arc (
	         'timesheet_approval_wf',
	         'approve',
	         'before_deleted',
	         'out',
	         '',
	         '',
	         'Zeiterfassung NOK'
	    );
	
	
	
	    select workflow__delete_arc (
	         'timesheet_approval_wf',
	         'approve',
	         'start',
	     'out');

-- Close and remove timesheet_conf_object
create or replace function im_timesheet_workflow__reject_workflow (integer, text, text)
returns integer as '
declare
    p_case_id        alias for $1;
    p_transition_key alias for $2;
    p_custom_arg     alias for $3;
    v_task_id        integer;	
    v_case_id       integer;
    v_object_id     integer;	
    v_creation_user integer;
    v_creation_ip   varchar;
    	v_journal_id	    integer;
    v_transition_key  varchar;	
    v_workflow_key  varchar;
    v_status        varchar;
    v_str       text;
    row	        RECORD;
begin
    -- Select out some frequently used variables of the environment
    select	c.object_id, c.workflow_key, task_id, c.case_id
    into   	v_object_id, v_workflow_key, v_task_id, v_case_id
    from	    wf_tasks t, wf_cases c
    where   c.case_id = p_case_id
        and t.case_id = c.case_id
        and t.workflow_key = c.workflow_key
        and t.transition_key = p_transition_key;

    v_journal_id := journal_entry__new(
        null, v_case_id,
        v_transition_key || '' set_object_status_id '' || im_category_from_id(p_custom_arg::integer),
        v_transition_key || '' set_object_status_id '' || im_category_from_id(p_custom_arg::integer),
        now(), v_creation_user, v_creation_ip,
        ''Setting the status of "'' || acs_object__name(v_object_id) || ''" to "'' || 
        im_category_from_id(p_custom_arg::integer) || ''".''
    );

    PERFORM im_biz_object__set_status_id(v_object_id, p_custom_arg::integer);
    
    update im_hours set conf_object_id = null where conf_object_id = v_object_id;
   
    return 0;
end;' language 'plpgsql';

update wf_context_transition_info set fire_callback = 'im_timesheet_workflow__reject_workflow' where workflow_key = 'timesheet_approval_wf' and transition_key = 'deleted' and    context_key = 'default';