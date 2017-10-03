/*
* Classe responsavel por tratar as regras de negocio referente 
* ao modelo Clube (Tipo de registro do objeto Conta)
*/

public with sharing class ClubeServico {
    
    public static ClubeServico clubeServico = null;
    public static ClubeServico getServico() {
        if(clubeServico == null) {
            clubeServico = new clubeServico();
        }
        return clubeServico;
    }
    
    /**
	 * Obter a conta clube do usuario
	 */
    public Account obterClube(Id userId) {
        System.debug('obterClube: ' + userId);
        
        User user = [
            SELECT Id, ContactId, Username
            FROM USer
            WHERE Id =:userId
        ];
        
        System.debug('user: ' + user);
        
        if(user == null || user.ContactId == null) {
            
            if(user.Username != null) {
                
                List<Account> accList = [
                    SELECT Id, RecordTypeId
                    FROM Account
                    WHERE Name =: user.Username
                ];
                
                if(!accList.isEmpty()) {
                    return accList.get(0);
                }
            }
            
            return null;
        }
        
        Contact contato =[
            SELECT Id, AccountId
            FROM Contact
            WHERE Id =: user.ContactId
        ];
        
        if(contato == null || contato.AccountId == null) {
            return null;
        }
        
        return [
            SELECT Id, Name, RecordTypeId
            FROM Account
            WHERE Id =: contato.AccountId
        ];
    }
    
    public SessaoCaixa__c obterSessaoCaixa() {
        
        List<SessaoCaixa__c> sessaoCaixa = [
            SELECT Id, Name
            FROM SessaoCaixa__c
            WHERE Status__c = 'Aberta'
            ORDER BY CreatedDate ASC
        ];
        
        if(sessaoCaixa.isEmpty()) {
            return null;
        }
        
        return sessaoCaixa.get(0);
    }
    
    public SessaoCash__c criarSessao(Contact jogador) {
        SessaoCash__c sessao = new SessaoCash__c();
        sessao.Cliente__c 		= jogador.Id;
        sessao.SessaoCaixa__c  = obterSessaoCaixa().Id;
        sessao.CobrarTaxa__c = true;
        
        List<SessaoCash__c> sessaoList = [
            SELECT Id, Cliente__r.FirstName, Cliente__r.LastName, CobrarTaxa__c
            FROM SessaoCash__c
            WHERE Cliente__c =: jogador.Id AND Status__c = 'Aberta'
            ORDER BY CreatedDate DESC
        ];
        
        if(!sessaoList.isEmpty()) {
            sessao = sessaoList.get(0);
        }
        
        if(sessao.Id == null) {
            INSERT sessao;    
        }
        
        return sessao;
    }
    
    public Boolean isVagaMesa(Id mesaId) {
        Mesa__c mesa = [
            SELECT Id, TotalVagas__c 
            FROM Mesa__c WHERE Id =: mesaId
        ];
        
        List<JogadorMesa__c> jMList = [
            SELECT Id FROM JogadorMesa__c 
            WHERE Mesa__c =: mesaId AND Status__c = 'Ativo'
        ];
        
        //a vaga?
        if(jMList.size() < mesa.TotalVagas__c) {
            return true;
        }
        return false;
    }
    
    public void addJogador(JogadorMesa__c jogadorMesa) {
        Id mesaId = jogadorMesa.Mesa__c; 
        Id jogId = jogadorMesa.Jogador__c;
        
        List<JogadorMesa__c> jMesaList = [
            SELECT Id, Status__c FROM JogadorMesa__c 
            WHERE Mesa__c =: mesaId 
            AND Jogador__c =: jogId AND Status__c in('Em Espera', 'Ativo') 
        ];
        
        if(jMesaList.isEmpty()) {
            INSERT jogadorMesa;
        	return;
        }
        
        JogadorMesa__c jogadorMesaDb = jMesaList.get(0);
        if(jogadorMesaDb.Status__c == 'Em Espera') {
            jogadorMesa.Id = jogadorMesaDb.Id;
            jogadorMesa.Status__c	= 'Ativo'; 
            
            UPDATE jogadorMesa;
        }
    }
    
    /*public Boolean addJogadorMesa(JogadorMesa__c jM) {
        System.debug('addJogadorMesa: ' + jM);
        
        Id mesaId = jM.Mesa__c; 
        Id jogId = jM.Jogador__c;
        Boolean temVaga = isVagaMesa(mesaId);
        
        List<JogadorMesa__c> jMesaList = [
            SELECT Id, Status__c FROM JogadorMesa__c 
            WHERE Mesa__c =: mesaId 
            AND Jogador__c =: jogId AND Status__c in('Em Espera', 'Ativo') 
        ];
        
        if(!jMesaList.isEmpty()) {
            
            if(temVaga && jMesaList.get(0).Status__c == 'Em Espera') {
                
                desativarJogadorMesa(jogId);
                
                jM.Id = jMesaList.get(0).Id;
                jM.DataAtivacao__c	= Datetime.now();
                jM.Status__c	= 'Ativo'; 
                
                UPDATE jM;
                
                return true;
            }
            
        } else {
            
            jM.Status__c = (temVaga ? 'Ativo' :'Em Espera');
            
            if(jM.Status__c == 'Ativo') {
                jM.DataAtivacao__c	= Datetime.now();
                
                desativarJogadorMesa(jogId);
            }
            
            INSERT jM;
            
            return true;
        }
        
        return false;
    }*/
    
    public void desativarJogadorMesa(Set<Id> jogSetId) {
        List<JogadorMesa__c> jMesaList = [
            SELECT Id, Mesa__c, Jogador__c, DataAtivacao__c, Status__c
            FROM JogadorMesa__c
            WHERE Status__c in('Ativo', 'Em Espera')  AND Jogador__c IN: jogSetId
            ORDER BY DataAtivacao__c DESC
        ];
        
        //jogador esta ativo ou na espera de alguma mesa?
        if(!jMesaList.isEmpty()) {    
            for(JogadorMesa__c j : jMesaList) {
                j.Status__c	 		 = 'Desativo';
            }
            UPDATE jMesaList;
        }
    }
    
    public void desativarJogadorMesa(Set<Id> jogSetId, Set<Id> menosSetId) {
        List<JogadorMesa__c> jMesaList = [
            SELECT Id, Mesa__c, Jogador__c, DataAtivacao__c, Status__c
            FROM JogadorMesa__c
            WHERE Status__c in('Ativo', 'Em Espera')  AND Jogador__c IN: jogSetId 
            AND Id NOT IN: menosSetId
            ORDER BY DataAtivacao__c DESC
        ];
        
        //jogador esta ativo ou na espera de alguma mesa?
        if(!jMesaList.isEmpty()) {    
            for(JogadorMesa__c j : jMesaList) {
                j.Status__c	 		 = 'Desativo';
            }
            UPDATE jMesaList;
        }
    }
    
    public void desativarJogadorMesa(Id jogId) {
        List<JogadorMesa__c> jMesaList = [
            SELECT Id, Mesa__c, Jogador__c, DataAtivacao__c, Status__c
            FROM JogadorMesa__c
            WHERE Status__c in('Ativo', 'Em Espera')  AND Jogador__c =: jogId
            ORDER BY DataAtivacao__c DESC
        ];
        
        //jogador esta ativo ou na espera de alguma mesa?
        if(!jMesaList.isEmpty()) {
            
            for(JogadorMesa__c j : jMesaList) {
                j.Status__c	 		 = 'Desativo';
                j.DataDesativacao__c = Datetime.now();
            }
            
            UPDATE jMesaList;
        }   
    }
    
    public void atualizarSessaoCaixa(Id sessaoCaixaId) {
        System.debug('Iniciando atulizacao da Sessao Caixa: ' + sessaoCaixaId);
        SessaoCaixa__c sessaoCaixa = [
            SELECT Id, ValorFundo__c, ValorTotalSacado__c,
            TotalFichasComprada__c, TotalFichasDevolvidas__c, TotalFichasCapile__c, TotalFichasRake__c,
            ValorPendentePagoDinheiro__c, ValorPendentePagoCartaoDebito__c, ValorPendentePagoCartaoCredito__c,
            ValorTotalEntradaDinheiro__c, ValorTotalEntradaCartaoDebito__c, ValorTotalEntradaCartaoCredito__c
            FROM SessaoCaixa__c
            WHERE Id =: sessaoCaixaId
        ];
        
        List<SessaoCash__c> sessaoJogList = [
            SELECT Id
            FROM SessaoCash__c
            WHERE SessaoCaixa__c =: sessaoCaixa.Id
        ];
        
        System.debug('Sessao Jogador: ' + sessaoJogList.size());
             
        calcPosicaoCaixa(sessaoCaixa, sessaoJogList);
        calcPosicaoCaixaFicha(sessaoCaixa, sessaoJogList);
        System.debug('Sessao Caixa: ' + sessaoCaixa);
        
        UPDATE sessaoCaixa;
    }
    
    private void calcPosicaoCaixaFicha(SessaoCaixa__c sessaoCaixa, List<SessaoCash__c> sessaoJogList) {
        sessaoCaixa.TotalFichaFaltando__c = 
            sessaoCaixa.TotalFichasComprada__c - 
            (sessaoCaixa.TotalFichasDevolvidas__c + 
             sessaoCaixa.TotalFichasCapile__c 	+
             sessaoCaixa.TotalFichasRake__c);
    }
    
    private void calcPosicaoCaixa(SessaoCaixa__c sessaoCaixa, List<SessaoCash__c> sessaoJogList) {
        sessaoCaixa.ValorTotalDinheiro__c = 
            (sessaoCaixa.ValorPendentePagoDinheiro__c + sessaoCaixa.ValorTotalEntradaDinheiro__c);
        
        sessaoCaixa.ValorTotalCartaoDebito__c = 
            sessaoCaixa.ValorPendentePagoCartaoDebito__c + sessaoCaixa.ValorTotalEntradaCartaoDebito__c;
        
        sessaoCaixa.ValorTotalCartaoCredito__c = 
            sessaoCaixa.ValorPendentePagoCartaoCredito__c + sessaoCaixa.ValorTotalEntradaCartaoCredito__c;
        
        sessaoCaixa.ValorTotalEspecie__c = 
            (sessaoCaixa.ValorFundo__c + sessaoCaixa.ValorTotalDinheiro__c) - sessaoCaixa.ValorTotalSacado__c;
    }
    
    public List<SelectOption> obterMesaOption() {
        List<Mesa__c> mesaList = [
            SELECT Id, Name, Titulo__c, Jogo__c
            FROM Mesa__c
            WHERE Status__c = 'Aberta'
        ];
        
        List<SelectOption> selectList = new List<SelectOption>();
        //selectList.add(new SelectOption('', '--Nenhuma--'));
        for(Mesa__c mesa : mesaList) {
            String label = '[' + mesa.Name + ']' + mesa.Titulo__c.toUpperCase() + ', ' + mesa.Jogo__c;
            selectList.add(new SelectOption(mesa.Id, label));
        }
        
        /*if(mesaList.isEmpty()) {
            selectList.add(new SelectOption('', '--Nenhuma--'));
        }*/
        return selectList;
    }
    
    public List<DealerSessao__c> obterSessoesDealerAberta(SessaoCaixa__c sessaoCaixa) {
        return [
            SELECT Id, Name, Dealer__r.FirstName, Dealer__r.LastName, Dealer__r.Account.Conta__c, 
            CreatedBy.Name, CreatedDate, Status__c
            
            FROM DealerSessao__c
            WHERE SessaoCaixa__c =: sessaoCaixa.Id AND Status__c = 'Ativo'
            ORDER BY CreatedDate DESC LIMIT 20
        ];
    }
    
    public Decimal calcTaxa(Account accClube, String pagamento, Decimal valor) {
        if(accClube == null) {
            throw new UtilApex.UtilApexException('Nao foi possível encontrar a conta do Clube');
        }
        if(pagamento == 'Cartão/Débito') {
            if(accClube.TaxaCartaoDebito__c != null && accClube.TaxaCartaoDebito__c > 0) {
                valor += valor * (accClube.TaxaCartaoDebito__c/100);
            }
        } else if(pagamento == 'Cartão/Crédito') {
            if(accClube.TaxaCartaoCredito__c != null && accClube.TaxaCartaoCredito__c > 0) {
                valor += valor * (accClube.TaxaCartaoCredito__c/100);
            }   
        }
        return valor;
    }
    
    public Decimal calcTaxa(String formaPagamento, Decimal valor) {
        
        Account accClube = obterClube(UserInfo.getUserId());
        
        if(accClube == null) {
            throw new UtilApex.UtilApexException('Nao foi possível encontrar a conta do Clube');
        }
        
        accClube = [
            SELECT Id, TaxaCartaoDebito__c, TaxaCartaoCredito__c
            FROM Account
            WHERE Id =: accClube.Id
        ];
        
        if(formaPagamento == 'Cartão/Débito') {
            if(accClube.TaxaCartaoDebito__c != null && accClube.TaxaCartaoDebito__c > 0) {
                valor += valor * (accClube.TaxaCartaoDebito__c/100);
            }
            
        } else if(formaPagamento == 'Cartão/Crédito') {
            if(accClube.TaxaCartaoCredito__c != null && accClube.TaxaCartaoCredito__c > 0) {
                valor += valor * (accClube.TaxaCartaoCredito__c/100);
            }
            
        }
        
        return valor;
    }
    
    public QueueSObject obterFilaClube(Id userId) {
        System.debug('Obtendo fila de sessoes caixa do clube.');
        Account accClube = obterClube(userId);
        
        System.debug('Acc Clube: ' + accClube);
        
        if(accClube == null) {
            return null;
        }
        
        List<QueueSObject> queue = [
            SELECT QueueId FROM QueueSObject 
            WHERE SobjectType = 'SessaoCaixa__c' 
            AND Queue.Name =: accClube.Name LIMIT 1
        ];
        
        if(queue.isEmpty()) {
            return null;
        }
        
        return queue.get(0);
    }
}