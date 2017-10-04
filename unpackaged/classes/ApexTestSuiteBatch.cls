global class ApexTestSuiteBatch implements Database.Batchable<sObject>, Schedulable {
	public void execute(Database.BatchableContext jobId, List<ApexTestSuite> recordList) {
		System.debug('ApexTestSuiteBatch.execute() jobId: ' + jobId);

		for(ApexTestSuite suite : recordList) {
			final Id testJobId = ApexTestSuiteService.getInstance().enqueueTests(suite);
			ApexTestSuiteSchedulable.schedulable(new ApexTestSuiteSchedulable(suite, testJobId));
		}
	}

	public void finish(Database.BatchableContext jobId) {
		System.debug('ApexTestSuiteBatch.finish() jobId: ' + jobId);
	}

	public Database.QueryLocator start(Database.BatchableContext jobId) {
		System.debug('ApexTestSuiteBatch.start() jobId: ' + jobId);
		final String query = ApexTestSuiteService.createQuery();
		System.debug('ApexTestSuiteBatch.start() query: ' + query);
		return Database.getQueryLocator(query);
	}

	public void execute(System.SchedulableContext context) {
		System.debug('JobIdApexTestSuiteBatch.execute()');
		final Id jobId = Database.executeBatch(new ApexTestSuiteBatch());
		System.debug('Schedulable.execute() jobId: ' + jobId);
	}
}