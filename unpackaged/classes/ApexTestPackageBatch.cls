global class ApexTestPackageBatch extends AbstractService implements Database.Batchable<sObject>, Schedulable {

	public void execute(Database.BatchableContext jobId, List<Package__c> recordList) {
		System.debug(getClass() + '.execute() jobId: ' + jobId);

		for (Package__c packa : recordList) {
			final Id testJobId = ApexTestPackageService.getInstance().enqueueTests(packa);
			System.debug('testJobId: ' +testJobId);
			ApexTestObserver.schedulable(new ApexTestPackageSchedulable(packa, testJobId));
		}
	}

	public void finish(Database.BatchableContext jobId) {
		System.debug('ApexTestSuiteBatch.finish() jobId: ' + jobId);
	}

	public Database.QueryLocator start(Database.BatchableContext jobId) {
		System.debug('ApexTestSuiteBatch.start() jobId: ' + jobId);
		final String query = ApexTestPackageService.createQuery();
		System.debug('ApexTestSuiteBatch.start() query: ' + query);
		return Database.getQueryLocator(query);
	}

	public void execute(System.SchedulableContext context) {
		System.debug('JobIdApexTestSuiteBatch.execute()');
		final Id jobId = Database.executeBatch(new ApexTestPackageBatch());
		System.debug('Schedulable.execute() jobId: ' + jobId);
	}
}