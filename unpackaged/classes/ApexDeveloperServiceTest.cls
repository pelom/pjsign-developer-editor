/**
 * Created by andreleite on 05/10/17.
 */
@IsTest
private class ApexDeveloperServiceTest {

	@IsTest static void testGetInstance() {
		ApexDeveloperService apexDeveloperServi = ApexDeveloperService.getInstance();
		System.assertEquals(true, apexDeveloperServi != null);
	}

	@IsTest static void testFind() {
		final List<ApexClass> apexClassList = [
				SELECT Id, Name, CreatedDate, CreatedById, CreatedBy.Name,
				LastModifiedDate, LastModifiedById, LastModifiedBy.Name
				FROM ApexClass LIMIT 10];

		ApexDeveloperService apexDeveloperServi = ApexDeveloperService.getInstance();
		final List<ApexDeveloper__c> developerList = apexDeveloperServi.find(apexClassList);
		System.assertEquals(0, developerList.size());

		final Package__c packageApex = ApexClassService.getInstance().getPackageDefault();
		final ApexClass apexClass = apexClassList.get(0);
		final ApexClass__c classy = ApexClassService.getInstance().createClass(packageApex, apexClass);
		INSERT classy;

		System.assertEquals(apexClass.Name, classy.Name);

		final ApexDeveloper__c developer = ApexDeveloperService.getInstance().createApexDeveloper(classy, apexClass);
		INSERT developer;


		final List<ApexDeveloper__c> developerList2 = apexDeveloperServi.find(apexClassList);
		System.assertEquals(1, developerList2.size());

		final List<ApexDeveloper__c> developerList3 = apexDeveloperServi.find(new List<ApexClass__c> { classy });
		System.assertEquals(1, developerList2.size());

		System.assertEquals(developerList2.get(0).Id, developerList3.get(0).Id);

		final ApexDeveloperLog__c apexDeveloperLog = apexDeveloperServi.createApexDeveloperLog(developer, classy, apexClass);
		INSERT apexDeveloperLog;
		System.assertEquals(true, apexDeveloperLog != null);
	}

	@IsTest static void testFindUser() {
		ApexDeveloperService apexDeveloperServi = ApexDeveloperService.getInstance();
		final User user = apexDeveloperServi.findUser(UserInfo.getUserId());
		System.assertEquals(true, user != null);
	}
}