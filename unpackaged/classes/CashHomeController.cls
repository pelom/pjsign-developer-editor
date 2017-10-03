public with sharing class CashHomeController extends AbstractCashController {
    
    public List<MesaView> mesaList 			 		{ get;set; }
    
    public List<SessaoJogadorView> sessaoJogadorList 	{ get;set; }
    public SessaoCaixa__c sessaoCaixaView 		{ get;set; }
    public String sessaoCaixaSelect 			{ get;set; }
    public List<SelectOption> sessaoCaixaOption { get;set; }
    public List<DealerSessao__c> dealerSessaoList { get;set; }
        
    public CashHomeController() {
        
        this.sessaoCaixaOption = new List<SelectOption>();
        if(sessaoCaixa != null) {
            sessaoCaixaOption.add(new SelectOption(sessaoCaixa.Id, formatCombo(sessaoCaixa)));
        }
        List<SessaoCaixa__c> sessaoCaixaList = [
            SELECT Id, Name, CreatedDate
            FROM SessaoCaixa__c
            WHERE CreatedDate = THIS_MONTH AND Status__c = 'Fechada'
            ORDER BY CreatedDate DESC
        ];
        
        for(SessaoCaixa__c sc : sessaoCaixaList ) {
            sessaoCaixaOption.add(new SelectOption(sc.Id, formatCombo(sc)));
        }
        if(!sessaoCaixaOption.isEmpty()) {
            this.sessaoCaixaSelect = (sessaoCaixa == null)  ? sessaoCaixaList.get(0).Id : sessaoCaixa.Id;
            loadData();
        }
        
    }
    
    private String formatCombo(SessaoCaixa__c sc) {
        Map<String, String> mapaSemana = UtilApex.mapaSemana;
        DateTime dt = DateTime.now();
        String semana = mapaSemana.get(sc.CreatedDate.format('EEEE'));
        String formattedDt = '[' + sc.Name + '] ' + sc.CreatedDate.format(' dd/MM/yyyy') + ' - '+ semana.toUpperCase() ;
        return formattedDt;
    }
    
    public PageReference atualizarCaixa() {
        if(sessaoCaixa != null) {
            ClubeServico.getServico().atualizarSessaoCaixa(sessaoCaixa.Id);       
        }
        return null;
    }
    
    protected override void init() { 
        //this.mesaSelect = new Mesa__c();
        this.mesaList 		= new List<MesaView>();
        this.sessaoJogadorList = new List<SessaoJogadorView>();
        this.dealerSessaoList = new List<DealerSessao__c>();
        
        //this.jogSessaoList 	= new List<SessaoCash__c>();
        //this.dealerMesaList 	= new List<DealerMesa__c>();
        
        if(sessaoCaixa == null) {
            return;
        }
        
        loadSessaoCaixa('' + sessaoCaixa.Id);
        
        /*this.sessaoCaixa = [
            SELECT Id, Name, CreatedDate,
            ValorTotalEspecie__c, ValorTotalSacado__c, ValorPendente__c
            FROM sessaoCaixa__c
            WHERE ID =: sessaoCaixa.Id
        ];*/
        
        /*this.mesaList = [
            SELECT Id, Name, Titulo__c, Jogo__c, TotalFichasCompradas__c
            FROM Mesa__c
            WHERE SessaoCaixa__c =: sessaoCaixa.Id AND Status__c = 'Aberta'
            ORDER BY CreatedDate DESC
        ];
        */
        //if(!this.mesaList.isEmpty()) {
        //    carregarJogadores(mesaList.get(0).Id);
        //}        
    }
    
    /*public PageReference carregarJogadores() {
        String mesaId = Apexpages.currentPage().getParameters().get('mesaId');
        
        if(!String.isEmpty(mesaId)) {
           carregarJogadores(mesaId);
        }
        
        return null;
    }
    
    private void carregarJogadores(String mesaId) {
        
        mesaSelect = [
            SELECT Id, Name
            FROM Mesa__c
            WHERE Id =: mesaId
        ].get(0);
      
        List<JogadorMesa__c> jogMesaList = [
            SELECT  Id, Jogador__c
            FROM JogadorMesa__c
            WHERE Mesa__c =: mesaId //AND Status__c IN('Ativo')
        ];
        
        Set<Id> jogId = new Set<Id>();
        for(JogadorMesa__c jM : jogMesaList) {
            jogId.add(jM.Jogador__c);
        }
        
        jogSessaoList = [
            SELECT Id, Name, Cliente__c, Cliente__r.FirstName, Cliente__r.LastName, CreatedDate, Status__c,
            TotalFichasPendente__c, TotalFichas__c
            FROM SessaoCash__c
            WHERE Cliente__c IN: jogId AND Status__c = 'Aberta' AND SessaoCaixa__c =: sessaoCaixaSelect
            ORDER BY TotalFichas__c DESC
        ];
        
        dealerMesaList = [
            SELECT Id, Name, Dealer__c, Dealer__r.LastName, Dealer__r.FirstName, DataEntrada__c, DataSaida__c, ValorCapile__c
            FROM DealerMesa__c
            WHERE Mesa__c =: mesaId
            ORDER BY DataSaida__c DESC
        ];
    }*/
    
    public void loadSessaoCaixa(String sesId) {
        this.sessaoCaixa = [
            SELECT Id, Name, CreatedDate,
            ValorTotalEspecie__c, ValorTotalSacado__c, ValorPendente__c
            FROM sessaoCaixa__c
            WHERE ID =: sesId
        ];
    }
    
    public void loadData() {
        
        if(sessaoCaixaSelect == null) {
            return;
        }
        
        loadSessaoCaixa(sessaoCaixaSelect);
        
        SessaoCaixa__c sc = [
            SELECT Name
            FROM SessaoCaixa__c
            WHERE Id =: sessaoCaixaSelect
        ];   
        
        this.sessaoCaixaList = [
            SELECT Id, Name, CreatedDate, CreatedBy.Name, Status__c
            FROM SessaoCaixa__c
            WHERE ID =: sessaoCaixaSelect
        ];
        
        List<Mesa__c> mList = [
            SELECT Id, Name, Titulo__c, Jogo__c,
            TotalFichasCompradas__c, TotalFichasCapile__c, ValorRake__c, ValorTotalVenda__c
            FROM Mesa__c
            WHERE SessaoCaixa__c =: sc.Id
            ORDER BY CreatedDate DESC
        ];
        this.mesaList = new List<MesaView>();
        for(Mesa__c mesa : mList) {
            mesaList.add(new MesaView(mesa));
        }
        
        this.dealerSessaoList = [
            SELECT Id, Name, Dealer__c, Dealer__r.LastName, Dealer__r.FirstName,
            ValorTotalCapile__c, Status__c, DataEntrada__c, DataSaida__c
            FROM DealerSessao__c
            WHERE SessaoCaixa__c =: sc.Id
            ORDER BY DataSaida__c DESC
        ];
        
        List<SessaoCash__c> sJogadorList = [
            SELECT Id, Name, Cliente__c, Cliente__r.FirstName, Cliente__r.LastName, 
            DataInicioSessao__c, DataFechamento__c, Status__c, FormaPagamento__c,
            TotalFichasPendente__c, TotalFichas__c, FichaDevolvida__c
            FROM SessaoCash__c
            WHERE SessaoCaixa__c =: sc.Id
            ORDER BY TotalFichas__c DESC
        ];
        
        this.sessaoJogadorList = new List<SessaoJogadorView>();
        for(SessaoCash__c s : sJogadorList) {
            SessaoJogadorView sjView = new SessaoJogadorView(s);
            this.sessaoJogadorList.add(sjView);
        }
    }
    
    public class MesaView {
        public Mesa__c mesa { get;set; }
        public Decimal taxa { get;set; }
        
        public MesaView(Mesa__c mesa) {
            this.mesa = mesa;
            this.taxa = mesa.ValorTotalVenda__c - mesa.TotalFichasCompradas__c;
        }
    }
    
    public class SessaoJogadorView {
        public SessaoCash__c sCash { get;set; }
        public Integer totalHoras  		{ get;set; }
        public Decimal valor			{ get;set; }
        
        public SessaoJogadorView(SessaoCash__c sessaoCash) {
            this.sCash = sessaoCash;
            System.debug('sessaoCash:' + sessaoCash);
            if(sessaoCash.DataInicioSessao__c != null && sessaoCash.DataFechamento__c != null) {
                this.totalHoras = 
                    sessaoCash.DataInicioSessao__c.Date().daysBetween(sessaoCash.DataFechamento__c.Date());
            }
            
            if(sessaoCash.FichaDevolvida__c != null && sessaoCash.TotalFichas__c != null) {
                this.valor = sessaoCash.FichaDevolvida__c - sessaoCash.TotalFichas__c;
            }
        }
    }
}