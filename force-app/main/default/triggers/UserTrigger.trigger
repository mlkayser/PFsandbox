/*
    @uthor: azhar.aziz@magnet360.com
    Created Date: 07 / 06 / 2015
    Description: Jira ( PFCC-2493 )
    @Update: 9/23/15 PFCC-3026 Andres Di Geronimo-Stenberg
    @Comment: Added Before Insert  Logic
*/
trigger UserTrigger on User ( before insert, 
                              before update, 
                              after insert, 
                              after update
                            ) 
{

    if( trigger.isBefore && trigger.isInsert )
    {
        UserTriggerHandler.setClubAccess( Trigger.new );
    }
    else if( trigger.isBefore && trigger.isUpdate )
    {
        UserTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
    else if( trigger.isAfter && trigger.isInsert )
    {
        UserTriggerHandler.afterInsert( Trigger.new );
    }
    else if( trigger.isAfter && trigger.isUpdate )
    {
        UserTriggerHandler.afterUpdate( Trigger.new, Trigger.oldMap );
    }


}// @End UserTrigger class