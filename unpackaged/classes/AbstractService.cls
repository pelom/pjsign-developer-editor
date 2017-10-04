public abstract class AbstractService {

	public String getClass() {
		final String value = String.valueOf(this);
		final Integer endIndex = value.indexOf(':');
		return value.substring(0, endIndex);
	}

}