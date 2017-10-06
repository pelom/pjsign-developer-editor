public abstract class AbstractServiceSchedulable extends AbstractService implements Database.Batchable<sObject>, Schedulable {

	public static final Integer ONLY_RUN = -1;

	protected final Integer minutes;
	public AbstractServiceSchedulable(Integer minutes) {
		this.minutes = minutes;
	}

	public virtual void execute(System.SchedulableContext context) {
		System.debug(getClass() + '.execute() context: ' + context);
		Database.executeBatch(this);
	}

	public virtual void finish(Database.BatchableContext jobId) {
		System.debug(getClass() + '.finish() jobId: ' + jobId);

		abortSchedulable();

		if(this.minutes < 1) {
			return;
		}

		runSchudule();
	}

	public void runSchudule() {
		final Datetime next =  Datetime.now().addMinutes(this.minutes);
		final String nextCrop = ApexUtils.formatCrop(next);

		System.schedule(getName(), nextCrop, this);
	}

	protected virtual String getName() {
		return getClass();
	}

	public void abortSchedulable() {
		System.debug(getClass() + '.abortSchedulable() serviceSchedulable: ' + this.getName());

		final List<CronTrigger> cronTriggerList = [
				SELECT Id FROM CronTrigger WHERE CronJobDetail.Name =: this.getName() ];

		if(cronTriggerList.isEmpty()) {
			System.debug(getClass() + '.abortSchedulable() cronTriggerList: ' + cronTriggerList);
			return;
		}

		final CronTrigger cronTrigger = cronTriggerList.get(0);
		System.debug(getClass() + '.abortSchedulable() cronTrigger: ' + cronTrigger);
		System.abortjob(cronTrigger.Id);
	}
}