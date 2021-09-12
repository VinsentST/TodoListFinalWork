public class QueuebleSinchronizatorClass implements Queueable,Database.AllowsCallouts  {
   
   String before='';
   String after=''; 
    public QueuebleSinchronizatorClass(String before, String after){
        this.before = before;
        this.after = after;
    }
    
   public void execute(QueueableContext context) {
       Http http = new Http();
       HttpRequest request = new HttpRequest();
       request.setEndpoint('callout:CustomerRubyAPI//services/apexrest/Tasks/');
       
       
       if(this.before == '' && this.after != '' ){
           System.debug('Synch after insert');
           request.setMethod('POST');
       	   request.setHeader('Content-Type', 'application/json;charset=UTF-8');
           List<Task> taskList = (List<Task>)Json.deserialize( this.after,List<Task>.class);
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