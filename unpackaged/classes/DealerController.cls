public with sharing class DealerController extends AbstractCashController {

    public List<DealerSessao__c> dealerSessaoList { get;set; }
    
    public List<Contact> dealerList 	{ get;set; }
    public DealerSessao__c dSessao		{ get;set; }
    
    public DealerMesa__c dMesa 	{ get;set; }
    public Contact dealer 		{ get;set; }
    
    public DealerController() { }
    
    protected override void init() {        
        this.dealerSessaoList = new List<DealerSessao__c>();
        
        if(sessaoCaixa == null) {
            return;
        }
        
        dealerSessaoList = ClubeServico.getServico().obterSessoesDealerAberta(sessaoCaixa);
        
        String dId = Apexpages.currentPage().getParameters().get('Id');
        if(!String.isEmpty(dId)) { //adicionar dealer na mesa
            
            List<Contact> dealerList = [SELECT Id, LastName, FirstName FROM Contact WHERE Id =: dId];
            if(dealerList.isEmpty()) {
                return;
            } else {
                dealer = dealerList.get(0);
                
            }
            
            List<DealerSessao__c> dSessaoList = [
                SELECT Id, Dealer__c, Dealer__r.FirstName, Dealer__r.LastName
                FROM DealerSessao__c
                
                WHERE Dealer__c=: dId AND Dealer__r.RecordTypeId =: UtilApex.getRecordTypeId('Contact', 'Dealer') 
                AND SessaoCaixa__c =: sessaoCaixa.Id AND Status__c = 'Ativo'
            ];
            
            if(dSessaoList.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.WARNING, 'O dealer não está ativo para registro em mesa'));
                //throw new UtilApex.UtilApexException('Sessão Dealer não encontrado');
                return;
            }
            
            dSessao = dSessaoList.get(0);
            
            dMesa = new DealerMesa__c();
            dMesa.DealerSessao__c = dSessao.Id;
            dMesa.Dealer__c = dSessao.Dealer__c;
            dMesa.ValorCapile__c = 0;
            dMesa.DataSaida__c = Datetime.now();
        }
    }
    
    public override PageReference buscar() {
        
        if(!String.isEmpty(textoChave)) {
            textoChave = textoChave.trim();
        }
        
        dealerList = Database.query(
            'SELECT Id, FirstName, LastName, MobilePhone, Email, Account.CPF__c ' 	+ 
            'FROM Contact ' 					+ 
            'WHERE RecordTypeId = \'' + UtilApex.getRecordTypeId('Contact', 'Dealer') + '\'' 	+
            (String.isNotBlank( textoChave ) ? 'AND (FirstName LIKE \'%' + textoChave + 
             '%\' OR LastName LIKE \'%' 		+ textoChave + 
             '%\' OR Email LIKE \'%' 			+ textoChave +
             '%\')' : '') +
            ' ORDER BY LastName ASC LIMIT 100'
        );
        
        return null;   
    }
    
    public PageReference addDealerMesa() {
        
        try {
            System.debug('Dealer Mesa: ' + dMesa);
            
            INSERT dMesa;
            
            //ClubeServico.getServico().atualizarSessaoDealer(dSessao);
            
        } catch(Exception ex) {
            System.debug('Ex: ' + ex);
            
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Ex: ' + ex.getMessage()));
            
            return null;
        }
        
        return cancelar();
    }
    
    protected override String getUrl() {
        String chave = obterChaveContato(dealer);
        return '/apex/Dealer?sfdc.tabName=01r61000000hot0&chave=' + chave;
    }
}