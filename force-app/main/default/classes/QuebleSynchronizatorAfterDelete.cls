public class QuebleSynchronizatorAfterDelete implements Queueable,Database.AllowsCallouts  {
	String jsonString=''; 
    public QuebleSynchronizatorAfterDelete(String jsonString){
        this.jsonString = jsonString;
    }
    public void execute(QueueableContext context){
        System.debug('Synch after insert');
       Http http = new Http();
       HttpRequest request = new HttpRequest();
       request.setEndpoint('callout:CustomerRubyAPI//services/apexrest/Tasks/');
      
       request.setMethod('DELETE');
       request.setHeader('Content-Type', 'application/json;charset=UTF-8');
       List<Task> taskList = (List<Task>)Json.deserialize( this.jsonString,List<Task>.class);
        Set<String > deletedTaskProtoIds = new Set<String >();
        for(Task t : taskList){
            if(t.Is_Synced__c  = true){
                deletedTaskProtoIds.add(t.Proto_Index__c);
            }
       }
       System.debug('deletedTaskProtoIds '+deletedTaskProtoIds);
       request.setBody(JSON.serialize(deletedTaskProtoIds));
       HttpResponse response = http.send(request);
       System.debug('AfterDelete response.getStatusCode() '+response.getStatusCode());
       if( response.getStatusCode() == 204 ){
           //Succesfull delete fron   another org
       }else{
           System.debug('Error: Can\'t Synchronize delete operation.Error code is |'+response.getStatusCode()+'|.Error message is |'+ String.valueOf(response.getBody())+'|' );
       } 
    }
    
}