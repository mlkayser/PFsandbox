public class FRM3_TasksController {

    @auraEnabled
    public static List<Task> getTasks() {

		ID userId = UserInfo.getUserId();
        List<Task> myTasks = new List<Task>();

        myTasks = [
        	SELECT Id, Subject, Status, ActivityDate, Owner.Name 
        	FROM Task 
        	WHERE OwnerId = :userId
            ORDER BY ActivityDate
        ];

        System.debug('***DEBUG tasks list size = ' + myTasks.size());
		return myTasks;
    }

}