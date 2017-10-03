public with sharing class ApexTestCoverageService {

	private static ApexTestCoverageService coverageTestService;
	private static final String TOOLING_QUERY = '/services/data/v37.0/tooling/query/?q=';

	public static ApexTestCoverageService getInstance() {
		if(coverageTestService == null) {
			coverageTestService = new ApexTestCoverageService();
		}
		return coverageTestService;
	}

	public static String createQuery() {
		return 'SELECT ApexClassOrTrigger.Name, '
			+ ' ApexClassorTriggerId, NumLinesCovered, NumLinesUncovered'
			+ ' FROM ApexCodeCoverageAggregate'
			+ ' ORDER BY ApexClassOrTrigger.Name';
	}

	public static String createEndpoint() {
		final String objectIdQuery = createQuery();
		final String environmentURL = URL.getSalesforceBaseUrl().toExternalForm()
				+ TOOLING_QUERY
				+ EncodingUtil.urlEncode(objectIdQuery, 'UTF-8');
		return environmentURL;
	}

	public Map<String, ApexCodeCoverageAggregate> callHttpRequest() {
//		HttpRequest req = new HttpRequest();
//		req.setMethod('POST');
//		req.setHeader('Content-Type','application/x-www-form-urlencoded');
//		req.setEndpoint('https://ap5.salesforce.com/services/oauth2/token');
//
//		String CLIENT_ID = '3MVG9KI2HHAq33RyCXLr7ztl_lvwe7pXW2rtlrSVj_s5loAZ2ErjL3IZ2kxdERppa_DN5OhBU.iyIPhOMLZv5';
//		String CLIENT_SECRET = '2987054690991388622';
//		String USERNAME = 'andre.leite@pjsign.com.br';
//		String PASSWORD = 'soad87ww';
//
//		req.setBody('grant_type=password' + '&client_id='+CLIENT_ID +
//				'&client_secret='+CLIENT_SECRET + '&username='+USERNAME + '&password='+PASSWORD);
//
//		Http http = new Http();
//		HTTPResponse response = http.send(req);
//		System.debug('Body ' + response.getBody());
//		System.debug('Status ' + response.getStatus());
//		System.debug('Status code ' + response.getStatusCode());

		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer 00D61000000KRpr!AQoAQCUwGQGHzJdfeJaRlEMO4Ajxsf2SBOtPVi5lK4DMhuAO.MfbYXNcnCFX2xUosHmbr48A0yX1zNppnNTp4EpwO8_FPk0n');
		req.setHeader('Content-Type', 'application/json');
		req.setEndpoint(createEndpoint());

		final String body = new Http().send(req).getBody();
		System.debug('body: ' + body);
		ApexTestCoverageService.ApexCodeCoverage apexCodeCoverageAggrregate =
				(ApexTestCoverageService.ApexCodeCoverage)JSON.deserialize(body,
								ApexTestCoverageService.ApexCodeCoverage.class);

		final Map<String, ApexCodeCoverageAggregate> classCoverageMap = new Map<String, ApexCodeCoverageAggregate>();
		for(ApexCodeCoverageAggregate agrr : apexCodeCoverageAggrregate.records) {
			classCoverageMap.put(agrr.apexClassOrTriggerId, agrr);
		}
		return classCoverageMap;
	}

	public class ApexCodeCoverage {
		public Integer size;
		public Integer totalSize;
		public List<ApexCodeCoverageAggregate> records;
	}

	public class ApexCodeCoverageAggregate {
		public Id apexClassOrTriggerId;
		public Integer numLinesCovered;
		public Integer numLinesUncovered;
		public Name apexClassOrTrigger;
		public Decimal perc;

		public Decimal percentage() {
			this.perc = 0;
			if(numLinesCovered == 0) {
				return this.perc;
			}
			final Integer total = numLinesUncovered + numLinesCovered;
			return this.perc = Decimal.valueOf((Double) numLinesCovered / total) * 100;
		}
	}

	public class Name {
		public String Name;
	}
}