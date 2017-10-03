public with sharing class JogadorFicha2Controller extends AbstractCashController {
    
    public JogadorMesa__c jogadorMesa 	{ get;set; }
    public CompraFicha__c compraFicha	{ get;set; }
    private SessaoCash__c sessaoJogador { get;set; }
    
    public JogadorFicha2Controller() {}
    
    protected override void init() {
        
        if(sessaoCaixa == null) {
            return;
        }
        
        String jogMesaId = Apexpages.currentPage().getParameters().get('Id');
        if(!String.isEmpty(jogMesaId)) {
            List<JogadorMesa__c> jogadorMesaList = [
                SELECT Id, Mesa__c, SessaoJogador__c, DataAtivacao__c,
                Jogador__c, Jogador__r.FirstName, Jogador__r.LastName, Status__c
                FROM JogadorMesa__c
                WHERE Id =: jogMesaId AND Status__c = 'Ativo' AND Mesa__r.SessaoCaixa__c =: sessaoCaixa.Id
            ];
            
            if(!jogadorMesaList.isEmpty()) {
                jogadorMesa = jogadorMesaList.get(0);
                
                this.sessaoJogador = 
                    ClubeServico.getServico().criarSessao(new Contact(Id=jogadorMesa.Jogador__c));
            }
        }
        
        String paramJogadorId = Apexpages.currentPage().getParameters().get('jogId');
        if(!String.isEmpty(paramJogadorId)) {
            List<JogadorMesa__c> jogadorMesaList = [
                SELECT Id, Mesa__c, SessaoJogador__c, DataAtivacao__c,
                Jogador__c, Jogador__r.FirstName, Jogador__r.LastName, Status__c
                FROM JogadorMesa__c
                WHERE Status__c IN ('Ativo', 'Em Espera') AND Jogador__c =: paramJogadorId
                ORDER BY DataAtivacao__c DESC
            ];
            
            if(!jogadorMesaList.isEmpty()) {
                jogadorMesa = jogadorMesaList.get(0);
                
                this.sessaoJogador = 
                    ClubeServico.getServico().criarSessao(new Contact(Id=jogadorMesa.Jogador__c));
            
                if(jogadorMesa.Status__c == 'Em Espera') {
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.INFO, 'O jogador não está ativo'));
                }
            }
        }
        
        this.compraFicha = new CompraFicha__c();
        if(jogadorMesa != null) {
            this.compraFicha.Mesa__c = jogadorMesa.Mesa__c;
            this.compraFicha.Cliente__c 	= jogadorMesa.Jogador__c;
        }       
        this.compraFicha.Fichas__c 		= 0;
        this.compraFicha.Valor_Total__c = 0;
        
    }
    
    public PageReference atualizarValores() {
        
        if(compraFicha.Fichas__c <= 0) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Fichas: É necessário inserir um valor válido.'));
            return null;
        }
        
        System.debug('sessao jogador:' + sessaoJogador);
        if(sessaoJogador.CobrarTaxa__c) { 
            this.compraFicha.Valor_Total__c = 
                ClubeServico.getServico().calcTaxa(compraFicha.FormaPagamento__c, compraFicha.Fichas__c);
        }
        
        return null;
    }
    
    public PageReference finalizar() {
        if(compraFicha.Fichas__c <= 0) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Fichas: É necessário inserir o valor.'));
            return null;
        }
        
        //Desfazer o calculo, caso necessario a trigger fara o calc novamente.
        this.compraFicha.Valor_Total__c = compraFicha.Fichas__c;
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            System.debug('Compra Ficha: ' + compraFicha);
            INSERT compraFicha;
            
        } catch(Exception ex) {
            Database.rollback(sp);
            
            System.debug('Ex: ' + ex);
            
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Ex: ' + ex.getMessage()));
            
            return null;
        }
        
        PageReference pageRef = new PageReference('/apex/Jogador?sfdc.tabName=01r61000000ho8J');
        return pageRef;
    }
    
    protected override String getUrl() {
        return '/apex/Jogador?sfdc.tabName=01r61000000ho8J';
    }
    
}