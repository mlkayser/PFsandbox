public abstract class PFBaseController {
    
    protected User currentUser{
        
        get {
            if ( this.currentUser == null ) {
                this.currentUser = 
                    [select ContactId,
                        Contact.Id, Contact.Name, Contact.AccountId, Contact.RecordType.Name,
                        Contact.Account.Id, Contact.Account.Name, Contact.Account.Group_Name__c
                    from User
                    where Id = :UserInfo.getUserId()];
            }
            return this.currentUser;
        }
        private set;
    }

    protected Contact getCurrentUserContact() {
        return this.currentUser.Contact;
    }

    protected Account getCurrentUserAccount() {
        return this.currentUser.Contact.Account;
    }

}