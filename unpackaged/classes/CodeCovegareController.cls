public class CodeCovegareController {

	@AuraEnabled
	public static Map<String, TestSuiteJson> getApexTestSuite() {
		System.debug('CodeCovegareController.getApexTestSuite()');

		final List<ApexTestSuite> apexTestSuiteList = ApexTestSuiteService.getInstance().findApexTestSuite();
		final Map<String, TestSuiteJson> testSuiteJsonMap = new Map<String, TestSuiteJson>();
		for(ApexTestSuite testSuite :apexTestSuiteList) {
			testSuiteJsonMap.put('' + testSuite.id, new TestSuiteJson(testSuite));
		}
		return testSuiteJsonMap;
	}

	@AuraEnabled
	public static List<CodeCovegare> getCodeCovegare(String testSuiteId) {
		System.debug('CodeCovegareController.getCodeCovegare() testSuiteId: ' + testSuiteId);

		Map<String, ApexTestCoverageService.ApexCodeCoverageAggregate> covegareMap;
		if(String.isEmpty(testSuiteId)) {
			covegareMap = ApexTestCoverageService.getInstance().getCodeCoverage();
		} else {
			final ApexTestSuite testSuite = ApexTestSuiteService.getInstance().findApexTestSuite(testSuiteId);
			covegareMap = ApexTestCoverageService.getInstance().getCodeCoverage(testSuite);
		}
		final List<CodeCovegare> covegareList = new List<CodeCovegare>();
		for(ApexTestCoverageService.ApexCodeCoverageAggregate code: covegareMap.values()) {
			covegareList.add(new CodeCovegare(code));
		}
		return covegareList;
	}

	public class TestSuiteJson {
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public String id { get; set; }

		public TestSuiteJson() {}
		public TestSuiteJson(ApexTestSuite testSuite) {
			this.name = testSuite.TestSuiteName;
			this.id = testSuite.Id;
		}
	}

	public class CodeCovegare {
		@AuraEnabled
		public String apexClassOrTriggerId { get; set; }
		@AuraEnabled
		public String apexClassName { get; set; }
		@AuraEnabled
		public Integer numLinesCovered { get; set; }
		@AuraEnabled
		public Integer numLinesUncovered { get; set; }
		@AuraEnabled
		public Decimal perc { get; set; }

		// Default, no-arg constructor, for client-side -> server-side
		public CodeCovegare() {}
		// Trivial constructor, for server-side Apex -> client-side JavaScript
		public CodeCovegare(ApexTestCoverageService.ApexCodeCoverageAggregate coverage) {
			this.apexClassOrTriggerId = coverage.apexClassOrTriggerId;
			this.apexClassName = coverage.apexClassOrTrigger.Name;
			this.numLinesCovered = coverage.numLinesCovered;
			this.numLinesUncovered = coverage.numLinesUncovered;
			this.perc = coverage.percentage();
		}
	}
}