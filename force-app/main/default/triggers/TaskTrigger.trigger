trigger TaskTrigger on Task (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
  
     /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
       
    }
    /* After Insert */
    else if(Trigger.isInsert && Trigger.isAfter){
        System.debug(' Trigger After Insert');
        
         ID jobID = System.enqueueJob(new QuebleSynchronizatorAfterInsert(JSON.serialize(Trigger.new),TaskHandler.OBJECT_TYPE.TASK));
    //     TaskHandler.handleOnAfterInsert(JSON.serialize(Trigger.new));
         
    }
    /* Before Update */
    else if(Trigger.isUpdate && Trigger.isBefore){
        
    }
    /* After Update */
    else if(Trigger.isUpdate && Trigger.isAfter){
        System.debug(' Trigger After Update');
       
          Map<Id,Task> taskToUpdate = new Map<Id,Task>();
     {
        
        Task gplObject = new Task(); // This takes all available fields from the required object. 
        Schema.SObjectType objType = gplObject.getSObjectType(); 
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Task.fields.getMap(); 
        
        for(Task gpl : trigger.new)
        {
           Task oldGPL = trigger.oldMap.get(gpl.Id);
           for(SObjectField field :sObjectType.Task.fields.getMap().values()){
               if(gpl.get(field) != oldGPL.get(field)){
                   System.Debug('IGORU Field changed: ' + field.getDescribe().getName() + '. The value has changed from: ' + oldGPL.get(field) + ' to: ' + gpl.get(field));
               
                   if (!( field  == Task.Is_Synced__c || field == Task.LastModifiedDate || field == Task.SystemModStamp || field == Task.Proto_Index__c )){
                       System.debug('Add to update ');
                        taskToUpdate.put(gpl.Id,gpl);
                   }else{
                       System.debug('Don\'t  update ');
                   }
               }     
            }
        }
         
    }
        
        
     if(taskToUpdate.size()>0){
         System.debug(' Trigger After Update call QuebleSynchronizatorAfterUpdate');
         
         ID jobID = System.enqueueJob(new QuebleSynchronizatorAfterUpdate(JSON.serialize(taskToUpdate.values()),TaskHandler.OBJECT_TYPE.TASK));
         
     }   
     
     
     
    }
    /* Before Delete */
    else if(Trigger.isDelete && Trigger.isBefore){
     
    }
    /* After Delete */
    else if(Trigger.isDelete && Trigger.isAfter){
        System.debug('After Delete ');
        ID jobID = System.enqueueJob(new QuebleSynchronizatorAfterDelete(JSON.serialize(Trigger.old)));
      
    }

    /* After Undelete */
    else if(Trigger.isUnDelete){
     //   handler.OnUndelete(Trigger.new);
    }

   
}