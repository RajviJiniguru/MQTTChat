//
//  QueryIntegration.swift
//  thecareportal
//
//  \d by Jayesh on 10/11/17.
//  Copyright © 2017 Jiniguru. All rights reserved.
//

import UIKit
import FMDB
import CoreLocation
// MARK:- Data Retrive Methods
extension DBManager{
    
    // MARK:- Get Client List of Login Carel
    class func getClientList() -> [ClientInformationModal]?{
        if DBManager.sharedInstance().openMasterDatabase(){
            let query = "select client_id,chatengine_room_id,(client_first_name ||' '|| client_last_name) as name,client_profile_picture from hc_clients where client_id in (select client_id from hc_client_visit_log where carer_id = '\(SharedManager.sharedInstance.userProfile.user_id ?? "")') order by created_at"
            do {
                let results = try _sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                var clientInfoarr : [ClientInformationModal] = []
                while results.next() {
                    let clientInfoobj = ClientInformationModal(resultset: results)
                    clientInfoarr.append(clientInfoobj)
                }
                return clientInfoarr
            }
            catch {
                print(error.localizedDescription)
            }
            _sharedInstance.masterDatabase?.close()
        }
        return nil
    }
    
    // MARK:- Get Visit Logs With CarePlan Visit Tab
    class func getVisitWithTaskDetail(visitid : String?,flgByID : Bool) -> [ClientVisitLogModal]?{
        if DBManager.sharedInstance().openMasterDatabase(){
            
            let query = """
            select hcvl.visit_log_id,hcvl.client_id
            ,strftime('%Y-%m-%d',datetime(visit_start_time, '\(Helper.getTimezoneOffset())')) as display_date
            ,strftime('%Y-%m-%d %H:%M',datetime(hcvl.visit_start_time, '\(Helper.getTimezoneOffset())')) as display_start_time
            ,strftime('%Y-%m-%d %H:%M',datetime(hcvl.visit_end_time, '\(Helper.getTimezoneOffset())')) as display_end_time
            ,hcvl.visit_title,hcvl.visit_description
            ,(select
            ('[' ||
            GROUP_CONCAT(
            ('{"outcome_id":"' || tbl.outcome_id || '", "outcome_title":"' || tbl.outcome_title || '", "total_outcomes":"' || tbl.total_outcomes || '"}' )
            ) || ']') json_column
            
            from
            (
            select
            sub_ho.outcome_id
            ,sub_ho.outcome_title
            ,count(sub_ho.outcome_id) as total_outcomes
            from hc_client_visit_log as sub_hcvl
            left join hc_client_task_log as sub_hctl on sub_hctl.visit_log_id = sub_hcvl.visit_log_id
            left join hc_client_outcomes as sub_hco on sub_hco.client_outcome_id = sub_hctl.client_outcome_id
            left join hc_outcomes as sub_ho on sub_ho.outcome_id = sub_hco.outcome_id
            
            where
            sub_hcvl.status = 1 and
            sub_hcvl.deleted_at is null and
            sub_hcvl.visit_log_id = hcvl.visit_log_id
            group by sub_hcvl.visit_log_id, sub_ho.outcome_id) as tbl) as json_column
            
            
            from hc_client_visit_log as hcvl
            left join hc_client_task_log as hctl on hctl.visit_log_id = hcvl.visit_log_id
            left join hc_client_outcomes as hco on hco.client_outcome_id = hctl.client_outcome_id
            left join hc_outcomes as ho on ho.outcome_id = hco.outcome_id
            where
            \(flgByID ? "hcvl.client_id = '\(SharedManager.sharedInstance.clientProfile?.client_id ?? "")' and" : "")
            hcvl.status = 1 and
            hcvl.deleted_at is null
            \(visitid != nil ? "and hcvl.visit_log_id = '\(visitid ?? "")'" : "")
            group by hcvl.visit_log_id order by hcvl.visit_start_time
            """
            do {
                let results = try _sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                var temparr : [ClientVisitLogModal] = []
                while results.next() {
                    temparr.append(ClientVisitLogModal(resultset: results))
                }
                return temparr
            }
            catch {
                print(error.localizedDescription)
            }
            _sharedInstance.masterDatabase?.close()
            return nil
        }
        return nil
    }
    
