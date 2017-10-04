public abstract class ApexTestObserver extends AbstractService implements Schedulable {
	public static final Integer DELAY_SEGUNDS = 10;

	private String name;
	private Integer deplay;
	private Id testJobId;

	private ApexTestObserver apexSchudulable = this;

	public ApexTestObserver(String name, Integer delay, Id testJobId) {
		this.name = getClass() + '.' + name;
		this.deplay = delay;
		this.testJobId = testJobId;
	}

	protected Boolean isProcessing(AsyncApexJob apexJob) {
		return apexJob.Status.equals('Processing');
	}

	protected Boolean isCompleted(AsyncApexJob apexJob) {
		return apexJob.Status.equals('Completed');
	}

	protected Boolean isResultFail(List<ApexTestResult> resultFail) {
		return !resultFail.isEmpty();
	}

	public static void schedulable(ApexTestObserver apexSchudulable) {
		System.debug('.schedulable() Schedulable: ' + apexSchudulable);

		abortSchedulable(apexSchudulable);
		System.schedule(apexSchudulable.getName(), createCropDelay(apexSchudulable.getDeplay()), apexSchudulable);
	}

	private static void abortSchedulable(ApexTestObserver schedulableClass) {
		System.debug('ApexTestSuiteSchudulable.abortSchedulable() schedulableClass: ' + schedulableClass);

		final List<CronTrigger> cronTriggerList = [
				SELECT Id FROM CronTrigger WHERE CronJobDetail.Name =: schedulableClass.getName() ];

		if(cronTriggerList.isEmpty()) {
			System.debug('.abortSchedulable() cronTriggerList: ' + cronTriggerList);
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

	public String getName() {
		return name;
	}

	public Integer getDeplay() {
		return deplay;
	}

	public Id getTestJobId() {
		return testJobId;
	}

	public void execute(System.SchedulableContext context) {
		System.debug(getClass() + '.execute() datetime: ' + Datetime.now());
		System.debug(getClass() + '.execute() testJobId: ' + apexSchudulable);

		final AsyncApexJob apexJob = findAsyncApexJob(apexSchudulable.testJobId);
		System.debug(getClass() + '.execute() apexJob: ' + apexJob);

		if(isProcessing(apexJob)) {
			schedulable(apexSchudulable);

		} else if(isCompleted(apexJob)) {

			final ApexTestResult[] results = [
					SELECT Outcome, ApexClassId, ApexClass.Name, MethodName, Message, StackTrace
					FROM ApexTestResult
					WHERE AsyncApexJobId =: this.testJobId
			];

			onTestCompleted(results);
		}
	}

	public AsyncApexJob findAsyncApexJob(Id jobId) {
		return  [
				SELECT ID, Status FROM AsyncApexJob
				WHERE Id =: jobId
		];
	}

	public List<ApexTestResult> getResulFail(ApexTestResult[] results) {
		final List<ApexTestResult> apexTestFail = new List<ApexTestResult>();
		for (ApexTestResult apexTest : results) {
			if(isFail(apexTest)) {
				apexTestFail.add(apexTest);
			}
		}
		return apexTestFail;
	}

	public List<ApexTestResult> getResulPass(ApexTestResult[] results) {
		final List<ApexTestResult> apexTestPass = new List<ApexTestResult>();
		for (ApexTestResult apexTest : results) {
			if(isPass(apexTest)) {
				apexTestPass.add(apexTest);
			}
		}
		return apexTestPass;
	}

	public static Boolean isFail(ApexTestResult apexTest) {
		return apexTest.Outcome.equalsIgnoreCase('Fail');
	}

	public static Boolean isPass(ApexTestResult apexTest) {
		return apexTest.Outcome.equalsIgnoreCase('Pass');
	}

	public static Boolean isMessage(ApexTestResult apexTest) {
		return apexTest.Message != null;
	}

	protected abstract void onTestCompleted(ApexTestResult[] results);
}