/**
 * Created by JLinn on 6/5/18.
 */

public with sharing class BrandExcellenceMobileUpload{
    
    public Id recordId {get; set;}
    public Brand_Excellence__c brandExcellence {get{
        return [SELECT Id, Name FROM Brand_Excellence__c WHERE Id = : THIS.recordId];
    } set;}
    
    public String surveyRecordType {get{
        return [SELECT RecordType.Name FROM Brand_Excellence__c WHERE Id = : THIS.recordId].RecordType.Name;
    } set;}
    
    public List<Picture_Category__mdt> pictureCategories {get{
        return [SELECT  MasterLabel, DeveloperName, isActive__c, Order__c, Survey__c FROM Picture_Category__mdt WHERE Survey__c = : surveyRecordType AND isActive__c = TRUE ORDER BY Order__c];
    } set;}
    
    public List<String> pictureCategoriesOnly {get{
        List<String> results = new List<String>();
        for (Picture_Category__mdt pc : this.pictureCategories){
            results.add(pc.DeveloperName);
        }
        return results;
    } set;}
    
    public List<String> pictureCategoriesStringOnly {get{
        List<String> results = new List<String>();
        for (Picture_Category__mdt pc : this.pictureCategories){
            results.add('\'' + pc.MasterLabel + '\'');
        }
        return results;
    } set;}
    
    
    public BrandExcellenceMobileUpload(ApexPages.StandardController controller){
        this.recordId = controller.getId();
    }
    
//
    
    @RemoteAction
    public static String uploadPhotosRemote(String picture, String path, String title, String accountId) {
//        System.debug(picture);
//        System.debug(picture.right(picture.length() - 23));
//        System.debug(picture.right(picture.length() - (picture.indexOf(',') + 1)));
//        Blob pictureBlob = Blob.valueOf(picture.right(picture.length() - 23));
//        system.debug(picture.right(picture.length() - 23).left(23));
        //system.debug(pictureBlob.toString().right(20));
        
        System.debug('***ENTERING UPLOAD PHOTOS REMOTE***');
        system.debug(path);
            
            ContentVersion v = new ContentVersion();
            v.VersionData = EncodingUtil.base64Decode(picture.right(picture.length() - (picture.indexOf(',') + 1)));
            v.Description = 'testing description';
            v.Title = title;
            v.PathOnClient = path;
        

        
        try{
            System.debug('***TRYING TO INSERT V***');
            insert v;
            
            
                ContentDocumentLink cdl = new ContentDocumentLink(
                        LinkedEntityId = accountId,
                   ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = : v.Id LIMIT 1].ContentDocumentId,
                        ShareType = 'I'
                );
            
            insert cdl;
            
            return 'Upload Successfully';
        }catch(DmlException e){
            System.debug(e);
            return 'There was an error, check the logs';
        }
        
        
    }
}


//LEGACY ARCHIVE - Because inevitably you will need it the moment you delete it ;)

//public String uploadPhotos() {
//
//        System.debug('# of pictures detected: ' + this.pictures.size());
//
//        List<ContentVersion> contentVersions = new List<ContentVersion>();
//
//
//        for(Blob b : pictures){
//
//            ContentVersion v = new ContentVersion();
//            v.VersionData = b;
//            v.Description = 'testing description';
//            v.Title = 'My Testing Title';
//            v.FirstPublishLocationId = this.accountId;
//
//            contentVersions.add(v);
//
//
//
//        }
//
//        try{
//
//            insert contentVersions;
//
//
//        }catch(DmlException e){
//            System.debug(e);
//        }
//
//
//
//        return '';
//    }