@isTest
public class PFProjectSiteRequestTest {

	public static testMethod void PFProjectSiteRequest() {

	PFProjectSiteRequest testRequest = new PFProjectSiteRequest();
	List<SelectOption> agreementTypes = testRequest.getAgreementTypes();
	testRequest.franchiseeName = 'Test Franchisee';
	testRequest.ownershipGroup = 'Test Group';
	testRequest.agreementType = 'NA';
	testRequest.agreementNumber = '1111111111';
	testRequest.siteAddress = 'Main St';
	testRequest.submit();

	}
}