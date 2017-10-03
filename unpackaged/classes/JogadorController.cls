public with sharing class JogadorController extends AbstractCashController {

    public List<Contact> jogadorList 				{ get;set; }
    public List<SessaoCash__c> jogadorSessaoList 	{ get;set; }
    
    public List<JogadorMesa__c> jogadorMesaList 	{ get;set; }
    public List<Mesa__c> mesaList 					{ get;set; }
    
    public JogadorController() {}
    
    protected override void init() {
        this.jogadorMesaList 	= new List<JogadorMesa__c>();
        this.jogadorSessaoList 	= new List<SessaoCash__c>();
		this.jogadorList 		= new List<Contact>();
        this.mesaList			= new List<Mesa__c>();
        
        if(sessaoCaixa != null) {
            jogadorSessaoList = [
                SELECT Id, Cliente__r.Id, Cliente__r.FirstName, Cliente__r.LastName,
                CreatedDate, Status__c, Name
                
                FROM SessaoCash__c
                WHERE Status__c = 'Aberta' AND SessaoCaixa__c =: sessaoCaixa.Id
                ORDER BY CreatedDate DESC LIMIT 100
            ];
        
            jogadorMesaList = [
                SELECT Id, Jogador__r.Id, Jogador__r.FirstName, Jogador__r.LastName,
                DataAtivacao__c, Mesa__r.Name, Mesa__r.Titulo__c, Mesa__r.Jogo__c, 
                CreatedBy.Name, CreatedDate, Status__c
                FROM JogadorMesa__c
                WHERE Status__c = 'Ativo' AND Mesa__r.SessaoCaixa__c =: sessaoCaixa.Id
                ORDER BY DataAtivacao__c DESC LIMIT 100
            ];
            
            mesaList = [
                SELECT Id, Name, Jogo__c, Titulo__c, 
                CreatedBy.Name, CreatedDate, Status__c
                FROM Mesa__c
                WHERE SessaoCaixa__c =: sessaoCaixa.Id AND Status__c = 'Aberta'
                ORDER BY CreatedDate DESC
            ];
            
        }
    }
    
    public override PageReference buscar() {
        
        if(String.isEmpty(textoChave)) {
            return null;
        }
        
        textoChave = textoChave.trim();
        
        jogadorList = Database.query(
            'SELECT Id, FirstName, LastName, MobilePhone, Email, Account.CPF__c, Account.Conta__c ' 	+ 
            'FROM Contact ' + 
            'WHERE RecordTypeId = \'' + UtilApex.getRecordTypeId('Contact', 'Jogador') + '\'' 				+
            //'WHERE AccountId != null AND Account.RecordTypeId = \'' + UtilApex.getRecordTypeId('Account', 'Jogador') + '\'' 				+
            (String.isNotBlank( textoChave ) ? ' AND (FirstName LIKE \'%' + textoChave + 
             '%\' OR LastName LIKE \'%' 		+ textoChave + 
             '%\' OR Email LIKE \'%' 			+ textoChave +
             //'%\' OR Account.Conta__c LIKE \'%' + textoChave + 
             '%\')' : '') +
            ' ORDER BY LastName ASC LIMIT 100'
        );
        
        return null;
    }
}