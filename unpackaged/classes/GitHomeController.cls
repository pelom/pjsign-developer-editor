public with sharing class GitHomeController {

	@AuraEnabled
	public static String serverEcho(String firstName) {
		Map<String, GitConnect__c> gitConnectMap = GitConnect__c.getAll();
		return ('Hello from the server, ' + firstName + ' ' + gitConnectMap);
	}

	@AuraEnabled
	public static List<SimpleAccount> getAccounts() {

		// Perform isAccessible() check here

		// SimpleAccount is a simple "wrapper" Apex class for transport
		List<SimpleAccount> simpleAccounts = new List<SimpleAccount>();

		List<Account> accounts = [SELECT Id, Name, Phone FROM Account LIMIT 5];
		for (Account acct : accounts) {
			simpleAccounts.add(new SimpleAccount(acct.Id, acct.Name, acct.Phone));
		}

		return simpleAccounts;
	}

	public class SimpleAccount {
		@AuraEnabled
		public String Id { get; set; }
		@AuraEnabled
		public String Name { get; set; }
		public String Phone { get; set; }

		// Default, no-arg constructor, for client-side -> server-side
		public SimpleAccount() {}

		// Trivial constructor, for server-side Apex -> client-side JavaScript
		public SimpleAccount(String id, String name, String phone) {
			this.Id = id;
			this.Name = name;
			this.Phone = phone;
		}
	}

	// This method is recommended.
	@AuraEnabled
	public static List<Account> getExpenses() {
		String [] expenseAccessFields = new String [] { 'Id', 'Name', 'CreatedDate' };


		// Obtain the field name/token map for the Expense object
		Map<String,Schema.SObjectField> m = Schema.SObjectType.Account.fields.getMap();

		for (String fieldToCheck : expenseAccessFields) {
			// Check if the user has access to view field
			if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
				// Pass error to client
				throw new System.NoAccessException();
				// Suppress editor logs
				return null;
			}
		}

		// Query the object safely
		return [ SELECT Id, Name, CreatedDate FROM Account];
	}
}