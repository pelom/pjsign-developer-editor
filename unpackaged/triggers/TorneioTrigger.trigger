trigger TorneioTrigger on Torneio__c (after insert) {
    
    if(Trigger.isAfter && Trigger.isInsert) {
        
        List<TorneioEvento__c> eventList = new List<TorneioEvento__c>();
        
        for(Torneio__c t : Trigger.New) {
            Datetime ini = t.DataInicio__c;
            Datetime fim = t.DataFinal__c;
            Integer dias = t.DataInicio__c.date().daysBetween(t.DataFinal__c.date());
            
            while(dias > 0) {
                fim = fim.addDays(-1);
                
                TorneioEvento__c event = new TorneioEvento__c();
                event.Name = 'DIA ' + dias;
                event.Torneio__c = t.Id;
                event.Data__c = fim;
                
                eventList.add(event);
                
                dias--;
            }
            
            dias = t.DataInicio__c.date().daysBetween(t.DataFinal__c.date());
            
            TorneioEvento__c event = new TorneioEvento__c();
            event.Name = (dias > 0 ? 'DIA FINAL' : t.DataFinal__c.date().format());
            event.Torneio__c = t.Id;
            event.Data__c = t.DataFinal__c;
            eventList.add(event);
        }
        
        try {
            INSERT eventList;
            
        } catch(Exception ex) {
            System.debug('Ex: ' + ex);
            
        }
    }
}