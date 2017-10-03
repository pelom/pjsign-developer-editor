public with sharing class SessaoCaixaController extends AbstractCashController {

    public List<Mesa__c> mesaList 					{ get;set; }
    public List<SessaoCash__c> jogSessaoList 		{ get;set; }
    
    public String sessaoCaixaId { get;set; }
    public SessaoCaixaController(ApexPages.StandardController controller) {
        sessaoCaixaId = controller.getId();        
    }

    public PageReference atualizarSessao() {
        
        if(String.isEmpty(sessaoCaixaId)) {
            throw new UtilApex.UtilApexException('É necessario uma sesssão.'); 
        }
        
        ClubeServico.getServico().atualizarSessaoCaixa(sessaoCaixaId);
        
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.CONFIRM, 'Sessão Caixa atualizado com sucesso'));
        
        return null;
    }
    
    public PageReference fechamentoSessaoCaixa() {
        if(sessaoCaixaId == null) {
            throw new UtilApex.UtilApexException('É necessario uma sesssão.'); 
        }
        
        sessaoCaixa = [
            SELECT Id, Status__c, Name
            FROM SessaoCaixa__c
            WHERE Id =:sessaoCaixaId             
        ];
        
        if(sessaoCaixa == null) {
            throw new UtilApex.UtilApexException('É necessario uma sessão.'); 
            
        } else if(sessaoCaixa.Status__c != 'Aberta') {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'A sessão não está Aberta'));
            
            return null;
        }
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            verificarDependencias();
            
            if(!mesaList.isEmpty() || !jogSessaoList.isEmpty()) { 
                return null;
            }
            
            desativarSessaoDealer();
            
            sessaoCaixa.DataFechamento__c 	= Datetime.now();
            sessaoCaixa.Status__c 			= 'Fechada';
            
            UPDATE sessaoCaixa;
            
            atualizarSessao();
            
        } catch(Exception ex) {
            Database.rollback(sp);
            
            System.debug('Ex: ' + ex);
            
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Ex: ' + ex.getMessage()));
            
            return null;
        }
        
        PageReference page = new PageReference('/' + sessaoCaixaId);
        return page;
    }
    
    private void desativarSessaoDealer() {
        List<DealerSessao__c> dealerSessaoList = [
            SELECT Id
            FROM DealerSessao__c
            WHERE SessaoCaixa__c =: sessaoCaixa.Id AND Status__c = 'Ativo'
        ];
        
        for(DealerSessao__c dSe : dealerSessaoList) {
            dSe.Status__c = 'Desativo';
        }
        
        UPDATE dealerSessaoList;
    }
    
    private void verificarDependencias() {
        mesaList = [
            SELECT Id, Name, Titulo__c, Status__c, Jogo__c, CreatedDate
            FROM Mesa__c
            WHERE SessaoCaixa__c =: sessaoCaixa.Id AND Status__c = 'Aberta'
        ];
        
        jogSessaoList = [
            SELECT Id, Name, Cliente__c, Cliente__r.FirstName, Cliente__r.LastName, CreatedDate, Status__c
            FROM SessaoCash__c
            WHERE SessaoCaixa__c =: sessaoCaixa.Id AND Status__c = 'Aberta'
            ORDER BY CreatedDate DESC LIMIT 20
        ];
        
        if(!jogSessaoList.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Não é possível efetuar o fechamento, existem Sessões Jogador abertas.'));
        }
        
        if(!mesaList.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Não é possível efetuar o fechamento, existem Mesas abertas.'));
            
        }
    }
}