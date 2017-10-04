public class ApexTestPackageService extends  AbstractService {

	private static ApexTestPackageService apexTestPackageService;
	public static ApexTestPackageService getInstance() {
		if(apexTestPackageService == null) {
			apexTestPackageService = new ApexTestPackageService();
		}
		return apexTestPackageService;
	}

	public Id enqueueTests(Package__c packag) {
		System.debug(getClass() + '.enqueueTests() packag: ' + packag);

		final List<ApexClass__c> memberLis = findApexClass(packag);
		final List<String> memberTestIdList = new List<String>();
		for(ApexClass__c classy: memberLis) {
			System.debug('classy: ' + classy);
			if(!String.isEmpty(classy.ApexTest__c)) {
				memberTestIdList.add(classy.ApexTest__c);
			}
		}
		final List<ApexClass__c> memberTestList = findApexClassTest(memberTestIdList);

		if(memberTestList.isEmpty()) {
			System.debug('Not found MemberTestList package: ' + packag.Name);
			return null;
		}

		final ApexTestQueueItem[] queueItems = createApexTestQueueItem(memberTestList);
		if(queueItems.isEmpty()) {
			System.debug('Not found MemberTestList package: ' + packag.Name);
			return null;
		}

		INSERT queueItems;

		// Get the job ID of the first queue item returned.
		final ApexTestQueueItem item = [
				SELECT ParentJobId FROM ApexTestQueueItem
				WHERE Id =: queueItems[0].Id
				LIMIT 1];
		return item.ParentJobId;
	}

	public static List<ApexTestQueueItem> createApexTestQueueItem(List<ApexClass__c> memberList) {
		final ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
		for (ApexClass__c apexClass : memberList) {
			queueItems.add(new ApexTestQueueItem(ApexClassId=apexClass.Apex__c));
		}
		return queueItems;
	}

	public List<Package__c> findApexTestPackage() {
		return [
				SELECT Id, Name, CreatedDate, CreatedById, CreatedBy.Name,
				LastModifiedDate, LastModifiedById, LastModifiedBy.Name
				FROM Package__c
		];
	}

	public List<ApexClass__c> findApexClass(Package__c packag) {
		return [
				SELECT Id, Name, Apex__c, ApexTest__c, LinesCovegare__c, Lines__c, Coverage__c
				FROM ApexClass__c
				WHERE Package__c =: packag.Id
		];
	}

	public List<ApexClass__c> findApexClassTest(List<String> apexClassTestList) {
		return [
				SELECT Id, Name, Apex__c, ApexTest__c, LinesCovegare__c, Lines__c, Coverage__c
				FROM ApexClass__c
				WHERE Apex__c IN: apexClassTestList
		];
	}

	public static String createQuery() {
		return 'SELECT Id, Name,'
				+ ' CreatedDate, CreatedById, CreatedBy.Name,'
				+ ' LastModifiedDate, LastModifiedById, LastModifiedBy.Name'
				+ ' FROM Package__c '
				//+ ' WHERE IsDeleted = false '
				+ ' ORDER BY CreatedDate ASC '
		;
	}
}