public with sharing class ApexTestSuiteService {

	private static ApexTestSuiteService suiteTestService;

	public String getClass() {
		final String value = String.valueOf(this);
		final Integer endIndex = value.indexOf(':');
		return value.substring(0, endIndex);
	}

	public static ApexTestSuiteService getInstance() {
		if(suiteTestService == null) {
			suiteTestService = new ApexTestSuiteService();
		}
		return suiteTestService;
	}

	public static String createQuery() {
		return 'SELECT Id, TestSuiteName, IsDeleted,'
			+ ' CreatedDate, CreatedById, CreatedBy.Name,'
			+ ' LastModifiedDate, LastModifiedById, LastModifiedBy.Name'
			+ ' FROM ApexTestSuite '
			+ ' WHERE IsDeleted = false '
			+ ' ORDER BY CreatedDate ASC '
		;
	}

	public Id enqueueTests(ApexTestSuite apexTestSuite) {
		System.debug(getClass() + '.enqueueTests() apexTestSuite: ' + apexTestSuite);

		final List<TestSuiteMembership> memberList = findTestSuiteMembership(apexTestSuite);

		if(memberList.isEmpty()) {
			System.debug('Not found membership apexTestSuite: ' + apexTestSuite.TestSuiteName);
			return null;
		}

		final Set<Id> apexClassIdSet = new Set<Id>();
		for (TestSuiteMembership member: memberList) {
			apexClassIdSet.add(member.ApexClassId);
		}

		final ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
		for (Id apexClassId : apexClassIdSet) {
			queueItems.add(new ApexTestQueueItem(ApexClassId=apexClassId));
		}
		if(queueItems.isEmpty()) {
			System.debug('Not found membership apexTestSuite: ' + apexTestSuite.TestSuiteName);
			return null;
		}
		INSERT queueItems;

		// Get the job ID of the first queue item returned.
		final ApexTestQueueItem item = [
				SELECT ParentJobId FROM ApexTestQueueItem
				WHERE Id =: queueItems[0].Id
				LIMIT 1
		];
		return item.ParentJobId;
	}

	public List<ApexTestSuite> findApexTestSuite() {
		return [
				SELECT Id, TestSuiteName, IsDeleted,
				CreatedDate, CreatedById, CreatedBy.Name,
				LastModifiedDate, LastModifiedById, LastModifiedBy.Name
				FROM ApexTestSuite
		];
	}

	public ApexTestSuite findApexTestSuite(Id apexTestSuiteId) {
		return [
				SELECT Id, TestSuiteName, IsDeleted,
				CreatedDate, CreatedById, CreatedBy.Name,
				LastModifiedDate, LastModifiedById, LastModifiedBy.Name
				FROM ApexTestSuite
				WHERE Id =: apexTestSuiteId
		];
	}

	public List<TestSuiteMembership> findTestSuiteMembership(ApexTestSuite apexTestSuite) {
		return [
			SELECT Id, ApexClassId, ApexTestSuiteId
			FROM TestSuiteMembership
			WHERE ApexTestSuiteId =: apexTestSuite.Id
		];
	}

	// Get the status and pass rate for each class
	// whose tests were run by the job.
	// that correspond to the specified job ID.
	public void checkClassStatus(ID jobId) {
		final ApexTestQueueItem[] items = [
				SELECT ApexClass.Name, Status, ExtendedStatus
				FROM ApexTestQueueItem
				WHERE ParentJobId=:jobId
		];
		for (ApexTestQueueItem item : items) {
			String extStatus = item.extendedstatus == null ? '' : item.extendedStatus;
			System.debug(item.ApexClass.Name + ': ' + item.Status + extStatus);
		}
	}

	// Get the result for each test method that was executed.
	public List<ApexTestResult> checkMethodStatus(ID jobId) {
		final ApexTestResult[] results = [
				SELECT Outcome, ApexClassId, ApexClass.Name, MethodName, Message, StackTrace
				FROM ApexTestResult
				WHERE AsyncApexJobId =: jobId
		];

		final List<ApexTestResult> apexTestFail = new List<ApexTestResult>();
		for (ApexTestResult apexTest : results) {

			if(isFail(apexTest)) {
				apexTestFail.add(apexTest);
			} else if(isPass(apexTest)) { }
		}
		return apexTestFail;
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

	public void checkRunResult(Id jobId) {
		System.debug('ApexTestSuiteService.checkRunResult() jobId: ' + jobId);

		final ApexTestRunResult[] runResults = [
				SELECT JobName, IsAllTests, Source, StartTime, EndTime, TestTime,
				Status, ClassesEnqueued, ClassesCompleted,
				MethodsEnqueued, MethodsCompleted, MethodsFailed
				FROM ApexTestRunResult
				WHERE AsyncApexJobId =: jobId
		];

		for(ApexTestRunResult runTest : runResults) {
			System.debug('ApexTestSuiteService.checkRunResult() runTest: ' + runTest);
		}
	}

	public AsyncApexJob findAsyncApexJob(Id jobId) {
		return  [
			SELECT ID, Status FROM AsyncApexJob
			WHERE Id =: jobId
		];
	}

	public Map<Id, List<ApexTestResult>> createResultFailMap(List<ApexTestResult> resultFail) {
		System.debug('ApexTestSuiteService.createResultFailMap() resultFail: ' + resultFail.size());

		final Map<Id, List<ApexTestResult>> classIdApexTest = new Map<Id, List<ApexTestResult>>();

		for(ApexTestResult apexTest : resultFail) {
			List<ApexTestResult> resultList = classIdApexTest.get(apexTest.ApexClassId);

			if(resultList == null) {
				resultList = new List<ApexTestResult>();
			}

			resultList.add(apexTest);
			classIdApexTest.put(apexTest.ApexClassId, resultList);
		}

		return classIdApexTest;
	}

	public void sendEmailFail(ApexTestSuite apexTestSuite, List<ApexTestResult> resultFail) {
		final Map<Id, List<ApexTestResult>> classIdApexTest =
				ApexTestSuiteService.getInstance().createResultFailMap(resultFail);

		final Map<Id, ApexClass> apexClassMap = ApexTestSuiteService.getInstance()
				.createApexClassMap(classIdApexTest);

//				final List<ApexClass> apexClassList = [
//						SELECT Id, LastModifiedById, Name FROM ApexClass
//						WHERE Id IN: classIdApexTest.keySet() ];
//
//				final Set<Id> userLastSet = new Set<Id>();
//				for(ApexClass cla : apexClassMap.values()) {
//					userLastSet.add(cla.LastModifiedById);
//				}

		final Map<Id, User> userMap = ApexTestSuiteService.getInstance()
				.createUserMap(apexClassMap);

		final Map<Id, List<String>> userIdFail = ApexTestSuiteService.getInstance()
				.createUserIdFailMap(classIdApexTest, userMap, apexClassMap);

		for(Id userId : userIdFail.keySet()) {
			final User user = userMap.get(userId);
			final List<String> bodyList = userIdFail.get(userId);

			String textBody = '';
			for(String body : bodyList) {
				textBody += body + '\n';
			}
			ApexUtils.sendEmailFail('Force Apex[Fail Test] - ' + apexTestSuite.TestSuiteName,
					textBody, new String[] { user.Email });
		}
	}

	public Map<Id, ApexClass> createApexClassMap(Map<Id, List<ApexTestResult>> classIdApexTest) {
		final Map<Id, ApexClass> apexClassMap = new Map<Id, ApexClass>([
				SELECT Id, LastModifiedById, Name FROM ApexClass
				WHERE Id IN: classIdApexTest.keySet()
		]);

		return apexClassMap;
	}

	public Map<Id, User> createUserMap(Map<Id, ApexClass> apexClassMap) {
		final Set<Id> userLastSet = new Set<Id>();
		for(ApexClass cla : apexClassMap.values()) {
			userLastSet.add(cla.LastModifiedById);
		}

		final Map<Id, User> userMap = new Map<Id, User>([
				SELECT Id, Name, Email FROM User WHERE Id IN: userLastSet]);

		return userMap;
	}

	public Map<Id, List<String>> createUserIdFailMap(
			Map<Id, List<ApexTestResult>> classIdApexTest,
			Map<Id, User> userMap,
			Map<Id, ApexClass> apexClassMap) {
		Map<Id, List<String>> userIdFail = new Map<Id, List<String>>();
		for(ApexClass cla : apexClassMap.values()) {
			final List<ApexTestResult> resultList = classIdApexTest.get(cla.Id);
			final User user = userMap.get(cla.LastModifiedById);

			String textBody = '';
			for(ApexTestResult apexTest : resultList) {
				textBody += 'ApexClass.Name: ' + apexTest.ApexClass.Name + '\n';
				textBody += 'Outcome: ' + apexTest.Outcome + '\n';
				textBody += 'MethodName: ' + apexTest.MethodName + '\n';
				textBody += 'Message: ' + apexTest.Message + '\n';
				textBody += 'StackTrace: ' + apexTest.StackTrace + '\n';
				textBody += '\n';
			}

			List<String> textBodyList = userIdFail.get(user.Id);
			if(textBodyList == null) {
				textBodyList = new List<String>();
			}
			textBodyList.add(textBody);
			userIdFail.put(user.Id, textBodyList);
		}
		return userIdFail;
	}
}