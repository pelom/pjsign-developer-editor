trigger CompraFichaTrigger on CompraFicha__c (before insert) {
    
    if(Trigger.isBefore && Trigger.isInsert) {
        
        Account accClube = ClubeServico.getServico().obterClube(UserInfo.getUserId());
        
        if(accClube == null) {
            throw new UtilApex.UtilApexException('Nao foi possível encontrar a conta do Clube');
        }
        
        accClube = [
            SELECT Id, TaxaCartaoDebito__c, TaxaCartaoCredito__c
            FROM Account
            WHERE Id =: accClube.Id
        ];
        
        SessaoCaixa__c sessaoCaixa = ClubeServico.getServico().obterSessaoCaixa();
        
        Map<Id, SessaoCash__c> cttSessaoMap = new Map<Id, SessaoCash__c>();
        for(CompraFicha__c compra : Trigger.New) {
            SessaoCash__c sessao = new SessaoCash__c();
            sessao.Cliente__c 	   = compra.Cliente__c;
            sessao.SessaoCaixa__c  = sessaoCaixa.Id;
            sessao.CobrarTaxa__c   = true;
            
            cttSessaoMap.put(compra.Cliente__c, sessao);
        }
        
        List<SessaoCash__c> sessaoList = [
            SELECT Id, Cliente__c, CobrarTaxa__c
            FROM SessaoCash__c
            WHERE Cliente__c IN: cttSessaoMap.keySet() AND Status__c = 'Aberta'
            ORDER BY CreatedDate DESC
        ];
        
        for(SessaoCash__c ses: sessaoList) {
            cttSessaoMap.put(ses.Cliente__c, ses);
        }
		
        UPSERT cttSessaoMap.values();
        
        for(CompraFicha__c compra : Trigger.New) {
            SessaoCash__c sessaoJogador = cttSessaoMap.get(compra.Cliente__c);
            
            compra.SessaoCash__c = sessaoJogador.Id;
            compra.Status__c = compra.FormaPagamento__c == 'Vale/Crédito' ? 'Aberta' : 'Paga';
            
            compra.Valor_Total__c = (compra.Valor_Total__c == null || compra.Valor_Total__c == 0) ? 
                compra.Fichas__c : compra.Valor_Total__c;
            
            if(sessaoJogador.CobrarTaxa__c) {
                compra.Valor_Total__c = ClubeServico.getServico().calcTaxa(
                    accClube, compra.FormaPagamento__c, compra.Valor_Total__c);    
            }
        }
    }   
}