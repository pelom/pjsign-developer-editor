public with sharing class ApexUtils {

	private static final String replyAddress = 'forceApex@kolekto.com.br';
	private static final String senderDisplayName = 'Force Apex - Fail Test';

	public static void sendEmailFail(String subject, String textBody, String[] emailList) {
		final Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(emailList );
		mail.setReplyTo(replyAddress);
		mail.setSenderDisplayName(senderDisplayName);
		mail.setSubject(subject);
		mail.setPlainTextBody(textBody);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	public static String formatCrop(Datetime now) {
		return now.second()
				+ ' ' + now.minute()
				+ ' ' + now.hour()
				+ ' ' + now.day()
				+ ' ' + now.month()
				+ ' ?'
				+ ' ' + now.year();
	}
}