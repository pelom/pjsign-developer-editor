global class ApexTestPackageServiceSchedulable extends AbstractServiceSchedulable {

	public ApexTestPackageServiceSchedulable(Integer minutes) {
		super(minutes);
	}

	public void execute(Database.BatchableContext jobId, List<Package__c> recordList) {
		System.debug(getClass() + '.execute() jobId: ' + jobId);

		for (Package__c packa : recordList) {
			try {
				final Id testJobId = ApexTestPackageService.getInstance().enqueueTests(packa);
				System.debug('testJobId: ' + testJobId);

				final ApexTestRunPackageSchedulable apexTestPackage =
						new ApexTestRunPackageSchedulable(packa, testJobId);

				apexTestPackage.abortSchedulable();
				apexTestPackage.runSchudule();

				packa.DateLastRunTest__c = Datetime.now();
			} catch (Exception ex) {
				System.debug('Ex: ' + ex);
			}

		}

		Database.update(recordList);
	}

	public Database.QueryLocator start(Database.BatchableContext jobId) {
		System.debug(getClass() + '.start() jobId: ' + jobId);
		final String query = ApexTestPackageService.createQuery();
		System.debug(getClass() + '.start() query: ' + query);
		return Database.getQueryLocator(query);
	}
}