public with sharing class JogadorMesaController extends AbstractCashController {
    
    private static String ATIVO = 'Ativo';
    private static String EMESPERA = 'Em Espera';
    
    public String status 	{ get;set; }
    public String mesaId 	{ get;set; }
    public Contact jogador	{ get;set; }
    
    public JogadorMesa__c jogadorMesa { get;set; }
    public List<JogadorMesa__c> jogadorMesaList { get;set; }
    
    public boolean btnAtivo		{ get;set; }
    public boolean compraFicha  { get;set; }
    public Mesa__c mesa 		{ get;set; }
    
    public List<SelectOption> tipoSelectOption {
        get {
            List<SelectOption> seleList = new List<SelectOption>();
            seleList.add(new SelectOption(ATIVO, 'Jogador Mesa'));
            seleList.add(new SelectOption(EMESPERA, 'Fila Espera'));
            return seleList;
        }
    }
    
    public JogadorMesaController() { }
    
    protected override void init() {
        this.btnAtivo	= false;
        this.jogadorMesaList = new List<JogadorMesa__c>();
        this.status = ATIVO;
        this.compraFicha = true;
        
        if(sessaoCaixa == null) {
            return;
        }
        
        String jId = Apexpages.currentPage().getParameters().get('Id');
        if(!String.isEmpty(jId)) {
            this.jogador = [
                SELECT Id, FirstName, LastName, Email
                FROM Contact
                WHERE Id=: jId AND RecordTypeId =: UtilApex.getRecordTypeId('Contact', 'Jogador')
            ];
            
            this.jogadorMesa = new JogadorMesa__c();
            this.jogadorMesa.Jogador__c = jId;
        }
        
        this.status = ATIVO; 
        String paramStatus = Apexpages.currentPage().getParameters().get('status');
        if(!String.isEmpty(paramStatus)) {
            if(paramStatus.toLowerCase() == 'ativo') {
                this.status = ATIVO;  
            
            } else if(paramStatus.toLowerCase() == 'em espera') {
                this.status = EMESPERA;  
            }
        }
        
        if(!mesaSelectOption.isEmpty()) {
            this.mesaId = mesaSelectOption.get(0).getValue();
            
            String paramMesaId = Apexpages.currentPage().getParameters().get('mesa');
            if(!String.isEmpty(paramMesaId)) {
                this.mesaId = paramMesaId;
            }
            selectMesa();
        }
    }
    
    public PageReference add() {
        try {
            jogadorMesa.Mesa__c = mesaId;
            jogadorMesa.Status__c = status;
            
            ClubeServico.getServico().addJogador(jogadorMesa);
            
        } catch(Exception ex) {
            System.debug('Ex: ' + ex);
            
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Ex: ' + ex.getMessage()));
            
            return null;
        }
        
        PageReference pageRef = new PageReference(
            '/apex/MesaFila?sfdc.tabName=01r61000000hp0L&mesa=' + mesaId + '&status=' + status);
        
        if(compraFicha && status.equals(ATIVO)) {
            pageRef = Page.JogadorCompraFicha;
            pageRef.getParameters().put('sfdc.tabName', '01r61000000ho8J');
            pageRef.getParameters().put('Id', jogadorMesa.Id);
            //pageRef = new PageReference(
            //    '/apex/JogadorCompraFicha?sfdc.tabName=01r61000000ho8J&Id=' + jogadorMesa.Id);
        }
        
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference selectMesa() {
        if(String.isEmpty(mesaId)) {
            this.mesa = null;
            btnAtivo = false;
            this.jogadorMesaList = new List<JogadorMesa__c>();
            return null;
        }
        
        List<Mesa__c> mesaList = [
            SELECT Id, Name, Jogo__c, Titulo__c, TotalVagas__c,
            ValorFrente__c, Observacoes__c
            FROM Mesa__c
            WHERE Id =: mesaId
        ];
        
        if(!mesaList.isEmpty()) {
            this.mesa = mesaList.get(0);
        }
        
        Boolean vaga = ClubeServico.getServico().isVagaMesa(mesaId);
        btnAtivo = true;
        
        //if(jogadorMesa != null) {
        if(status == 'Em Espera' && vaga) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.WARNING, 'Existe vaga na mesa.')); 
            
        } else if(status == 'Ativo' && !vaga) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.WARNING, 'Não existe vaga na mesa.')); 
            btnAtivo = false;
        }    
        //}
        
        jogadorMesaList = [
            SELECT Id, Jogador__c, CreatedDate, Status__c, DataAtivacao__c, Mesa__c
            FROM JogadorMesa__c
            WHERE Status__c =: status  AND Mesa__c =: mesaId
            ORDER BY CreatedDate ASC
        ];
        
        for(JogadorMesa__c jM : jogadorMesaList) {
            if(jogadorMesa != null && jogadorMesa.Jogador__c == jM.Jogador__c) {
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.WARNING, 'Jogador já encontra-se na mesa.'));
                btnAtivo = false;
            }
        }
        
        return null;
    }
    
    public PageReference actionJogador() {
        String jMesaId = Apexpages.currentPage().getParameters().get('Id');
        String action = Apexpages.currentPage().getParameters().get('action');
       
        if(String.isEmpty(action)) {
            throw new UtilApex.UtilApexException('Acao nao encontrada');
        }
        if(String.isEmpty(jMesaId)) {
            throw new UtilApex.UtilApexException('Identificador nao encontrado');
        }
        
        List<JogadorMesa__c> jMList = [
            SELECT Id, Mesa__c, Status__c, DataDesativacao__c
            FROM JogadorMesa__c
            WHERE Id =: jMesaId
        ];
        
        try {
            if(!jMList.isEmpty()) {
                String newStatus = (action == '0') ? 'Desativo' : 'Ativo';

                JogadorMesa__c jm = jMList.get(0);
                jm.Status__c 	= newStatus;
                
                Boolean vaga = ClubeServico.getServico().isVagaMesa(mesaId);
                if(jm.Status__c == 'Ativo' && !vaga) {
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.WARNING, 'Não existe vaga na mesa.')); 
                   return null;
                }    
                
                UPDATE jMList;
            }
            
        } catch(Exception ex) {
            System.debug('Ex: ' + ex);
            
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Ex: ' + ex.getMessage()));
            
            return null;
        }
        
        PageReference pageRef = new PageReference(
            '/apex/MesaFila?sfdc.tabName=01r610000002O2U&mesa=' + mesaId + '&status=' + status);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    protected override String getUrl() {
        String chave = obterChaveContato(jogador);
        return '/apex/Jogador?sfdc.tabName=01r61000000ho8J&chave=' + chave;
    }
}