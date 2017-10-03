public with sharing class CaixaController extends AbstractCashController {
    
    public List<SessaoCash__c> sessaoList 			{ get;set; }
    public List<DealerSessao__c> dealerSessaoList 	{ get;set; }
    public List<SessaoCash__c> jogSessaoList 		{ get;set; }
    public List<Mesa__c> mesaList 					{ get;set; }
    public CaixaController() { }
    
    public override void init() {
        System.debug('Init()');
        
        this.sessaoList 		= new List<SessaoCash__c>();
        this.dealerSessaoList 	= new List<DealerSessao__c>();
        this.jogSessaoList 		= new List<SessaoCash__c>();
        this.mesaList			= new List<Mesa__c>();
        
        if(sessaoCaixa == null) {
            return;  
        }
        
        dealerSessaoList = ClubeServico.getServico().obterSessoesDealerAberta(sessaoCaixa);
        
        System.debug('dealerSessaoList: ' + dealerSessaoList);
        
        jogSessaoList = [
            SELECT Id, Name, 
            Cliente__c, Cliente__r.FirstName, Cliente__r.LastName, Cliente__r.Account.Conta__c,
            CreatedBy.Name, CreatedDate, Status__c
            
            FROM SessaoCash__c
            WHERE SessaoCaixa__c =: sessaoCaixa.Id AND Status__c = 'Aberta'
            ORDER BY CreatedDate DESC LIMIT 20
        ];
        
        System.debug('jogSessaoList: ' + jogSessaoList);
        
        mesaList = [
            SELECT Id, Name, Jogo__c, Titulo__c, 
            CreatedBy.Name, CreatedDate, Status__c
            FROM Mesa__c
            WHERE SessaoCaixa__c =: sessaoCaixa.Id AND Status__c = 'Aberta'
            ORDER BY CreatedDate DESC
        ];
    }
    
    public override PageReference buscar() {
        
        if(String.isEmpty(textoChave) || sessaoCaixa == null) {
            return null;
        }
        
        textoChave = textoChave.trim();
        
        Id sId = sessaoCaixa.Id;
        
        sessaoList = Database.query(
            'SELECT Id, Name, Cliente__c, Cliente__r.FirstName, Cliente__r.LastName, Cliente__r.Account.Conta__c,'
            + 'CreatedBy.Name, CreatedDate, Status__c ' 	+ 
            'FROM SessaoCash__c ' 			+ 
            'WHERE Status__c = \'Aberta\' ' +
            (String.isNotBlank( textoChave ) ? 'AND (Cliente__r.FirstName LIKE \'%' + textoChave + 
             '%\' OR Cliente__r.LastName LIKE \'%' 		+ textoChave +  
             '%\' OR Cliente__r.Account.Conta__c LIKE \'%' + textoChave + 
             '%\')' : '') + ' AND SessaoCaixa__c =: sId ' + 
            ' ORDER BY Cliente__r.FirstName ASC LIMIT 100'
        );
        
        return null;
    }
}