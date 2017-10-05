public class ApexClassService extends  AbstractService {

	private static final String PACKAGE_DEFAULT = 'br.default';

	private static ApexClassService apexClassService;
	private static ApexDeveloperService developerService;

	public ApexClassService() {
		developerService = ApexDeveloperService.getInstance();
	}

	public static ApexClassService getInstance() {
		if(apexClassService == null) {
			apexClassService = new ApexClassService();
		}
		return apexClassService;
	}

	public void executeMap(List<ApexClass> apexClassList) {
		System.debug(getClass() + '.executeMap() jobId: ' + apexClassList.size());

		final Package__c packageDefault = getPackageDefault();
		final Map<String, ApexClass> apexClassMap = new Map<String, ApexClass>();
		for (ApexClass apexClass : apexClassList) {
			apexClassMap.put(apexClass.Id, apexClass);
		}
		final Map<String, ApexClass> apexClassTestMap = createApexClassTestMap(apexClassMap);
		final Map<String, ApexClass__c> classMap = createClassMap(apexClassMap);
		final Map<String, List<ApexDeveloper__c>> classDeveloperMap = createApexDeveloperMap(apexClassMap);

		final List<ApexClass__c> newApexClassList = new List<ApexClass__c>();
		final List<ApexDeveloper__c> developerList = new List<ApexDeveloper__c>();
		final List<ApexDeveloperLog__c> logList = new List<ApexDeveloperLog__c>();

		for(ApexClass apexClass : apexClassList) {
			ApexClass__c classy = classMap.get(apexClass.Id);

			if(classy == null) {
				classy = createClass(packageDefault, apexClass);
				newApexClassList.add(classy);
			} else {
				if(isUpdateClass(apexClass, classy)) {
					final List<ApexDeveloper__c> devList =
							classDeveloperMap.get(String.valueOf(apexClass.Id));

					final List<ApexDeveloper__c> exist = new List<ApexDeveloper__c>();
					for(ApexDeveloper__c dev : devList) {
						if(dev.User__c == apexClass.LastModifiedById) {
							System.debug('update: ' + dev);

							ApexDeveloperLog__c log = developerService.createApexDeveloperLog(dev, classy, apexClass);
							logList.add(log);

							exist.add(dev);
						}
					}

					if(exist.isEmpty()) {
						exist.add(developerService.createApexDeveloper(classy, apexClass));
					}

					developerList.addAll(exist);
					classy = updateClass(apexClass, classy);
				}
			}

			final ApexClass apexClassTest = apexClassTestMap.get(apexClass.Name + 'Test');
			if(apexClassTest != null) {
				classy.ApexTest__c = apexClassTest.Id;
			}

			classMap.put(String.valueOf(apexClass.Id), classy);
		}

		try {
			Database.UpsertResult[] result = Database.upsert(classMap.values());
//			final List<ApexClass__c> newClassList = new List<ApexClass__c>();
//			for(Database.UpsertResult res : result) {
//				if(res.isCreated()) {
//					newClassList.add();
//				}
//			}

			for(ApexClass__c classy : newApexClassList) {
				final ApexClass apexClass = apexClassMap.get(classy.Apex__c);
				developerList.add(developerService.createApexDeveloper(classy, apexClass));
			}

			if(!developerList.isEmpty()) {
				result = Database.upsert(developerList);
				final List<Id> isList = new List<Id>();
				for(Database.UpsertResult res : result) {
					if(res.isCreated()) {
						isList.add(res.getId());
					}
				}
				final List<ApexDeveloper__c> devList = [
						SELECT Id, Name, ApexClass__r.Apex__c FROM ApexDeveloper__c WHERE Id IN: isList];

				for(ApexDeveloper__c dev : devList) {
					final ApexClass apexClass = apexClassMap.get(dev.ApexClass__r.Apex__c);
					final ApexClass__c classy = classMap.get(dev.ApexClass__r.Apex__c);
					ApexDeveloperLog__c log = developerService.createApexDeveloperLog(dev, classy, apexClass);
					log.Date__c = apexClass.CreatedDate;
					log.Message__c = 'Criou ';
					logList.add(log);
				}
			}

			if(!logList.isEmpty()) {
				Database.insert(logList);
			}

		} catch (Exception ex) {
			System.debug('Ex: ' + ex);
		}
	}

	private Package__c getPackageDefault() {
		final List<Package__c> packageDefault =
			[ SELECT Id FROM Package__c WHERE Name =: PACKAGE_DEFAULT ];

		Package__c packageReturn = null;
		if(packageDefault.isEmpty()) {
			packageReturn = new Package__c(Name=PACKAGE_DEFAULT);
			INSERT packageReturn;
		} else{
			packageReturn = packageDefault.get(0);
		}
		return packageReturn;
	}

	private Map<String, ApexClass> createApexClassTestMap(Map<String, ApexClass> apexClassMap) {
		final List<String> nameTestList = new List<String>();
		for (ApexClass apexClass : apexClassMap.values()) {
			nameTestList.add(buildNameTest(apexClass));
		}

		final List<ApexClass> classTestList = [
				SELECT Id, Name FROM ApexClass
				WHERE Name IN: nameTestList
		];

		final Map<String, ApexClass> apexClassTestMap = new Map<String, ApexClass>();
		for (ApexClass apexClass : classTestList) {
			apexClassTestMap.put(apexClass.Name, apexClass);
		}
		return apexClassTestMap;
	}

	private Map<String, ApexClass__c> createClassMap(Map<String, ApexClass> apexClassMap) {
		final List<ApexClass__c> classList = [
				SELECT Id, Name, Apex__c, DateCreated__c, DateUpdate__c
				FROM ApexClass__c
				WHERE Apex__c IN: apexClassMap.keySet()
		];

		final Map<String, ApexClass__c> classMap = new Map<String, ApexClass__c>();
		for(ApexClass__c classy : classList) {
			classMap.put(classy.Apex__c, classy);
		}
		return classMap;
	}

	private Map<String, List<ApexDeveloper__c>> createApexDeveloperMap(Map<String, ApexClass> apexClassMap) {
		final List<ApexDeveloper__c> developerList = developerService.find(apexClassMap.values());

		final Map<String, List<ApexDeveloper__c>> classMap = new Map<String, List<ApexDeveloper__c>>();
		for(ApexDeveloper__c dev : developerList) {
			List<ApexDeveloper__c> devList = classMap.get(dev.ApexClass__r.Apex__c);
			if(devList == null) {
				devList = new List<ApexDeveloper__c>();
			}
			devList.add(dev);
			classMap.put(dev.ApexClass__r.Apex__c, devList);
		}
		return classMap;
	}

	private String buildNameTest(ApexClass apexClass) {
		return apexClass.Name + 'Test';
	}

	private ApexClass__c updateClass(ApexClass apexClass, ApexClass__c classy) {
		updateProperty(apexClass, classy);
		return classy;
	}

	private Boolean isUpdateClass(ApexClass apexClass, ApexClass__c classy) {
		if(classy.DateUpdate__c == null) {
			return true;
		}

		return apexClass.LastModifiedDate != classy.DateUpdate__c;
	}

	private ApexClass__c createClass(Package__c packag, ApexClass apexClass) {
		final ApexClass__c classy = new ApexClass__c();
		classy.Apex__c = apexClass.Id;
		classy.Package__c = packag.Id;
		classy.DateCreated__c = apexClass.CreatedDate;
		updateProperty(apexClass, classy);
		return classy;
	}

	private ApexClass__c updateProperty(ApexClass apexClass, ApexClass__c classy) {
		classy.Name = apexClass.Name;
		classy.DesignPattern__c = defineDesignPattern(apexClass);
		classy.DateUpdate__c = apexClass.LastModifiedDate;
		return classy;
	}

	private String defineDesignPattern(ApexClass apexClass) {
		if(apexClass.Name.endsWithIgnoreCase('Controller')) {
			return 'Controller';
		} else if(apexClass.Name.endsWithIgnoreCase('Service')) {
			return 'Service';
		} else if(apexClass.Name.endsWithIgnoreCase('BO')) {
			return 'Business Object';
		} else if(apexClass.Name.endsWithIgnoreCase('DAO')) {
			return 'Data Access Object';
		} else if(apexClass.Name.endsWithIgnoreCase('Util')) {
			return 'Util';
		} else if(apexClass.Name.endsWithIgnoreCase('Utils')) {
			return 'Util';
		}
		return null;
	}

	public static String createQuery() {
		return 'SELECT Id, Name, '
				+ ' CreatedDate, CreatedById, CreatedBy.Name,'
				+ ' LastModifiedDate, LastModifiedById, LastModifiedBy.Name'
				+ ' FROM ApexClass '
				+ ' ORDER BY CreatedDate DESC '
		;
	}
}