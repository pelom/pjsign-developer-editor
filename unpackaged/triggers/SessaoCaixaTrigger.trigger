trigger SessaoCaixaTrigger on SessaoCaixa__c (before insert) {
    
    if(Trigger.isBefore && Trigger.isInsert) {
        
        QueueSobject queue = 
            ClubeServico.getServico().obterFilaClube(UserInfo.getUserId());
        if(queue != null) {
            for(SessaoCaixa__c sc : Trigger.New) {
                sc.OwnerId = queue.QueueId;
            }
        }
    }
    
}