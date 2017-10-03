trigger TorneioEventoTrigger on TorneioEvento__c (after insert) {
    
    
    /*if(Trigger.isAfter && Trigger.isInsert) {
        
        Map<Id, TorneioEvento__c> tEventMap = new  Map<Id, TorneioEvento__c>();
        for(TorneioEvento__c ev : Trigger.New) {
            tEventMap.put(ev.Id, ev);
        }
        
        List<TorneioEvento__c> eventDbList = [
            SELECT Id, Name, Data__c, Torneio__r.Titulo__c
            FROM TorneioEvento__c
            WHERE ID=:tEventMap.keySet()
        ];
        
        List<Event> eventList = new List<Event>();
        
        for(TorneioEvento__c ev : eventDbList) {
            Event event = new Event(
                OwnerId = UserInfo.getUserId(),
                StartDateTime = ev.Data__c,
                EndDateTime = ev.Data__c.addHours(8),
                ActivityDateTime = ev.Data__c,
                Subject = ev.Torneio__r.Titulo__c + ' - ' + ev.Name
            );
        }
    }*/
    
    
    
}