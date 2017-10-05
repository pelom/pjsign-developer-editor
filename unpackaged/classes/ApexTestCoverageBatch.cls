global class ApexTestCoverageBatch extends AbstractService implements Database.Batchable<sObject>, Database.AllowsCallouts {

	private final String id;
	global ApexTestCoverageBatch(final String id) {
		this.id	 = id;
	}

	public Void execute(Database.BatchableContext jobId, List<Package__c> recordList) {
		final Package__c packag = recordList.get(0);
//		final List<ApexClass__c> classList = ApexTestPackageService.getInstance().findApexClass(recordList.get(0));
//
//		final Set<Id> classIdSet = new Set<Id>();
//		for(ApexClass__c classy : classList) {
//			System.debug(getClass() + '.onTestCompleted() res: ' + classy);
//			classIdSet.add(classy.Apex__c);
//		}

		final Map<Id, ApexClass__c> apexIdApexClass =
				ApexTestPackageService.getInstance().createApexIdApexClassMap(packag);

		final Map<String, ApexTestCoverageService.ApexCodeCoverageAggregate> codeCoverageMap =
				ApexTestCoverageService.getInstance().getCodeCoverage(apexIdApexClass.keySet());

		final List<ApexClassMessage__c> newMessageList = new List<ApexClassMessage__c>();
		for(ApexClass__c apexClass : apexIdApexClass.values()) {
			ApexTestCoverageService.ApexCodeCoverageAggregate coverage = codeCoverageMap.get(apexClass.Apex__c);
			if(coverage != null) {
				updateCoverage(apexClass, coverage);

				if(isErrorCoverage(apexClass)) {
					final ApexClassMessage__c apexMessage = createMessage(apexClass);
					newMessageList.add(apexMessage);
				}
			}
		}

		Database.update(apexIdApexClass.values());
		Database.insert(newMessageList);

		final Package__c packageDb = ApexTestPackageService.getInstance().findApexTestPackage(packag.Id);
		packageDb.Coverage__c = (packageDb.NumberLinesCoverage__c/ packageDb.NumberLines__c) * 100;
		UPDATE packageDb;
	}

	private ApexClass__c updateCoverage(ApexClass__c apexClass,
										ApexTestCoverageService.ApexCodeCoverageAggregate coverage) {
		apexClass.LinesCovegare__c =  coverage.numLinesCovered;
		apexClass.Lines__c = coverage.numLinesCovered + coverage.numLinesUncovered;
		apexClass.Coverage__c = apexClass.LinesCovegare__c/apexClass.Lines__c * 100;
		return apexClass;
	}

	private Boolean isErrorCoverage(ApexClass__c apexClass) {
		return apexClass.Coverage__c < 75
				&& apexClass.Lines__c != null
				&& apexClass.Coverage__c != null;
	}

	private ApexClassMessage__c createMessage(ApexClass__c apexClass) {
		final ApexClassMessage__c apexMessage = new ApexClassMessage__c();
		apexMessage.Name = 'Covegare Low';
		apexMessage.ApexClass__c = apexClass.Id;
		apexMessage.Outcome__c = 'warn';
		return apexMessage;
	}

	public Void finish(Database.BatchableContext jobId) {
	}

	public System.Iterable<sObject> start(Database.BatchableContext jobId) {
		return Database.getQueryLocator('SELECT Id FROM Package__c WHERE Id =\''
				+ id + '\'');
	}
}