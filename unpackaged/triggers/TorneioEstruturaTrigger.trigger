trigger TorneioEstruturaTrigger on TorneioEstrutura__c (after insert) {
    
    if(Trigger.isAfter && Trigger.isInsert) {
        
        Schema.DescribeFieldResult fieldResult =
            TorneioNivel__c.Nivel__c.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String> valueList = new List<String>();
        for( Schema.PicklistEntry f : ple) {
            valueList.add(f.getValue());
        }
        
        List<TorneioNivel__c> tNivelList = new List<TorneioNivel__c>();
        for(TorneioEstrutura__c tEs : Trigger.New) {
            for(String nivelValue : valueList) {
                TorneioNivel__c nivel = new TorneioNivel__c();
                nivel.Name = tEs.Name + ' - Nível ' + nivelValue;
                nivel.DuracaoBlinds__c = tEs.TempoBlinds__c;
                nivel.Nivel__c = nivelValue;
                nivel.TorneioEstrutura__c = tEs.Id;
                
                tNivelList.add(nivel);
            }
        }
        
        try {
            INSERT tNivelList;
            
        } catch(Exception ex) {
            System.debug('Ex: ' + ex);
            
        }
    }
}