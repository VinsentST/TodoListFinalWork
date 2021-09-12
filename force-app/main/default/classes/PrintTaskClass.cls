public class PrintTaskClass {
    public static void printTaskList(List<Task> taskList){
        for(Task t : taskList){
            System.debug('+t.id '+t.id+' t.Subject |'+t.Subject+'| t.Proto_Index__c' +t.Proto_Index__c+'|');
        }
    }
}