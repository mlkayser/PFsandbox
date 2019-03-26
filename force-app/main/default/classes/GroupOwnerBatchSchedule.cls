/**
 * Created by rdiaznasser on 4/3/18.
 */

global class GroupOwnerBatchSchedule implements Schedulable{

    global void execute (SchedulableContext SC){
        Database.executeBatch(new GroupOwnerBatch());
    }
}