    // MARK:- Get Visit Logs
    class func getVisitLogs(startDate : String,endDate : String) -> [ClientVisitLogModal]?{
        if DBManager.sharedInstance().openMasterDatabase(){
            
            let query =  """
            select hc_client_visit_log.client_id ,
            strftime('%Y-%m-%d',datetime(visit_start_time, '\(Helper.getTimezoneOffset())')) as display_date,
            strftime('%H:%M',datetime(visit_start_time, '\(Helper.getTimezoneOffset())')) as display_start_time,
            strftime('%H:%M',datetime(visit_end_time, '\(Helper.getTimezoneOffset())')) as display_end_time,
            (client_prefix ||' '|| client_first_name ||' '|| client_last_name) as name,
            visit_log_id,visit_title, visit_description from hc_client_visit_log, hc_clients
            where hc_client_visit_log.carer_id = '\(SharedManager.sharedInstance.userProfile.user_id ?? "")' and
            hc_client_visit_log.client_id = hc_clients.client_id and
            strftime('%Y-%m-%d',datetime(visit_start_time,'\(Helper.getTimezoneOffset())')) >= date('\(startDate)') and
            strftime('%Y-%m-%d',datetime(visit_start_time,'\(Helper.getTimezoneOffset())')) <= date('\(endDate)')
            and hc_client_visit_log.status= 1 and hc_client_visit_log.deleted_at is null order by visit_start_time
            """
            
            do {
                let results = try _sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                var arrVisitLog : [ClientVisitLogModal] = []
                while results.next() {
                    let obj = ClientVisitLogModal(resultset: results)
                    arrVisitLog.append(obj)
                }
                return arrVisitLog
            }
            catch {
                print(error.localizedDescription)
            }
            _sharedInstance.masterDatabase?.close()
        }
        return nil
    }
    
    // MARK:- Get CarePlan Outcomes
    class func getCareplanOutcomes() -> [OutComeDetailModal]?{
        if DBManager.sharedInstance().openMasterDatabase(){
            let query =
            """
            select hc_outcomes.outcome_id, outcome_title,
            (case when client_outcome_description = ''
            then outcome_description
            else client_outcome_description
            end) as outcome_description
            from hc_outcomes,hc_client_outcomes
            where hc_client_outcomes.client_id = '\(SharedManager.sharedInstance.clientProfile?.client_id ?? "")'
            and hc_outcomes.outcome_id = hc_client_outcomes.outcome_id
            and hc_client_outcomes.status = 1
            and hc_client_outcomes.deleted_at is null
            and hc_outcomes.status = 1
            and hc_outcomes.deleted_at is null
            """
            do {
                let results = try _sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                var arrTemp : [OutComeDetailModal] = []
                while results.next() {
                    let obj = OutComeDetailModal(resultset: results)
                    arrTemp.append(obj)
                }
                return arrTemp
            }
            catch {
                print(error.localizedDescription)
            }
            _sharedInstance.masterDatabase?.close()
        }
        return nil
    }
    
    // MARK:- Get Visit Task
    class func getVisitTasks(visitId : String,_ Outcomeid : String?) -> [TaskInformationModal]?{
        if DBManager.sharedInstance().openMasterDatabase(){
            //\(Outcomeid != nil ? "'\(Outcomeid ?? "")'" : "hc_outcomes.outcome_id")
            
            let query =
            """
            select task_log_id,task_status,task_title, task_type,task_medicine_has_confirmed_note,task_medicine_notes,task_notes,task_description,task_personal_info, hc_outcomes.outcome_id,outcome_title,policy_id,
            case when  client_outcome_description = "" then outcome_description
            else client_outcome_description
            end as description
            from hc_client_task_log, hc_client_outcomes,hc_outcomes
            where visit_log_id = "\(visitId)"
            and hc_client_task_log.client_outcome_id = hc_client_outcomes.client_outcome_id and
            hc_client_outcomes.outcome_id = hc_outcomes.outcome_id
            \(Outcomeid != nil ? "and hc_client_outcomes.outcome_id = '\(Outcomeid ?? "")'" : "")
            order by hc_outcomes.outcome_id, hc_client_task_log.created_at, hc_client_task_log.task_log_id
            """
            
            do {
                let results = try _sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                var arrReturn : [TaskInformationModal] = []
                while results.next() {
//                    var arrayTaskInfoModal = [TaskInformationModal]()
                    let obj = TaskInformationModal(resultset: results)
                    
                    arrReturn.append(obj)
                }
                return arrReturn
            }
            catch {
                print(error.localizedDescription)
            }
            _sharedInstance.masterDatabase?.close()
            return nil
        }
        return nil
    }
    
    
    // MARK:- Get Client Information
    class func getClientInfo(clientID : String?) -> FMResultSet?  {
        if DBManager.sharedInstance().openMasterDatabase(){
            let query =
            """
            select
            (client_first_name ||' '|| client_last_name) as name,
            client_profile_picture from hc_clients where client_id = "\(clientID ?? "")"
            """
            do {
                let results = try _sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                while results.next() {
                    return results
                }
            }
            catch {
                print(error.localizedDescription)
            }
            return nil
            _sharedInstance.masterDatabase?.close()
        }
        return nil
    }
    
