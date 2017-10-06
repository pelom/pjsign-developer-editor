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
		System.assertEquals(true, false, 'Error test');
	}

	@IsTest
	static void testCreateQuery() {
		final String query = ApexClassService.createQueryFull();
		System.assertEquals(true, query != null);
	}
}