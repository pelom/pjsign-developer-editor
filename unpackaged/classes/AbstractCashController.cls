public abstract class AbstractCashController {
    
    //Sessao do caixa
    public SessaoCaixa__c sessaoCaixa 			{ get; set;}
    
    public List<SessaoCaixa__c> sessaoCaixaList 	{ get;set;}
    
    //Lista de mesa
    public List<SelectOption> mesaSelectOption 	{ get;set; }
    
    //Texto chave para efetuar pesquisar
    public String textoChave 					{ get;set; }

    public Account accClube 					{ get;set; }
    
    public String retUrl {
        get {
            String url = Apexpages.currentPage().getParameters().get('retUrl');
            
            if(url == null || String.isEmpty(url)) {
                return getUrl();
            }
            
            return url;
        }
    }
    
    public AbstractCashController() {
        
        this.mesaSelectOption 	= ClubeServico.getServico().obterMesaOption();
        this.sessaoCaixaList = new List<SessaoCaixa__c>();
        
        if(isCriarSessao()) {
            this.sessaoCaixa = ClubeServico.getServico().obterSessaoCaixa();
            
            if(sessaoCaixa == null) {
                sessaoNaoEncontrada();
                
            } else {
                this.accClube = ClubeServico.getServico().obterClube(UserInfo.getUserId());
                this.sessaoCaixaList = [
                    SELECT Id, Name, CreatedDate, CreatedBy.Name, Status__c
                    FROM SessaoCaixa__c
                    WHERE ID =: sessaoCaixa.Id
                ];
                sessaoEncontrada();
            }
        }
        
        init();
        
        String chave = Apexpages.currentPage().getParameters().get('chave');
        if(!String.isEmpty(chave)) {
            textoChave = chave;
            buscar();
            //textoChave = null;
        }
    }
    
    protected virtual Boolean isCriarSessao() {
        return true;
    }
    
    protected virtual void sessaoNaoEncontrada() {
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.WARNING, 'Não há Sessão de Caixa Aberta'));
        // throw new UtilApex.UtilApexException('Nenhum Sessão de Caixa Aberta');
    }
    
    protected virtual void sessaoEncontrada() {
    }
    
    protected virtual void init() {
    }
    
    public virtual PageReference buscar() {
        return null;
    }
    
    protected virtual String getUrl() {
        return '';
    }
    
    public PageReference cancelar() {
        PageReference pageRef = new PageReference(retUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    protected virtual String obterChaveContato(Contact ctt) {
        if(ctt == null) {
            return '';
        }
        
        String chave = ctt.LastName;
        
        if(!String.isEmpty(ctt.Email)) {
            chave = ctt.Email;
            
        }
        
        return chave;
    }
}