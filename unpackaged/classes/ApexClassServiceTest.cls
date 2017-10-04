/**
 * Created by andreleite on 04/10/17.
 */
@IsTest
private class ApexClassServiceTest {

	@IsTest
	static void testGetInstance() {

	}

	@IsTest
	static void testExecuteMap() {

	}

	@IsTest
	static void testCreateQuery() {
		final String query = ApexClassService.createQuery();
		System.assertEquals(true, query != null);
	}
}