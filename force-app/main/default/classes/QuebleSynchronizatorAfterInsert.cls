public class QuebleSynchronizatorAfterInsert implements Queueable,Database.AllowsCallouts  {
 
    
    TaskHandler.OBJECT_TYPE objectType = TaskHandler.OBJECT_TYPE.NOT_DEFINED;
    String jsonString;
   
   public QuebleSynchronizatorAfterInsert(String jsonString,TaskHandler.OBJECT_TYPE objectType){
       
        this.jsonString = jsonString;
        this.objectType = objectType;
    }
    
   public void execute(QueueableContext context) {
       Http http = new Http();
       HttpRequest request = new HttpRequest();
      
       System.debug('Synch after insert');
       request.setMethod('POST');
       request.setHeader('Content-Type', 'application/json;charset=UTF-8');
       
      if(this.objectType == TaskHandler.OBJECT_TYPE.TASK ){
           request.setEndpoint('callout:CustomerRubyAPI//services/apexrest/Tasks/');
           List<Task> taskList = (List<Task>)Json.deserialize( this.jsonString,List<Task>.class);
           List<Task> taskListUpdate = new List<Task>();
           List<Task> taskListSend = new List<Task>();
           for(Task t: taskList){
               Task sendTask = (Task)JSON.deserialize(JSON.serialize(t), Task.class);
               Task updateTask = (Task)JSON.deserialize(JSON.serialize(t), Task.class);
               sendTask.id = null;
               sendTask.Proto_Index__c = String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'))+t.id;
               sendTask.Is_Synced__c = true;
               taskListSend.add(sendTask);
               
               updateTask.Proto_Index__c = sendTask.Proto_Index__c;
               updateTask.Is_Synced__c = sendTask.Is_Synced__c;
               taskListUpdate.add(updateTask);
           }
           request.setBody(JSON.serialize(taskListSend));
           HttpResponse response = http.send(request);
           System.debug('response.getStatusCode() '+response.getStatusCode());
           if( response.getStatusCode() == 201 ){
               //Succesfull insert in another org
               update taskListUpdate;
           }else{
               System.debug('Error: Can\'t Synchronized.Error code is |'+response.getStatusCode()+'|.Error message is |'+ String.valueOf(response.getBody())+'|' );
           }
        }       
    }
}