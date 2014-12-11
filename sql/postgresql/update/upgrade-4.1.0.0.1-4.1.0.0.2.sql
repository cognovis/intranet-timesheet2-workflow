SELECT acs_log__debug('/packages/intranet-timesheet2-workflow/sql/postgresql/upgrade/upgrade-4.1.0.0.1-4.1.0.0.2.sql','');

-- -------------------------------------------------------
-- Update the Arcs to go to finish immediately
-- -------------------------------------------------------
update wf_arcs set place_key ='before_deleted' where workflow_key = 'vacation_approval_wf' and transition_key = 'approve' and place_key='start';        
update wf_arcs set place_key ='before_deleted' where workflow_key = 'hr_vacation_approval_wf' and transition_key = 'approve' and place_key='start';
update wf_arcs set place_key ='before_deleted' where workflow_key = 'hr_vacation_approval_wf' and transition_key = 'hr_approve' and place_key='start';
