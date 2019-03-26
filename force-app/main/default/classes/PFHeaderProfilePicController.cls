public class PFHeaderProfilePicController{

	public String profileImageUrl { get; set; }
    public String acctId { get; set; }
    public List<user> lstuser;
    
    public PFHeaderProfilePicController () {
         lstuser = [select FullPhotoUrl,SmallPhotoUrl,Contact.Id,Contact.Account.Id from User where Id =: UserInfo.getUserId()];
         User u = lstuser[0];
         profileImageUrl = u.SmallPhotoUrl;
    }

}