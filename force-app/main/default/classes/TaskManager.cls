@RestResource(urlMapping='/Tasks/*')
global with sharing class TaskManager {
   
    @HttpPost
    global static void createTasks() {
        System.debug('createTask');
        RestRequest req = RestContext.request;  
		System.debug(req);        
        RestResponse res = RestContext.response;
       
        List<Task> taskList = (List<Task>)Json.deserialize(req.requestbody.tostring(),List<Task>.class); 
        PrintTaskClass.printTaskList(taskList);
       	
        try{
             res.statusCode = 201;
            /** FIC We need to use only our User */
            List<Task> taskListToUpdate = new List<Task>();
            for(Task t : taskList){
                t.OwnerId = UserInfo.getUserId();
                taskListToUpdate.add(t);
            }
           insert taskListToUpdate;
            for(Task t : taskListToUpdate){
                System.debug('t.id '+t.id);
            }
        } catch(DMLException e) {
            res.statusCode = 400;
            String resStr='ErrMsg |';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                System.debug(e.getDmlMessage(i)); 
                resStr+=e.getDmlMessage(i);
    		}
            resStr+='|';
            res.responseBody=Blob.valueOf(resStr);
        } catch(Exception e) {
            res.statusCode = 500;
            String resStr='ErrMsg |'+e.getMessage()+'|';
        } 
    }   
    @HttpDelete
    global static void deleteTasks() {
        System.debug('deleteTasks');
        RestRequest req = RestContext.request;  
		System.debug(req);        
        RestResponse res = RestContext.response;
        Set<String> deletedTaskProtoIds = (Set<String >)Json.deserialize(req.requestbody.tostring(),Set<String >.class);
        List<Task> taskToDelete = [SELECT Id,Proto_Index__c  from Task where Proto_Index__c In :deletedTaskProtoIds  ];
        try{
           res.statusCode = 204;
           delete  taskToDelete;
        } catch(DMLException e) {
            res.statusCode = 400;
            String resStr='ErrMsg |';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                System.debug(e.getDmlMessage(i)); 
                resStr+=e.getDmlMessage(i);
    		}
            resStr+='|';
            res.responseBody=Blob.valueOf(resStr);
        } catch(Exception e) {
            res.statusCode = 500;
            String resStr='ErrMsg |'+e.getMessage()+'|';
        } 
        
    }     
  
     @HttpPatch
    global static List<Task> updateTasks() {
   //  global static void updateTasks() {
   
        System.debug('updateTasks');
        RestRequest req = RestContext.request;  
		System.debug(req);        
        RestResponse res = RestContext.response;
         Map<String, Object> reqMap = new Map<String, Object>();
     try{      
        reqMap = (Map<String, Object>)JSON.deserializeUntyped(req.requestbody.tostring());
        System.debug(reqMap);
         
        List<Task> taskToUpdate = [SELECT Id,Proto_Index__c,Is_Synced__c from Task where Proto_Index__c In :reqMap.keySet()  ];
        Set<String> updatableFieldsName = new Set<String>();
		for(SObjectField field :sObjectType.Task.fields.getMap().values()){
    		if( field.getDescribe().isAccessible() && field.getDescribe().isUpdateable() && field.getDescribe().getName()!='Proto_Index__c' ){
                
        		updatableFieldsName.add(field.getDescribe().getName());
                    System.debug(field.getDescribe().getName());
    		}
		}
     
         for (Task tsk : taskToUpdate){
             tsk.Is_Synced__c = true;
            Map<String, Object> params =(Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(reqMap.get(tsk.Proto_Index__c))); 
            System.debug('params '+params);
            for(String fieldName : params.keySet()) {
                if(  updatableFieldsName.Contains(fieldName) ){
                    /** FIC we need to change  */
                    if(fieldName != 'OwnerId'){
                        if(fieldName == 'ActivityDate' ){
                            
                            String dateStr = (params.get(fieldName)).tostring() ;
                            System.debug('ActivityDate |'+params.get(fieldName)+'| dateStr |'+dateStr+'|');
                            tsk.put(fieldName, Date.valueOf(dateStr));
                            System.debug('after put');
                        }else{
                            tsk.put(fieldName, params.get(fieldName));
                        }   
                    } 
                }         	    
        	}
        }
      
             res.statusCode = 202;
             update taskToUpdate; 
             return taskToUpdate;
        } catch(DMLException e) {
            res.statusCode = 400;
            String resStr='@HttpPatch [updateTasks] ErrMsg |';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                System.debug(e.getDmlMessage(i)); 
                resStr+=e.getDmlMessage(i);
    		}
            resStr+='|';
            res.responseBody=Blob.valueOf(resStr);
          
            List<Task> notSynchrTasks = [SELECT Id,Is_Synced__c,Proto_Index__c from Task where Proto_Index__c In :reqMap.keySet()  ];
            for (Task tsk : notSynchrTasks){
                 tsk.Is_Synced__c = false;
            }
            update notSynchrTasks;
			return notSynchrTasks;
        } catch(Exception e) {
            res.statusCode = 500;
            String resStr='@HttpPatch [updateTasks] ErrMsg |'+e.getMessage()+'|';
            res.responseBody=Blob.valueOf(resStr);
         
            List<Task> notSynchrTasks = [SELECT Id,Is_Synced__c,Proto_Index__c from Task where Proto_Index__c In :reqMap.keySet()  ];
            for (Task tsk : notSynchrTasks){
                 tsk.Is_Synced__c = false;
            }
            update notSynchrTasks;
            return notSynchrTasks;
        }
    }    
}