    // MARK:- Get Client Details
    class func getClientDetails(clientID : String?) -> FMResultSet?  {
        if DBManager.sharedInstance().openMasterDatabase(){
            let query =
            """
            select
            client_address,client_profile_picture,
            (client_first_name ||' '|| client_last_name) as name,client_landline,
            client_mobile_no,client_doctor_name,client_surgery,client_doctor_phone,client_next_to_kin,client_next_to_kin_phone
            from hc_clients where client_id = "\(clientID ?? "")"
            """
            do {
                let results = try _sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                
                while results.next() {
                    return results
                }
            }
            catch {
                print(error.localizedDescription)
            }
            return nil
            _sharedInstance.masterDatabase?.close()
        }
        return nil
    }
    
    // MARK:- Get FAQ
    class func getFaq() -> [FAQsModal]?{
        if DBManager.sharedInstance().openMasterDatabase(){
            let query =
            """
            select faq_title,faq_Description
             from hc_company_faq order by display_order
            """
            do {
                let results = try _sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                var temparr : [FAQsModal] = []
                while results.next() {
                    temparr.append(FAQsModal(resultset: results))
                }
                return temparr
            }
            catch {
                print(error.localizedDescription)
            }
            return nil
            _sharedInstance.masterDatabase?.close()
        }
        return nil
    }
    
    // MARK:- Get Care Note
    class func getCareNotes() -> [CareNoteModal]?{
        if DBManager.sharedInstance().openMasterDatabase(){
            
        let query =
            """
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
            (
            Cast (JulianDay(visit_end_time) * 24 * 60 As Integer) -  Cast (JulianDay(visit_start_time) * 24 * 60 As Integer)
            )
            
            ||" minutes, "|| visit_title as care_plan_line_1
            ,strftime('%Y-%m-%d %H:%M:%S',datetime(visit_start_time, '\(Helper.getTimezoneOffset())')) as visit_start_time
            , (select full_name from hc_user_profile where hc_user_profile.user_id = cvl.carer_id)|| " "||
            (
            StrFTime('%H', datetime(visit_start_time, '\(Helper.getTimezoneOffset())'))
            || ':' ||
            StrFTime('%M', datetime(visit_start_time, '\(Helper.getTimezoneOffset())'))
            ||" - "||
            StrFTime('%H', datetime(visit_end_time, '\(Helper.getTimezoneOffset())'))
            || ':' ||
            StrFTime('%M', datetime(visit_end_time, '\(Helper.getTimezoneOffset())'))
            ) as care_plan_line_2
            ,visit_description
            ,cvl.visit_log_id
            from hc_client_visit_log as cvl
            where cvl.client_id = '\(SharedManager.sharedInstance.clientProfile?.client_id ?? "")' -- add client id condition
            and cvl.status = 1
            and cvl.deleted_at is null
            and strftime('%Y-%m-%d %H:%M:%S',datetime(cvl.visit_start_time, '\(Helper.getTimezoneOffset())')) < '\(Date().getStringInformat(convDateFormatter: "yyyy-MM-dd HH:mm:ss"))'  -- add condition to display past data
            order by cvl.visit_start_time desc
        """
           
            do {
                
                let results = try _sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                var arrTemp : [CareNoteModal] = []
                while results.next() {
                    arrTemp.append(CareNoteModal(resultset: results))
                }
                return arrTemp
            }
            catch {
                print(error.localizedDescription)
            }
            
            return nil
            
        }
        return nil
    }
    
