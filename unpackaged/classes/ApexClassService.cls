public class ApexClassService extends  AbstractService {

	private static ApexClassService apexClassService;

	public static ApexClassService getInstance() {
		if(apexClassService == null) {
			apexClassService = new ApexClassService();
		}
		return apexClassService;
	}

	public void executeMap(List<ApexClass> apexClassList) {
		System.debug(getClass() + '.executeMap() jobId: ' + apexClassList.size());

		final List<Package__c> packageDefault = [ SELECT Id FROM Package__c WHERE Name = 'br.default' ];
		Package__c packag;
		if(packageDefault.isEmpty()) {
			packag = new Package__c(Name='br.default');
			INSERT packag;
		} else{
			packag = packageDefault.get(0);
		}

		final List<String> nameTestList = new List<String>();

		final Map<String, ApexClass> apexClassMap = new Map<String, ApexClass>();
		for (ApexClass apexClass : apexClassList) {
			apexClassMap.put(apexClass.Id, apexClass);
			nameTestList.add(apexClass.Name + 'Test');
		}

		final List<ApexClass> classTestList = [
				SELECT Id, Name FROM ApexClass
				WHERE Name IN: nameTestList
		];

		final Map<String, ApexClass> apexClassTestMap = new Map<String, ApexClass>();
		for (ApexClass apexClass : classTestList) {
			apexClassTestMap.put(apexClass.Name, apexClass);
		}

		final List<ApexClass__c> classList = [
			SELECT Id, Name, Apex__c FROM ApexClass__c
			WHERE Apex__c IN: apexClassMap.keySet()
		];

		final Map<String, ApexClass__c> classMap = new Map<String, ApexClass__c>();
		for(ApexClass__c classy : classList) {
			classMap.put(classy.Apex__c, classy);
		}

		for(ApexClass apexClass : apexClassList) {
			ApexClass__c classy = classMap.get(apexClass.Id);

			if(classy == null) {
				classy = createClass(packag, apexClass);
			} else {
				classy = updateClass(apexClass, classy);
			}

			final ApexClass apexClassTest = apexClassTestMap.get(apexClass.Name + 'Test');
			if(apexClassTest != null) {
				classy.ApexTest__c = apexClassTest.Id;
			}

			classMap.put(String.valueOf(apexClass.Id), classy);
		}

		try {
			Database.upsert(classMap.values());

		} catch (Exception ex) {
			System.debug('Ex: ' + ex);
		}
	}

	private ApexClass__c updateClass(ApexClass apexClass, ApexClass__c classy) {
		updateProperty(apexClass, classy);
		return classy;
	}

	private ApexClass__c createClass(Package__c packag, ApexClass apexClass) {
		final ApexClass__c classy = new ApexClass__c();
		classy.Apex__c = apexClass.Id;
		classy.Package__c = packag.Id;
		updateProperty(apexClass, classy);
		return classy;
	}

	private ApexClass__c updateProperty(ApexClass apexClass, ApexClass__c classy) {
		classy.Name = apexClass.Name;
		classy.DesignPattern__c = defineDesignPattern(apexClass);
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