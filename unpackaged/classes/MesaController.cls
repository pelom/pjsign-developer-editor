public with sharing class MesaController extends AbstractCashController {

    public String mesaId 	{ get;set; }
    
    public Mesa__c mesa 	{ get;set; }
    
    public Boolean efetuarFechamento { get;set; }
    
    public List<JogadorMesa__c> jMesaList { get; set; }
    
    public MesaController(ApexPages.StandardController controller) {
        mesaId = controller.getId();
        efetuarFechamento = false;
    }
    
    public PageReference fechamentoMesa() {
        
        if(String.isEmpty(mesaId)) {
            throw new UtilApex.UtilApexException('É necessario uma mesa.'); 
        }
        
        mesa = [
            SELECT Id, Status__c, ValorRake__c, Name, SessaoCaixa__c
            FROM Mesa__c
            WHERE Id =: mesaId
        ];
        
        if(mesa == null) {
            throw new UtilApex.UtilApexException('É necessario uma mesa.'); 
            
        } else if(mesa.Status__c != 'Aberta') {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'A Mesa não está Aberta'));
            
            return null;
        }
        
        jMesaList = [
            SELECT Id, Jogador__c, SessaoJogador__c, CreatedDate, Status__c, DataAtivacao__c, Mesa__c
            FROM JogadorMesa__c
            WHERE Status__c = 'Ativo'  AND Mesa__c =: mesa.Id
            ORDER BY CreatedDate DESC
        ];
        
        if(!jMesaList.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Não é possível efetuar o fechamento, existe(m) jogador(es) ativo(s) na(s) mesa(s).'));
            
            return null;
        }
        
        efetuarFechamento = true;
        
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.WARNING, 'Por favor informe o valor do Rake e confirme a operação.'));
        
        return null;
    }
    
    public PageReference efetuarFechamento() {
        
        if(mesa.ValorRake__c == null || mesa.ValorRake__c <= 0) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Por favor informe: valor do Rake.'));
            
            return null;
        }
        
        mesa.Status__c = 'Fechada';
        mesa.DataFechamento__c = Datetime.now();
        
        UPDATE mesa;
        //ClubeServico.getServico().atualizarMesa(mesa);
        
        PageReference page = new PageReference('/' + mesa.Id);
        return page;
    }
}