//
//  QueryFile.swift
//  thecareportal
//
//  Created by Jayesh on 08/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//


// Query for fetching visit outcomes
/*
select hcvl.visit_log_id
,hcvl.visit_start_time
,hcvl.visit_end_time
,hcvl.visit_title,hcvl.visit_description
,(select
('[' ||
GROUP_CONCAT(
('{"outcome_id":"' || tbl.outcome_id || '", "outcome_title":"' || tbl.outcome_title || '", "total_outcomes":"' || tbl.total_outcomes || '"}' )
) || ']') ashwin_column

from
(
select
sub_ho.outcome_id
,sub_ho.outcome_title
,count(sub_ho.outcome_id) as total_outcomes
from hc_client_visit_log as sub_hcvl
left join hc_client_task_log as sub_hctl on sub_hctl.visit_log_id = sub_hcvl.visit_log_id
left join hc_client_outcomes as sub_hco on sub_hco.client_outcome_id = sub_hctl.outcome_id
left join hc_outcomes as sub_ho on sub_ho.outcome_id = sub_hco.outcome_id

where
sub_hcvl.status = 1 and
sub_hcvl.deleted_at is null and
sub_hcvl.visit_log_id = hcvl.visit_log_id
group by sub_hcvl.visit_log_id, sub_ho.outcome_id) as tbl) as ashwin_column


from hc_client_visit_log as hcvl
left join hc_client_task_log as hctl on hctl.visit_log_id = hcvl.visit_log_id
left join hc_client_outcomes as hco on hco.client_outcome_id = hctl.outcome_id
left join hc_outcomes as ho on ho.outcome_id = hco.outcome_id

where
hcvl.status = 1 and
hcvl.deleted_at is null

group by hcvl.visit_log_id
*/


/*
 select
 (select count(task_status) as no_of_tasks from hc_client_task_log
 where visit_log_id =  cvl.visit_log_id and task_status = 0
 and status=1 and deleted_at is null) as pending_no_of_task
 
 ,(select count(task_status) as no_of_tasks from hc_client_task_log
 where visit_log_id =  cvl.visit_log_id and task_status = 1
 and status=1 and deleted_at is null) as completed_no_of_task
 
 
 ,(select count(task_status) as no_of_tasks from hc_client_task_log
 where visit_log_id =  cvl.visit_log_id and task_status = 2
 and status=1 and deleted_at is null) as incompleted_no_of_task
 
 ,(select count(co.outcome_id) as outcome_total
 from hc_client_task_log as ctl
 left join hc_client_outcomes as co on co.client_outcome_id = ctl.client_outcome_id
 where ctl.status=1 and ctl.deleted_at is null
 and co.status = 1 and co.deleted_at is null
 and ctl.visit_log_id =  cvl.visit_log_id) as no_of_outcomes
 
 
 ,strftime('%H:%M',datetime(visit_start_time, '\(Helper.getTimezoneOffset())'))||" - "||
 ((strftime('%H:%M',datetime(visit_end_time, '\(Helper.getTimezoneOffset())')) - strftime('%H:%M',datetime(visit_start_time, '\(Helper.getTimezoneOffset())')))* 60)
 ||" minutes, "|| visit_title as care_plan_line_1
 ,strftime('%Y-%m-%d %H:%M:%S',datetime(visit_start_time,'\(Helper.getTimezoneOffset())')) as visit_start_time
 , (select client_prefix || " " || client_first_name || " " || client_last_name
 from hc_clients where client_id = cvl.client_id)|| " "|| (strftime('%H:%M',datetime(visit_start_time, '\(Helper.getTimezoneOffset())'))||" - "||strftime('%H:%M',datetime(visit_end_time,'\(Helper.getTimezoneOffset())'))) as care_plan_line_2
 ,visit_description
 ,cvl.visit_log_id
 from hc_client_visit_log as cvl
 where cvl.client_id != '\(SharedManager.sharedInstance.clientProfile?.client_id ?? "")' -- add client id condition
 and cvl.carer_id = '\(SharedManager.sharedInstance.userProfile.user_id ?? "")' -- add login carer id
 and cvl.status = 1
 and cvl.deleted_at is null
 and strftime('%Y-%m-%d %H:%M:%S',datetime(cvl.visit_start_time,'\(Helper.getTimezoneOffset())')) < '2017-11-13 01:00:00'  -- add condition to display past data
 order by cvl.visit_start_time desc
 */