    // MARK :- Confirm Medicine Note
    class func confirmmedicineNote(tasklogid : String) -> Bool{
        if DBManager.sharedInstance().openMasterDatabase(){
            //\(Outcomeid != nil ? "'\(Outcomeid ?? "")'" : "hc_outcomes.outcome_id")
            let query =
            """
            update hc_client_task_log set task_medicine_has_confirmed_note = '1',is_export = 0 where task_log_id = '\(tasklogid)'
            """
            let result = _sharedInstance.masterDatabase! .executeUpdate(query, withArgumentsIn: [tasklogid])
            _sharedInstance.masterDatabase?.close()
             return result
        }
        return false
    }
    
    // MARK :- Add  Note
    class func addNote(notes : String,tasklogid : String) -> Bool{
        if DBManager.sharedInstance().openMasterDatabase(){
            //\(Outcomeid != nil ? "'\(Outcomeid ?? "")'" : "hc_outcomes.outcome_id")
            let query =
            """
            update hc_client_task_log set task_notes = ?, is_export = 0 where task_log_id = ?
            """
            let result = _sharedInstance.masterDatabase!.executeUpdate(query, withArgumentsIn: [notes,tasklogid])
            _sharedInstance.masterDatabase?.close()
            return result
        }
        return false
    }
    
    // MARK :- Update Task Status
    class func updateTaskstatus(status : String,tasklogid : String) -> Bool{
        if DBManager.sharedInstance().openMasterDatabase(){
            //\(Outcomeid != nil ? "'\(Outcomeid ?? "")'" : "hc_outcomes.outcome_id")
            let query =
            """
            update hc_client_task_log set task_status = '\(status)', is_export = 0 where task_log_id = '\(tasklogid)'
            """
            let result = _sharedInstance.masterDatabase!.executeUpdate(query, withArgumentsIn: [status,tasklogid])
            _sharedInstance.masterDatabase?.close()
            return result
        }
        return false
    }
    
    // MARK :- Retrive Client Summary
    class func getClientSummary() -> String?{
        if DBManager.sharedInstance().openMasterDatabase(){
            //\(Outcomeid != nil ? "'\(Outcomeid ?? "")'" : "hc_outcomes.outcome_id")
            let query =
            """
            select client_summary
            from hc_clients where client_id = '\(SharedManager.sharedInstance.clientProfile?.client_id ?? "")'
            """
            do {
                let results = try _sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                while results.next() {
                    return results.string(forColumn: "client_summary")
                }
            }
            catch {
                print(error.localizedDescription)
            }
            return nil
            _sharedInstance.masterDatabase?.close()
        }
        return nil
        
    }
    
    // MARK :- Add Task On Database()
    class func AddTaskOnDatabase(query : String) -> Bool{
        if DBManager.sharedInstance().openMasterDatabase(){
            //\(Outcomeid != nil ? "'\(Outcomeid ?? "")'" : "hc_outcomes.outcome_id")
            let result = _sharedInstance.masterDatabase!.executeStatements(query)
            _sharedInstance.masterDatabase?.close()
            return result
        }
        return false

    }
    
    // MARK:- Retrive client Outcome Id
    class func getClientOutcomeId(outcomeId : String) -> String?{
        if DBManager.sharedInstance().openMasterDatabase(){
            let query =
            """
            select client_outcome_id
             from hc_client_outcomes where outcome_id = '\(outcomeId)' and client_id = '\(SharedManager.sharedInstance.clientProfile?.client_id ?? "")'
            """
            do {
                let results = try _sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                while results.next() {
                    return results.string(forColumn: "client_outcome_id")
                }
            }
            catch {
                print(error.localizedDescription)
            }
            return nil
            _sharedInstance.masterDatabase?.close()
        }
        return nil
    }
    
    // MARK:- OutCome List BasedOn Visit Log ID
    class func getTaskListBasedOnvisitLogID(visitLogId : String) -> [TaskInformationModal]?{
        
//        select task_log_id,task_title, task_type, task_medicine_notes, task_description, task_status, task_medicine_has_confirmed_note,
//        task_notes, hc_outcomes.outcome_id, outcome_title,
//        (case when client_outcome_description = ''
//        then outcome_description
//        else client_outcome_description
//        end) as description
//        from hc_client_task_log, hc_client_outcomes , hc_outcomes
//        where visit_log_id = '\(visitLogId)'
//        and hc_client_task_log.client_outcome_id = hc_client_outcomes.client_outcome_id and
//        hc_client_outcomes.outcome_id = hc_outcomes.outcome_id
        
