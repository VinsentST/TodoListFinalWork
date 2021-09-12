public class QuebleSynchronizatorAfterUpdate implements Queueable,Database.AllowsCallouts  {
	String jsonString=''; 
    
    TaskHandler.OBJECT_TYPE objectType = TaskHandler.OBJECT_TYPE.NOT_DEFINED;
    public QuebleSynchronizatorAfterUpdate(String jsonString,TaskHandler.OBJECT_TYPE objectType){
  //  public QuebleSynchronizatorAfterUpdate(String jsonString){
        this.jsonString = jsonString;
        this.objectType = objectType;
    }
    public void execute(QueueableContext context) {
       Http http = new Http();
       HttpRequest request = new HttpRequest();
       
       System.debug('Synch after update');
       request.setMethod('PATCH');
       request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
       if(this.objectType == TaskHandler.OBJECT_TYPE.TASK ){
           request.setEndpoint('callout:CustomerRubyAPI//services/apexrest/Tasks/');
           Set<Task> taskSet = (Set<Task>)Json.deserialize( this.jsonString,Set<Task>.class);
           
           Map<String,Task> mapTaskList = new Map<String,Task>(); 
           for(Task t: taskSet ){
               if(t.Is_Synced__c  = true){
                   mapTaskList.put(t.Proto_Index__c,t); 
               }        
           }
           request.setBody(JSON.serialize(mapTaskList));
           HttpResponse response = http.send(request);
           System.debug('response.getStatusCode() '+response.getStatusCode());
           if( response.getStatusCode() == 202 ){
               System.debug('Ok');
               
           }else{
               System.debug('Set IsSycned false');
               for(Task t: taskSet ){
                   t.Is_Synced__c = false;
               }
               update new List<Task>(taskSet);
               System.debug('Error: Can\'t Synchronized.Error code is |'+response.getStatusCode()+'|.Error message is |'+ String.valueOf(response.getBody())+'|' );
           }
       }    
        
    }
}