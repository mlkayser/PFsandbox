/*
     * Name                 : RecordTypeUtil
     * Object               : RecordType Metadata
     * Requirement          : Get Recrod Type using metadata
     * Refer classes        : NONE
     * Author               : Magnet 360
     * Modify History       : NONE
 */
public class RecordTypeUtil {

	// Returns Id of the record type for the supplied Object Name and Record Type Name.
    public static Id getRecordTypeIdByName(String objName, String rTypeName) {
		Id rId;
  
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		if(gd.get(objName) != null) {
			Map<String, Schema.RecordTypeInfo> infos = gd.get(objName).getDescribe().getRecordTypeInfosByName();
			rId = infos.get(rTypeName).getRecordTypeId();
		}
        
        return rId;
	}

    
    /* commented way before Planet fitness asked to delete this trigger
    // Not in use. Can be enabled if required.
    public static String getRecordTypeNameById(String objName, Id rTypeId) {
        String rName;
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        
        if(gd.get(objName) != null) {
            Map<Id, Schema.RecordTypeInfo> infos = gd.get(objName).getDescribe().getRecordTypeInfosById();
            rName = infos.get(rTypeId).getName();
        }
        
        return rName;
        
    }*/
    
}