public with sharing class ApexTestCoverageService {

	private final String CONTENT_TYPE_URLENCODED = 'application/x-www-form-urlencoded';
	private final String CONTENT_TYPE_JSON = 'application/json';

	private static final String TOOLING_QUERY = '/services/data/v37.0/tooling/query/?q=';

	private static ApexTestCoverageService coverageTestService;

	private ApexTestSuiteService testSuiteService;

	private ApexTestCoverageService() {
		this.testSuiteService = ApexTestSuiteService.getInstance();
	}

	public static ApexTestCoverageService getInstance() {
		if(coverageTestService == null) {
			coverageTestService = new ApexTestCoverageService();
		}
		return coverageTestService;
	}

//	public static String createQuery() {
//		return createQuery(new Set<Id>());
//	}

	public static String createQuery(Set<Id> classIdSet) {
		String query = 'SELECT ApexClassOrTrigger.Name, '
				+ ' ApexClassorTriggerId, NumLinesCovered, NumLinesUncovered'
				+ ' FROM ApexCodeCoverageAggregate ';
		if(!classIdSet.isEmpty()) {
			query += 'WHERE ' + buildWhereId('ApexClassorTriggerId', classIdSet);
		}
		query += ' ORDER BY ApexClassOrTrigger.Name';
		return query;
	}

	private static String buildWhereId(String fieldName, Set<Id> idSet) {
		final List<String> inIdList = new List<String>();
		for(Id idW : idSet) {
			inIdList.add('\'' + idW + '\'');
		}
		return fieldName + ' IN (' + String.join(inIdList, ',') + ')';
	}

	public static String createToolingQueryEndpoint(Set<Id> classIdSet) {
		final String objectIdQuery = createQuery(classIdSet);
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

	private Boolean isUnauthorized(HttpResponse response) {
		return response.getStatusCode() == 401;
	}

	private String buildBody(ConnectRemote__c connect) {
		return 'grant_type=password'
				+ '&client_id=' + connect.Client_ID__c
				+ '&client_secret=' + connect.Client_Secret__c
				+ '&username=' + connect.Username__c
				+ '&password=' + connect.Password__c;
	}

	public Map<String, ApexCodeCoverageAggregate> getCodeCoverage(ApexTestSuite apexTestSuite) {
		final List<TestSuiteMembership> memberList =
				testSuiteService.findTestSuiteMembership(apexTestSuite);
		final Set<Id> classOrTriggerIdSet = ApexTestSuiteService.createSetId(memberList);
		return getCodeCoverage(classOrTriggerIdSet);
	}

	public Map<String, ApexCodeCoverageAggregate> getCodeCoverage() {
		return getCodeCoverage(new Set<Id>());
	}

	public Map<String, ApexCodeCoverageAggregate> getCodeCoverage(Set<Id> classIdSet) {
		System.debug('getCodeCoverage() ' + classIdSet);
		final Map<String, ConnectRemote__c> gitConnectMap = ConnectRemote__c.getAll();
		final ConnectRemote__c connect = gitConnectMap.get('Salesforce');

		authenticate(connect);

		try {
			return getCodeCoverage(classIdSet, connect);

		} catch (Exception ex) {
			System.debug('Ex: ' + ex);

			connect.Bearer__c = null;
			authenticate(connect);

			return getCodeCoverage(classIdSet, connect);
		}

		return new Map<String, ApexCodeCoverageAggregate>();
	}

	private Map<String, ApexCodeCoverageAggregate> getCodeCoverage(Set<Id> classIdSet, ConnectRemote__c connect) {
		if(!isBearer(connect)) {
			return new Map<String, ApexCodeCoverageAggregate>();
		}

		final HTTPResponse response = callHttpRequestCodeCoverage(classIdSet, connect);

		if(isUnauthorized(response)) {
			throw new UnauthorizedException('Status Unauthorized - 401');

		} else if(!isSuccess(response)) {
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

	private HTTPResponse callHttpRequestCodeCoverage(Set<Id> classIdSet, ConnectRemote__c connect) {
		System.debug('callHttpRequestCodeCoverage() connect: ' + connect);

		final HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer ' + connect.Bearer__c);
		req.setHeader('Content-Type', CONTENT_TYPE_JSON);
		req.setEndpoint(createToolingQueryEndpoint(classIdSet));
		return httpSend(req);
	}

	private class UnauthorizedException extends Exception { }

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