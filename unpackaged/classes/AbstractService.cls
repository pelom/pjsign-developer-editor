public abstract class AbstractService {

	public String getClass() {
		final String value = String.valueOf(this);
		final Integer endIndex = value.indexOf(':');
		return value.substring(0, endIndex);
	}

	public Set<Id> createaList(Database.UpsertResult[] result) {
		final Set<Id> isSet = new Set<Id>();

		for(Database.UpsertResult res : result) {
			if(res.isCreated()) {
				isSet.add(res.getId());
			}
		}

		return isSet;
	}
}