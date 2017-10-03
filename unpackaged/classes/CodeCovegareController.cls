public class CodeCovegareController {

	@AuraEnabled
	public static List<CodeCovegare> getCodeCovegare(String session) {
		System.debug('UserInfo.getSessionID() : ' + UserInfo.getSessionID());
		final Map<String, ApexTestCoverageService.ApexCodeCoverageAggregate> covegareMap =
				ApexTestCoverageService.getInstance().callHttpRequest();

		final List<CodeCovegare> covegareList = new List<CodeCovegare>();
		for(ApexTestCoverageService.ApexCodeCoverageAggregate code: covegareMap.values()) {
			covegareList.add(new CodeCovegare(code));
		}
		return covegareList;
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