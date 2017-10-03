trigger JogadorMesaTrigger on JogadorMesa__c (before insert, before update, after update) {
    
    if(Trigger.isBefore && Trigger.isInsert) {
        
        Map<Id, SessaoCash__c> cttSessaoMap = new Map<Id, SessaoCash__c>();   
        SessaoCaixa__c sessaoCaixa = ClubeServico.getServico().obterSessaoCaixa();
        
        for(JogadorMesa__c jogMesa : Trigger.New) {
            
            SessaoCash__c sessao = new SessaoCash__c();
            sessao.Cliente__c 	   = jogMesa.Jogador__c;
            sessao.SessaoCaixa__c  = sessaoCaixa.Id;
            sessao.CobrarTaxa__c   = true;
            
            cttSessaoMap.put(jogMesa.Jogador__c, sessao);
        }
        
        List<SessaoCash__c> sessaoList = [
            SELECT Id, Cliente__c, CobrarTaxa__c, DataInicioSessao__c
            FROM SessaoCash__c
            WHERE Cliente__c IN: cttSessaoMap.keySet() 
            AND Status__c = 'Aberta' AND SessaoCaixa__c =: sessaoCaixa.Id
            ORDER BY CreatedDate DESC
        ];
        
        for(SessaoCash__c ses: sessaoList) {
            //configurar as sessao que ja existem
            cttSessaoMap.put(ses.Cliente__c, ses);
        }
        
        UPSERT cttSessaoMap.values();
        
        
        Set<Id> jogadorIdSet = new Set<Id>();
        for(JogadorMesa__c jogMesa : Trigger.New) {
            SessaoCash__c sessaoJogador = cttSessaoMap.get(jogMesa.Jogador__c);
            jogMesa.SessaoJogador__c = sessaoJogador.Id;
            if(jogMesa.Status__c == 'Ativo') {
                jogMesa.DataAtivacao__c = Datetime.now();
                jogadorIdSet.add(jogMesa.Jogador__c);
                
                if(sessaoJogador.DataInicioSessao__c == null) {
                    sessaoJogador.DataInicioSessao__c = Datetime.now();
                }
            }
        }
        
        if(!jogadorIdSet.isEmpty()) {
            ClubeServico.getServico().desativarJogadorMesa(jogadorIdSet);
        }
        
        UPDATE cttSessaoMap.values();
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        Set<Id> jogadorIdSet = new Set<Id>();
        
        for(JogadorMesa__c jogMesa : Trigger.New) {
            if(jogMesa.Status__c == 'Ativo') {
                jogMesa.DataAtivacao__c = Datetime.now();
                jogadorIdSet.add(jogMesa.Jogador__c);
                
            } else if(jogMesa.Status__c == 'Desativo') {
                jogMesa.DataDesativacao__c = Datetime.now();
                jogMesa.UsuarioDesativacao__c = UserInfo.getUserId();
            }
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> jogadorSetId = new Set<Id>();
        Set<Id> jogadorMesaSetId = new Set<Id>();
        
        for(JogadorMesa__c jogMesa : Trigger.New) {
            if(jogMesa.Status__c == 'Ativo') {
                jogadorSetId.add(jogMesa.Jogador__c);
                jogadorMesaSetId.add(jogMesa.Id);     
            }
        }
        
        if(!jogadorSetId.isEmpty()) {
            ClubeServico.getServico().desativarJogadorMesa(jogadorSetId, jogadorMesaSetId);
        }
    }
}