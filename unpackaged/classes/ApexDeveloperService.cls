public class ApexDeveloperService {

	private static ApexDeveloperService apexDeveloperService;

	public static ApexDeveloperService getInstance() {
		if(apexDeveloperService == null) {
			apexDeveloperService = new ApexDeveloperService();
		}
		return apexDeveloperService;
	}

	public List<ApexDeveloper__c> find(List<ApexClass> apexClassList) {
		Set<String> apexSet = new Set<String>();
		for (ApexClass apexClass : apexClassList) {
			apexSet.add(apexClass.Id);
		}
		return [
				SELECT Id, Name, ApexClass__c, User__c, ApexClass__r.Apex__c
				FROM ApexDeveloper__c WHERE ApexClass__r.Apex__c IN: apexSet
		];
	}

	public List<ApexDeveloper__c> find(List<ApexClass__c> apexClassList) {
		return [
			SELECT Id, Name, ApexClass__c, User__c
			FROM ApexDeveloper__c WHERE ApexClass__c IN: apexClassList
		];
	}

	public User findUser(Id user) {
		return [
			SELECT Id, Name FROM User WHERE Id =: user
		];
	}

	public ApexDeveloper__c createApexDeveloper(ApexClass__c classy, ApexClass apexClass) {
		ApexDeveloper__c  apexDeveloper = new ApexDeveloper__c();
		apexDeveloper.ApexClass__c = classy.Id;
		apexDeveloper.Name = apexClass.CreatedBy.Name;
		apexDeveloper.User__c = apexClass.CreatedById;

		return apexDeveloper;
	}

	public ApexDeveloperLog__c createApexDeveloperLog(ApexDeveloper__c developer, ApexClass__c classy, ApexClass apexClass) {
		final ApexDeveloperLog__c log = new ApexDeveloperLog__c();
		log.Name = developer.Name;
		log.Message__c = 'Atualizou ';
		log.Date__c = apexClass.LastModifiedDate;
		log.ApexDeveloper__c = developer.Id;
		log.ApexClass__c = classy.Id;
		return log;
	}
}