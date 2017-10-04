public class ApexClassBatch extends AbstractService implements Database.Batchable<sObject>, Schedulable {

	public Void execute(System.SchedulableContext context) {
	}

	public Void execute(Database.BatchableContext jobId, List<sObject> recordList) {
		System.debug(getClass() + '.execute() jobId: ' + jobId);
		ApexClassService.getInstance().executeMap(recordList);
	}

	public Void finish(Database.BatchableContext jobId) {
		Database.executeBatch(new ApexTestPackageBatch());
	}

	public Database.QueryLocator start(Database.BatchableContext jobId) {
		System.debug(getClass() + '.start() jobId: ' + jobId);
		final String query = ApexClassService.createQuery();
		System.debug(getClass() + '.start() query: ' + query);
		return Database.getQueryLocator(query);
	}
}