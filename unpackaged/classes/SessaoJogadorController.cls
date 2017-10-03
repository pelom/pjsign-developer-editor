public with sharing class SessaoJogadorController extends AbstractCashController {
    
    public String sessaoJogadorId 		{ get;set; }
    public SessaoCash__c sessaoJogador 	{ get;set; }
    
    public List<CompraFicha__c> compraList	{ get;set; }
    
    public Contact jogador 					{ get;set; }
    public Account accClube					{ get;set; }
    public Boolean btnAtivo					{ get;set; }
    
    public SessaoJogadorController() { 
    	sessaoJogadorId = Apexpages.currentPage().getParameters().get('Id'); 
    }
    
    protected override void init() {    
        
        if(sessaoCaixa == null) {
            return;
        }
        
        String sessaoId = Apexpages.currentPage().getParameters().get('Id'); 
        
        if(!atualizarValorSessao(sessaoId)) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Não foi possível encontrar a sessão do cliente'));
            return;
        }
       
        jogador = new Contact(Id=sessaoJogador.Cliente__c);
        jogador.LastName = sessaoJogador.Cliente__r.LastName;
        jogador.FirstName = sessaoJogador.Cliente__r.FirstName;
        
        compraList = [
            SELECT Id, Name, Status__c, Fichas__c, Valor_Total__c,  
            Mesa__c, CreatedDate, CreatedBy.Name, FormaPagamento__c
            FROM CompraFicha__c
            WHERE SessaoCash__c =: sessaoJogador.Id
            ORDER BY CreatedDate DESC
        ];
        
        accClube = ClubeServico.getServico().obterClube(UserInfo.getUserId());
        
        atualizarValores();
    }
    
    private Boolean atualizarValorSessao(String sessaoId) {
        List<SessaoCash__c> sessaoJogadorList = [
            SELECT Id, Name, CreatedDate, FormaPagamento__c, Status__c,
            Cliente__c, Cliente__r.FirstName, Cliente__r.LastName, 
            CobrarTaxa__c,
            FichaDevolvida__c, TotalFichas__c, TotalFichasPendente__c, 
            ValorCompra__c, ValorTotalPago__c, ValorTotalPendente__c, ValorTotal__c
            
            FROM SessaoCash__c
            WHERE Id =: sessaoId AND Status__c = 'Aberta' AND SessaoCaixa__c =: sessaoCaixa.Id
        ];
        
        if(sessaoJogadorList.isEmpty()) {
            return false;
        }
        
        sessaoJogador = sessaoJogadorList.get(0);
        
        return true;
    }
    
    public PageReference atualizarValores() {
        this.btnAtivo = true;
        if(sessaoJogador.FichaDevolvida__c == null || sessaoJogador.FichaDevolvida__c < 0) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Fichas Devolvidas: É necessário informa um valor válido.'));
            return null;
        }
        
        sessaoJogador.ValorTotal__c = 
            sessaoJogador.FichaDevolvida__c - sessaoJogador.TotalFichasPendente__c;
        
        if(sessaoJogador.ValorTotal__c < 0) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'O CLIENTE ESTÁ COM O SALDO NEGATIVO: É necessário realizar a cobrança.'));
            
            if(sessaoJogador.CobrarTaxa__c) { 
                sessaoJogador.ValorTotal__c = 
                    ClubeServico.getServico().calcTaxa(sessaoJogador.FormaPagamento__c, sessaoJogador.ValorTotal__c);
            }
            
            
        } else if(sessaoJogador.ValorTotal__c > 0) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.CONFIRM, 'O CLIENTE ESTÁ COM O SALDO POSITIVO: É necessário realizar o pagamento.'));
            
            sessaoJogador.FormaPagamento__c  = 'Dinheiro';
            btnAtivo = false;
                
        } else {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.INFO, 'O CLIENTE ESTÁ COM O SALDO ZERADO:É necessário receber as fichas.'));   
            
        }
        
        return null;
    }
    
    public PageReference salvar() {
        
        if(sessaoJogador.FichaDevolvida__c == null || sessaoJogador.FichaDevolvida__c < 0) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Fichas Devolvidas: É necessário informa um valor válido.'));
            return null;
        }
        
        if(sessaoJogador.ValorTotal__c < 0 && String.isEmpty(sessaoJogador.FormaPagamento__c)) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Forma Pagamento: É necessário informa um valor.'));
            return null;
            
        } else if(sessaoJogador.ValorTotal__c > 0) {
            sessaoJogador.FormaPagamento__c  = 'Dinheiro';
        
        }
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            ClubeServico.getServico().desativarJogadorMesa(sessaoJogador.Cliente__c);
            
            sessaoJogador.DataFechamento__c = Datetime.now();
            sessaoJogador.UsuarioFechamento__c = UserInfo.getUserId();
            sessaoJogador.Status__c		 = 'Fechada';
            
            System.debug('Sessao: ' + sessaoJogador);
            
            UPDATE sessaoJogador;
            
            
            
        } catch(Exception ex) {
            Database.rollback(sp);
            System.debug('Ex: ' + ex);
            
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Ex: ' + ex.getMessage()));
            
            return null;
        }
        
        PageReference pageRef = new PageReference('/apex/Caixa?sfdc.tabName=01r61000000hoRV');
        return pageRef;
    }
    
    protected override String getUrl() {
        String chave = obterChaveContato(jogador);
        return '/apex/Caixa?sfdc.tabName=01r61000000hoRV&chave=' + chave;
    }
}