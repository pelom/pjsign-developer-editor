public abstract class ApexTestRunSchedulable extends AbstractServiceSchedulable {

	public static final Integer NEXT_RUN_MINUTES = 1;

	public static final String Processing = 'Processing';
	public static final String Completed = 'Completed';

	public static final String STATUS_FAIL = 'Fail';
	public static final String STATUS_PASS = 'Pass';

	private final String name;
	private final Id testJobId;

	public ApexTestRunSchedulable(String name, Id testJobId) {
		super(NEXT_RUN_MINUTES);
		this.name = getClass() + '.' + name;
		this.testJobId = testJobId;
	}

	protected override String getName() {
		return this.name;
	}

	public ApexTestRunSchedulable(Integer minutes) {
		super(minutes);
	}

	protected Boolean isProcessing(AsyncApexJob apexJob) {
		return apexJob.Status.equals(Processing);
	}

	protected Boolean isCompleted(AsyncApexJob apexJob) {
		return apexJob.Status.equals(Completed);
	}

	protected Boolean isResultFail(List<ApexTestResult> resultFail) {
		return !resultFail.isEmpty();
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
		return apexTest.Outcome.equalsIgnoreCase(STATUS_FAIL);
	}

	public static Boolean isPass(ApexTestResult apexTest) {
		return apexTest.Outcome.equalsIgnoreCase(STATUS_PASS);
	}

	public static Boolean isMessage(ApexTestResult apexTest) {
		return apexTest.Message != null;
	}

	protected abstract void onTestCompleted(ApexTestResult[] results);

	public override void execute(System.SchedulableContext context) {
		System.debug(getClass() + '.execute() context: ' + context);

		System.debug(getClass() + '.execute() datetime: ' + Datetime.now());
		System.debug(getClass() + '.execute() testJobId: ' + testJobId);

		final AsyncApexJob apexJob = findAsyncApexJob(this.testJobId);
		System.debug(getClass() + '.execute() apexJob: ' + apexJob);

		if(isProcessing(apexJob)) {
			abortSchedulable();
			runSchudule();

		} else if(isCompleted(apexJob)) {

			final ApexTestResult[] results = [
					SELECT Outcome, ApexClassId, ApexClass.Name, MethodName, Message, StackTrace
					FROM ApexTestResult
					WHERE AsyncApexJobId =: this.testJobId
			];

			onTestCompleted(results);
		}
	}

	public override void finish(Database.BatchableContext jobId) { }
	public void execute(Database.BatchableContext jobId, List<sObject> recordList) { }
	public System.Iterable<sObject> start(Database.BatchableContext jobId) { return null; }
}