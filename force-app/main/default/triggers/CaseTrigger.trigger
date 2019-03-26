trigger CaseTrigger on Case ( before insert , after insert, after update) 
{

    if( trigger.isBefore && trigger.isInsert )
    {
        CaseHelper.populateAccountLookup(trigger.new);
        
    }
    else if( trigger.isAfter && trigger.isInsert )
    {
        //CaseHelper.shareCase( trigger.new );
        
    }
    else if( trigger.isAfter && trigger.isUpdate )
    {
        //CaseHelper.removeShareCase( trigger.new , trigger.oldMap );
        //CaseHelper.shareCase( trigger.new );
    }

}