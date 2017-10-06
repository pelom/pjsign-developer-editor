public class ApexClassBatch extends AbstractServiceSchedulable {

	private final Boolean full;

	public ApexClassBatch(Boolean full) {
		super(ONLY_RUN);

		this.full = full;
	}

	public ApexClassBatch(Integer minutes) {
		super(minutes);
		this.full = false;
	}

	public void execute(Database.BatchableContext jobId, List<sObject> recordList) {
		System.debug(getClass() + '.execute() jobId: ' + jobId);
		ApexClassService.getInstance().executeMap(recordList);
	}

	public Database.QueryLocator start(Database.BatchableContext jobId) {
		System.debug(getClass() + '.start() jobId: ' + jobId);

		final Datetime dta = Datetime.now().addMinutes(-this.minutes);

		String query = null;
		if(this.full) {
			query = ApexClassService.createQueryFull();
		} else {
			query = ApexClassService.createQuery(
							dta.formatGMT('yyyy-MM-dd') + 'T'
							   + dta.formatGMT('HH:mm:ss.SSS') + 'Z');
		}

		System.debug(getClass() + '.start() query: ' + query);
		return Database.getQueryLocator(query);
	}
}