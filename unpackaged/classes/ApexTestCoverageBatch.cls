global class ApexTestCoverageBatch extends AbstractService implements Database.Batchable<sObject>, Database.AllowsCallouts {

	private final String id;
	global ApexTestCoverageBatch(final String id) {
		this.id	 = id;
	}

	public Void execute(Database.BatchableContext jobId, List<Package__c> recordList) {
		final List<ApexClass__c> classList = ApexTestPackageService.getInstance().findApexClass(recordList.get(0));

		final Set<Id> classIdSet = new Set<Id>();
		for(ApexClass__c classy : classList) {
			System.debug(getClass() + '.onTestCompleted() res: ' + classy);
			classIdSet.add(classy.Apex__c);
		}

		final Map<String, ApexTestCoverageService.ApexCodeCoverageAggregate> codeCoverageMap =
				ApexTestCoverageService.getInstance().getCodeCoverage(classIdSet);

		final List<ApexClassMessage__c> newMessageList = new List<ApexClassMessage__c>();
		for(ApexClass__c apexClass : classList) {
			ApexTestCoverageService.ApexCodeCoverageAggregate coverage = codeCoverageMap.get(apexClass.Apex__c);
			if(coverage != null) {
				apexClass.LinesCovegare__c =  coverage.numLinesCovered;
				apexClass.Lines__c = coverage.numLinesCovered + coverage.numLinesUncovered;
				apexClass.Coverage__c = apexClass.LinesCovegare__c/apexClass.Lines__c * 100;

				if(apexClass.Coverage__c < 75) {
					final ApexClassMessage__c apexMessage = new ApexClassMessage__c();
					apexMessage.Name = 'Covegare Low';
					apexMessage.ApexClass__c = apexClass.Id;
					apexMessage.Outcome__c = 'warn';
					newMessageList.add(apexMessage);
				}
			}
		}

		Database.update(classList);
		Database.insert(newMessageList);
	}

	public Void finish(Database.BatchableContext jobId) {
	}

	public System.Iterable<sObject> start(Database.BatchableContext jobId) {
		return Database.getQueryLocator('SELECT Id FROM Package__c WHERE Id =\''
				+ id + '\'');
	}
}