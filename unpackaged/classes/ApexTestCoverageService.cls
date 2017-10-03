public with sharing class ApexTestCoverageService {

	private final String CONTENT_TYPE_URLENCODED = 'application/x-www-form-urlencoded';
	private final String CONTENT_TYPE_JSON = 'application/json';

	private static final String TOOLING_QUERY = '/services/data/v37.0/tooling/query/?q=';

	private static ApexTestCoverageService coverageTestService;

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

	public static String createToolingQueryEndpoint() {
		final String objectIdQuery = createQuery();
		final String environmentURL = URL.getSalesforceBaseUrl().toExternalForm()
				+ TOOLING_QUERY
				+ EncodingUtil.urlEncode(objectIdQuery, 'UTF-8');
		return environmentURL;
	}

	public static String createOauth2Endpoint(final String url) {
		final String environmentURL = System.URL.getSalesforceBaseUrl().toExternalForm()
				+ '' + url;
		return environmentURL;
	}

	public ConnectRemote__c authenticate(ConnectRemote__c connect) {
		System.debug('authenticate() connect: ' + connect);

		if(isBearer(connect)) {
			return connect;
		}

		final HTTPResponse response = callHttpRequestAuthenticate(connect);

		if(!isSuccess(response)) {
			return connect;
		}

		final SalesforceOauth salesforceOauth = (SalesforceOauth) JSON.deserialize(
				response.getBody(), ApexTestCoverageService.SalesforceOauth.class);

		connect.Bearer__c = salesforceOauth.access_token;
		return connect;
	}

	private Boolean isBearer(ConnectRemote__c connect) {
		return connect.Bearer__c != null;
	}

	private HTTPResponse callHttpRequestAuthenticate(ConnectRemote__c connect) {
		System.debug('callHttpRequestAuthenticate() connect: ' + connect);

		final HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setHeader('Content-Type', CONTENT_TYPE_URLENCODED);
		req.setEndpoint(createOauth2Endpoint(connect.URL__c));
		req.setBody(buildBody(connect));

		return httpSend(req);
	}

	private HttpResponse httpSend(HttpRequest req) {
		System.debug('httpSend() req: ' + req);

		final HTTPResponse response =  new Http().send(req);
		System.debug('Body ' + response.getBody());
		System.debug('Status ' + response.getStatus());
		System.debug('Status code ' + response.getStatusCode());
		return response;
	}

	private Boolean isSuccess(HttpResponse response) {
		return response.getStatusCode() == 200;
	}

	private String buildBody(ConnectRemote__c connect) {
		return 'grant_type=password'
				+ '&client_id=' + connect.Client_ID__c
				+ '&client_secret=' + connect.Client_Secret__c
				+ '&username=' + connect.Username__c
				+ '&password=' + connect.Password__c;
	}

	public Map<String, ApexCodeCoverageAggregate> getCodeCoverage() {
		final Map<String, ConnectRemote__c> gitConnectMap = ConnectRemote__c.getAll();
		final ConnectRemote__c connect = gitConnectMap.get('Salesforce');

		authenticate(connect);

		try {
			return getCodeCoverage(connect);

		} catch (Exception ex) {
			System.debug('Ex: ' + ex);

			connect.Bearer__c = null;
			authenticate(connect);

			return getCodeCoverage(connect);
		}

		return new Map<String, ApexCodeCoverageAggregate>();
	}

	private Map<String, ApexCodeCoverageAggregate> getCodeCoverage(ConnectRemote__c connect) {
		if(!isBearer(connect)) {
			return new Map<String, ApexCodeCoverageAggregate>();
		}

		final HTTPResponse response = callHttpRequestCodeCoverage(connect);

		if(!isSuccess(response)) {
			return new Map<String, ApexCodeCoverageAggregate>();
		}

		final ApexCodeCoverage apexCodeCoverage = (ApexCodeCoverage) JSON.deserialize(
				response.getBody(), ApexTestCoverageService.ApexCodeCoverage.class);

		final Map<String, ApexCodeCoverageAggregate> classCoverageMap = new Map<String, ApexCodeCoverageAggregate>();
		for(ApexCodeCoverageAggregate agrr : apexCodeCoverage.records) {
			classCoverageMap.put(agrr.apexClassOrTriggerId, agrr);
		}

		UPDATE connect;

		return classCoverageMap;
	}

	private HTTPResponse callHttpRequestCodeCoverage(ConnectRemote__c connect) {
		System.debug('callHttpRequestCodeCoverage() connect: ' + connect);

		final HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer ' + connect.Bearer__c);
		req.setHeader('Content-Type', CONTENT_TYPE_JSON);
		req.setEndpoint(createToolingQueryEndpoint());
		return httpSend(req);
	}

	public class SalesforceOauth {
		public String access_token;
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