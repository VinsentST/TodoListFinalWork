@IsTest
public class TaskManagerTest {
    String  Proto_Index='proto_index_test';
	@TestSetup
    static void makeData() {
        // Inserting a new contact
        Task testTask = new Task(Subject='Richard');
        insert testTask;
    }

}