        if DBManager.sharedInstance().openMasterDatabase(){
            
            let query =
            """
            select task_log_id,task_title, task_type, task_medicine_notes, task_description, task_status, task_medicine_has_confirmed_note,task_notes, hc_outcomes.outcome_id, outcome_title, policy_id, task_personal_info, 'false' as isSelected,
            (case when client_outcome_description != '' AND client_outcome_description != null
            then client_outcome_description
            else case when outcome_description != '' AND outcome_description != null then outcome_description else '' end
            end) as description
            from hc_client_task_log, hc_client_outcomes , hc_outcomes
            where visit_log_id = '\(visitLogId)'
            and hc_client_task_log.client_outcome_id = hc_client_outcomes.client_outcome_id and
            hc_client_outcomes.outcome_id = hc_outcomes.outcome_id
            """
            
            do {
                
                let results = try _sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                var arrReturn : [TaskInformationModal] = []
                while results.next() {
                    let obj = TaskInformationModal(resultset: results)
                    arrReturn.append(obj)
                }
                return arrReturn
            }
            catch {
                print(error.localizedDescription)
            }
            _sharedInstance.masterDatabase?.close()
        }
        return nil
    }
    
    // MARK:- Vist Log List BasedOn Visit Log ID
    class func getOutcomeListBasedOnvisitLogID(visitLogId : String) -> [OutComeDetailModal]?{
        if DBManager.sharedInstance().openMasterDatabase(){
            
//            select client_outcome_id, outcome_title,(case when client_outcome_description != '' OR client_outcome_description != null
//            then client_outcome_description
//            else case when outcome_description != '' OR outcome_description != null then outcome_description else '' end
//            end) as description
//            from hc_outcomes, hc_client_outcomes
//            where client_outcome_id in
//            (select client_outcome_id from hc_client_task_log where visit_log_id = 'de402c2f-5b71-581f-2874-5af58cab3491')
//            and hc_outcomes.outcome_id = hc_client_outcomes.outcome_id
//            group by hc_outcomes.outcome_id
            
            let query =
            """
            select client_outcome_id, outcome_title,(case when client_outcome_description != '' OR client_outcome_description != null
            then client_outcome_description
            else case when outcome_description != '' OR outcome_description != null then outcome_description else '' end
            end) as outcome_description
            from hc_outcomes, hc_client_outcomes
            where client_outcome_id in
            (select client_outcome_id from hc_client_task_log where visit_log_id = '\(visitLogId)')
            and hc_outcomes.outcome_id = hc_client_outcomes.outcome_id
            group by hc_outcomes.outcome_id
            """
            
            do {
                
                let results = try _sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                var arrTemp : [OutComeDetailModal] = []
                while results.next() {
                    let obj = OutComeDetailModal(resultset: results)
                    arrTemp.append(obj)
                }
                return arrTemp
            }
            catch {
                print(error.localizedDescription)
            }
            _sharedInstance.masterDatabase?.close()
        }
        return nil
    }
    
    // MARK:- ADD Emergancy request on db
    class func addRecordOnDatabase(query : String) -> Bool{
        if DBManager.sharedInstance().openMasterDatabase(){
            let result = _sharedInstance.masterDatabase!.executeStatements(query)
            _sharedInstance.masterDatabase?.close()
            return result
        }
        return false
    }
    
    class func getPrivacy(policy_id : String ) -> FMResultSet?{
        if DBManager.sharedInstance().openMasterDatabase(){
            let query =
            """
            select title,description from hc_privacy_policy_master where policy_id = '\(policy_id)'
            """
            do {
                
                let result = try _sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                while result.next() {
                    return result
                }
                
            }
            catch {
                print(error.localizedDescription)
            }
            _sharedInstance.masterDatabase?.close()
        }
        return nil
    }
    
    class func createTableForLocationEntry(){
        if DBManager.sharedInstance().openMasterDatabase(){
            let query =
            """
            CREATE TABLE IF NOT EXISTS hc_user_location(
            user_location_id TEXT  NOT NULL PRIMARY KEY,
            user_id TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            entry_date TEXT NOT NULL,
            status INTEGER NOT NULL DEFAULT '1',
            created_at TEXT NULL,
            updated_at TEXT NULL,
            deleted_at TEXT NULL,
            is_export INTEGER NOT NULL DEFAULT '0')
            """
            let result =  _sharedInstance.masterDatabase!.executeStatements(query)
            print(result)
            _sharedInstance.masterDatabase?.close()
        }
    }
    
