global class ApexTestSuiteSchedulable implements Schedulable {

	private static final String NAME = 'ApexTestSuiteSchudulable';
	private static final Integer DELAY_SEGUNDS = 60;

	private ApexTestSuite apexTestSuite;
	private Id testJobId;
	private String nameTest;

	private ApexTestSuiteSchedulable suiteSchudulable = this;
	private ApexTestSuiteService apexTestService;

	public ApexTestSuiteSchedulable(ApexTestSuite apexTestSuite, Id testJobId) {
		this.nameTest = genarateKey(apexTestSuite);
		this.apexTestSuite = apexTestSuite;
		this.testJobId = testJobId;
		this.apexTestService = ApexTestSuiteService.getInstance();
	}

	private static String genarateKey(ApexTestSuite apexTestSuite) {
		return NAME + '.' + apexTestSuite.TestSuiteName;
	}

	public void execute(System.SchedulableContext context) {
		System.debug('ApexTestSuiteSchudulable.execute() datetime: ' + Datetime.now());
		System.debug('ApexTestSuiteSchudulable.execute() schedulableClass: ' + suiteSchudulable);

		final AsyncApexJob apexJob = this.apexTestService.findAsyncApexJob(this.testJobId);
		System.debug('ApexTestSuiteSchudulable.execute() apexJob: ' + apexJob);

		if(isProcessing(apexJob)) {
			schedulable(suiteSchudulable);

		} else if(isCompleted(apexJob)) {
			final List<ApexTestResult> resultFail =
					this.apexTestService.checkMethodStatus(this.testJobId);

			if(isResultFail(resultFail)) {
				this.apexTestService.sendEmailFail(this.apexTestSuite, resultFail);
			}
		}
	}

	private static Boolean isProcessing(AsyncApexJob apexJob) {
		return apexJob.Status.equals('Processing');
	}

	private static Boolean isCompleted(AsyncApexJob apexJob) {
		return apexJob.Status.equals('Completed');
	}

	private static Boolean isResultFail(List<ApexTestResult> resultFail) {
		return !resultFail.isEmpty();
	}

	public static void schedulable(ApexTestSuiteSchedulable schedulableClass) {
		System.debug('ApexTestSuiteSchudulable.schedulable() schedulableClass: ' + schedulableClass);

		abortSchedulable(schedulableClass);

		System.schedule(schedulableClass.nameTest, createCropDelay(DELAY_SEGUNDS), schedulableClass);
	}

	private static void abortSchedulable(ApexTestSuiteSchedulable schedulableClass) {
		System.debug('ApexTestSuiteSchudulable.abortSchedulable() schedulableClass: ' + schedulableClass);

		final List<CronTrigger> cronTriggerList = [
				SELECT Id FROM CronTrigger WHERE CronJobDetail.Name =: schedulableClass.nameTest ];

		if(cronTriggerList.isEmpty()) {
			System.debug('ApexTestSuiteSchudulable.abortSchedulable() cronTriggerList: ' + cronTriggerList);
			return;
		}

		System.abortjob(cronTriggerList.get(0).Id);
	}

	public static String createCropDelay(Integer delaySeconds) {
		System.debug('ApexTestSuiteSchudulable.createCropDelay() delaySeconds: ' + delaySeconds);

		final Datetime next =  Datetime.now().addSeconds(delaySeconds);
		final String nextCrop = ApexUtils.formatCrop(next);
		return nextCrop;
	}
}