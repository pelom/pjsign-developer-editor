trigger AccountTrigger on Account (before insert) {
    
    if(Trigger.isBefore && Trigger.isInsert) {
        
        /*final Map<Id, Account> ownerMap = new Map<Id, Account>();
        for(Account acc : Trigger.New) {
            ownerMap.put(acc.OwnerId, acc);
        }
        //System.debug('ownerMap:' + ownerMap);
        
        final Map<Id, Id> userContactMap = new Map<Id, Id>();
        List<User> userList = [ SELECT ID, ContactId FROM User WHERE Id =: ownerMap.keySet() ];
        for(User ser : userList) {
            userContactMap.put(ser.ContactId, ser.Id);
        }
        //System.debug('userContactMap:' + userContactMap);
        
        final Map<Id, Id> contactAccMap = new Map<Id, Id>();
        List<Contact> contactList = [ 
            SELECT ID, AccountId FROM Contact WHERE Id =: userContactMap.keySet() 
        ];
        for(Contact ct : contactList) {
            contactAccMap.put(ct.AccountId, ct.Id);
        }
        //System.debug('contactAccMap:' + contactAccMap);
        
        final List<Account> accUserList = [
            SELECT Id, Name FROM Account WHERE Id=: contactAccMap.keySet() AND isPartner = true
        ];
        //System.debug('accUserList:' + accUserList);
        
        for(Account acc : accUserList) {
            Id contactId = contactAccMap.get(acc.Id);
            Id userId = userContactMap.get(contactId);
            
            Account accIn = ownerMap.get(userId);
            if(accIn.RecordTypeId == null) {
                accIn.RecordTypeId = UtilApex.getRecordTypeId('Account', 'Jogador');     
            }
            
            if(accIn.ParentId == null) {
                accIn.ParentId = acc.Id;
            }
            //System.debug('Acc pai:' + acc);
            //System.debug('Acc in:' + accIn);
        }
		*/
    }
}