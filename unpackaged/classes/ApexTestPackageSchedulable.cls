public with sharing class ApexTestPackageSchedulable extends ApexTestObserver {

	private Package__c packag;

	public ApexTestPackageSchedulable(Package__c packag, Id testJobId) {
		super(packag.Name, DELAY_SEGUNDS, testJobId);
		this.packag = packag;
	}

	public override void onTestCompleted(ApexTestResult[] results) {
		System.debug(getClass() + '.onTestCompleted()');
		Database.executeBatch(new ApexTestCoverageBatch(packag.Id));

		final List<ApexClass__c> classList =
				ApexTestPackageService.getInstance().findApexClass(packag);

		final Map<String, ApexClass__c> apexClassMap = new Map<String, ApexClass__c>();
		Set<Id> deleteMessage = new Set<Id>();
		for(ApexClass__c cls : classList) {
			deleteMessage.add(cls.Id);
			apexClassMap.put(cls.Apex__c, cls);
		}

		final List<ApexClassMessage__c> messageList = [
			SELECT Id FROM ApexClassMessage__c WHERE ApexClass__c IN: deleteMessage
		];

		Database.delete(messageList);

		final List<ApexClassMessage__c> newMessageList = new List<ApexClassMessage__c>();
		for(ApexTestResult apexTest : results) {
			ApexClass__c classsy = apexClassMap.get(apexTest.ApexClassId);

			if(isFail(apexTest)) {
				final ApexClassMessage__c apexMessage = new ApexClassMessage__c();
				apexMessage.Name = 'Test Erro';
				apexMessage.ApexClass__c = classsy.Id;
				apexMessage.Outcome__c = apexTest.Outcome;
				apexMessage.Message__c = apexTest.Message;
				apexMessage.MethodName__c = apexTest.MethodName;
				apexMessage.StackTrace__c = apexTest.StackTrace;

				newMessageList.add(apexMessage);
			}
		}

		Database.insert(newMessageList);
	}

	public Package__c getPackag() {
		return packag;
	}
}