    class func insertDataIntoLocationTable(location : CLLocationCoordinate2D){
        
        /* This method will let you know that location change has occured so we need to sync with server as well. So we have called user_location API here with required params. Once you get the response from server then need to insert location data into hc_user_location table with isExport = 1. */
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let currentDate  = formatter.string(from: date)
        
        let params = [
            WSRequestParams.device_id : CurrentDevice.iPhoneDeviceId ?? "",
            WSRequestParams.push_registration_id : CurrentDevice.iPhoneDeviceId ?? "",
            WSRequestParams.app_version : CurrentDevice.CurrentAppVersion ?? "1.0",
            WSRequestParams.device_type : CurrentDevice.CurrentDeviceType,
            WSRequestParams.os_version :  CurrentDevice.iPhoneOsVersion,
            WSRequestParams.request_date : currentDate,
            WSRequestParams.entry_date : currentDate,
            WSRequestParams.latitude : location.latitude,
            WSRequestParams.longitude : location.longitude,
            WSRequestParams.user_id : SharedManager.sharedInstance.userProfile.user_id ?? ""
            ] as [String : Any]
        
        WSManager.wscallAlamoRequest(url: WebService.userLocation, method: .post , param: params, headers: WSManager.getHeaders(headersType: .Authorization), successComplitionBlock: { (responseObject) in
            
            if let newToken = responseObject[WSResponseParams.newToken] as? String{
                    Helper.setPREF(newToken, key: UserDefaultsConstant.PREF_SECRET_TOKEN)
                    self.insertDataIntoLocationTable(location: location)
            }else{
                    self.updateUserLocationInDBWhenWebserviceCallIsFinished(location: location, isExport: "1")
            }
            
        }) { (error) in
            self.updateUserLocationInDBWhenWebserviceCallIsFinished(location: location, isExport: "0")
        }
    }
    
    static func updateUserLocationInDBWhenWebserviceCallIsFinished(location : CLLocationCoordinate2D , isExport : String){
        
        /* This method is responsible to insert location data in table when location changes are reflected on server */
        
        if DBManager.sharedInstance().openMasterDatabase(){
            let query =
            """
            INSERT INTO `hc_user_location`(`user_location_id`,`user_id`,`latitude`,`longitude`,`entry_date`,`created_at`,`updated_at`,`deleted_at`,`is_export`) VALUES ("\(UUID().uuidString)","\(SharedManager.sharedInstance.userProfile.user_id ?? "")",\(location.latitude),\(location.longitude),"\(Date().preciseUTCTime)","\(Date().preciseUTCTime)",NULL,NULL,\(isExport));
            """
            let result = _sharedInstance.masterDatabase!.executeStatements(query)
            print(result)
            _sharedInstance.masterDatabase?.close()
        }
    }
    
    // MARK: Emergency Contact Detail Retrival method
    
    func getEmergencyContactDetailsForSelctedClient()-> [EmergencyContact]?{
        
        if DBManager.sharedInstance().openSlaveDatabase(){
            
            let query = "SELECT emergency_contacts from hc_clients where client_id = '\(SharedManager.sharedInstance.clientProfile?.client_id ?? "")'"
            
            do {
                
                let results = try DBManager._sharedInstance.masterDatabase!.executeQuery(query, values: nil)
                
                while results.next() {
                    return prepareEmergencyObject(resultSet: results)
                }
            }
            catch {
                print(error.localizedDescription)
            }
            
            DBManager._sharedInstance.masterDatabase?.close()
        }
        
        return nil
    }
    
    func prepareEmergencyObject(resultSet : FMResultSet) -> [EmergencyContact]?{
        
        if let jsonObject = resultSet.object(forColumn: "emergency_contacts") as? String{

            let data = jsonObject.data(using: .utf8)
            
            var emergencyContact : [EmergencyContact] = []

            do{
                let jsonObj = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)

                if let abyObjectArray = jsonObj as? [AnyObject]{

                    for obj in abyObjectArray{

                        if(obj is [String:Any]){
                            
                            let emergencyObject = EmergencyContact(resultSet: obj as? [String : Any])
                            emergencyContact.append(emergencyObject)
                        }
                    }
                }
            }
            catch{

            }
            
            return emergencyContact
        }
        
        return nil
    }
    
}
