public class TorneioPainelController {
    
    public Boolean isHeader {
        get {
            String param = ApexPages.currentpage().getParameters().get('header');
            if(String.isEmpty(param)) {
                return false;
            }
            return true;
        }
    }
    
    public List<SelectOption> nivelOptionList {
        get {
            List<SelectOption> selectList = new List<SelectOption>();
            
            List<TorneioNivel__c> nivelList = [
                SELECT Id, Name, Nivel__c, ValorBig__c, ValorSmall__c
                FROM TorneioNivel__c
                WHERE TorneioEstrutura__c =: torneioEvento.Estrutura__c
                ORDER BY Nivel__c DESC
            ];
            
            for(TorneioNivel__c tn : nivelList) {
                selectList.add(new SelectOption(tn.Id, tn.Name));                
            }
            
            return selectList;
        }
    }
    
    private Id torneioEventoId 	{ get;set;}
    
    public TorneioEvento__c torneioEvento   { get;set; }
    //public TorneioEstrutura__c estrutra     { get;set; }
    public TorneioNivel__c torneioNivel	    { get;set; }
    public TorneioNivel__c torneioNivelProx { get;set; }
    
    public String nivel  		 { get;set; }
    public Integer tempoLevel	 { get;set; }
    public String tempoString 	 { get;set; }
    public String tempoIntervalo { get;set; }
    public Decimal mediaStack	 { get;set; }
    
    public Boolean isBtnIniciar {
        get {
            return (torneioEvento.Status__c == 'Parado' || torneioEvento.Status__c == 'Não Iniciado');
        }
    }
    
    public Boolean isBtnPausar {
        get {
            return (torneioEvento.Status__c == 'Em Andamento');
        }
    }
    
    public TorneioPainelController(ApexPages.StandardController stdController) {
        this.torneioEventoId = stdController.getId();
        
        initPainel();
    }
    
    public void inicializar() {
        if(torneioEvento.Nivel__c == null) {
            List<TorneioNivel__c> nivelList = [
                SELECT Id
                FROM TorneioNivel__c
                WHERE TorneioEstrutura__c =: torneioEvento.Estrutura__c
                ORDER BY Nivel__c ASC
                LIMIT 1
            ];
            
            if(!nivelList.isEmpty()) {
                torneioEvento.Nivel__c = nivelList.get(0).Id;      
                alterarNivel();
            }
        }
    }
    
    private void initPainel() {
        this.tempoLevel = 0;
        this.tempoString = '00:00:00';
        this.tempoIntervalo = '00:00:00';
        atualizarPainel();
    }
    
    private void atualizarPainel() {
        
        this.torneioEvento = [
            SELECT Id, Name, Estrutura__c, Nivel__c,
            TotalPlayers__c, TotalBuyIn__c, TotalRebuy__c, TotalAddOn__c, TotalFichas__c, TotalTimeChip__c, ValorArrecadado__c,
            Status__c, DataInicioLevel__c, TempoLevel__c, 
            Torneio__r.Titulo__c
            
            FROM TorneioEvento__c
            WHERE Id =: torneioEventoId
        ];
        
        /*this.estrutra = [
            SELECT Id, TempoBlinds__c
            FROM TorneioEstrutura__c
            WHERE Id =: this.torneioEvento.Estrutura__c
        ];*/
        
                
        Integer minutos = 0;

        if(torneioEvento.TempoLevel__c != null && 
           torneioEvento.DataInicioLevel__c != null) {
               this.tempoLevel = UtilApex.betweenSegunds(
                   torneioEvento.DataInicioLevel__c, torneioEvento.TempoLevel__c);
               
               Long ms = torneioEvento.TempoLevel__c.getTime() - 
                   torneioEvento.DataInicioLevel__c.getTime() ;
               tempoString = formatTempo(ms);
               minutos += (Integer) ((ms/1000)/60);
           }
        
        if(!String.isEmpty(torneioEvento.Nivel__c)) {
            this.torneioNivel = [
                SELECT Id, Name, Nivel__c, ValorSmall__c, ValorBig__c, ValorAnte__c, 
                ProximoNivel__c, DuracaoBlinds__c
                FROM TorneioNivel__c
                WHERE Id=: torneioEvento.Nivel__c
            ];
            
            if(!String.isEmpty(torneioNivel.ProximoNivel__c)) {
                this.torneioNivelProx = [
                    SELECT Id, Name, Nivel__c, ValorSmall__c, ValorBig__c, ValorAnte__c, DuracaoBlinds__c
                    FROM TorneioNivel__c
                    WHERE Id=: torneioNivel.ProximoNivel__c
                ];
            } else {
                this.torneioNivelProx = null;
                
            }
            
            if(this.torneioNivel.ValorSmall__c == 0 && this.torneioNivel.ValorBig__c == 0) {
                this.nivel = this.torneioNivel.Name;
                
            } else {
                this.nivel = 'NÍVEL ' + this.torneioNivel.Nivel__c + 'º ';     
            }
        }
        
        this.mediaStack = 0;
        if(this.torneioEvento.TotalFichas__c > 0 && this.torneioEvento.TotalPlayers__c > 0) {
            this.mediaStack = this.torneioEvento.TotalFichas__c / this.torneioEvento.TotalPlayers__c;
        }
        
        if(this.torneioNivelProx != null && this.torneioNivelProx.ValorSmall__c != 0) {
            List<TorneioNivel__c> nivelList = [
                SELECT Id, DuracaoBlinds__c, ValorSmall__c
                FROM TorneioNivel__c
                WHERE TorneioEstrutura__c =: torneioEvento.Estrutura__c 
                AND Nivel__c >:  this.torneioNivel.Nivel__c 
                
                ORDER BY Nivel__c DESC
            ];
            
            for(Integer i = nivelList.size()-1; i > 0; i--) {
                TorneioNivel__c tn = nivelList.get(i);            
                if(tn.ValorSmall__c == 0) {
                    break;    
                }
                minutos += Integer.valueOf(tn.DuracaoBlinds__c);
            }
        }
        
        tempoIntervalo = formatTempo(minutos*60*1000);
    }
    
    public void btnIniciar() {
        System.debug('btnIniciar');
        
        if(!isBtnIniciar) {
            return;
        }
        
        if(String.isEmpty(this.torneioEvento.Estrutura__c)) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.WARNING, 'O Evento não possui estrutura configurada, por favor adicione uma estrutura.'));
            return;
        }
        
        TorneioEvento__c tev = new TorneioEvento__c(Id=torneioEvento.Id);
        tev.Status__c = 'Em Andamento';
        tev.Nivel__c = torneioEvento.Nivel__c;
        tev.DataInicioLevel__c = torneioEvento.DataInicioLevel__c;
        
        if(String.isEmpty(tev.Nivel__c)) {
            List<TorneioNivel__c> nivelList = [
                SELECT Id, DuracaoBlinds__c
                FROM TorneioNivel__c
                WHERE TorneioEstrutura__c =: torneioEvento.Estrutura__c
                ORDER BY Nivel__c ASC
            ];
            final TorneioNivel__c ni = nivelList.get(0);
            tev.Nivel__c = ni.Id;
            
            Integer minutes = Integer.valueOf(ni.DuracaoBlinds__c);
            configNovoLevel(tev, minutes);
        }
       
        try {
            UPDATE tev;
            
            atualizarPainel();
            
        } catch(Exception ex) {
            System.debug('Ex: ' + ex);
            
        }
    }
    
    public void btnPausar() {
        if(!isBtnPausar) {
            return;
        }
        
        TorneioEvento__c tev = new TorneioEvento__c(Id=torneioEvento.Id);
        tev.Status__c = 'Parado';
        
        try {
            UPDATE tev;
            
            atualizarPainel();
            
        } catch(Exception ex) {
            System.debug('Ex: ' + ex);
            
        }
    }
    
    public String formatTempo(Long ms) {
        Decimal s = ms/1000;
        Integer m = 0;
        Integer h = 0;
        
        
        if(s < 1) {
            s = 0;
            
        } else {
            m = (Integer) (s/60);
            
            if(m < 1) {
                m = 0;
                
            } else {
                h = m/60;
                
                if(h < 1) {
                    h = 0;
                }
            }
        }
        
        s  = s - (m  * 60);
        m  = m - (h  * 60);
        
        return 
            (h < 10 ? '0' + h : '' + h) + ':' + 
            (m < 10 ? '0' + m : '' + m) + ':' +
            (s < 10 ? '0' + s : '' + s);
    }
    
    private void configNovoLevel(TorneioEvento__c tev, Integer minutes) {
        tev.DataInicioLevel__c = Datetime.newInstance(
            Datetime.now().year(), 
            Datetime.now().month(), 
            Datetime.now().day(), 
            Datetime.now().hour(), 
            Datetime.now().minute(), 0);
        
        tev.TempoLevel__c	= tev.DataInicioLevel__c.addMinutes(minutes);
    }
    
    public void updateTimeSeg() {
        TorneioEvento__c tev = new TorneioEvento__c(Id=torneioEvento.Id);
        tev.TempoLevel__c = torneioEvento.TempoLevel__c.addMinutes(-1);
        
        Integer min = 
            UtilApex.betweenMinutes(torneioEvento.DataInicioLevel__c, tev.TempoLevel__c);
        
        System.debug('torneioEvento.DataInicioLevel__c:' + torneioEvento.DataInicioLevel__c);
        System.debug('torneioEvento.TempoLevel__c:' + torneioEvento.TempoLevel__c);
        System.debug('Min:' + min);
        
        if(min <= 0) {      
            if(torneioNivelProx != null) {
                tev.Nivel__c = torneioNivelProx.Id;    
                
                Integer minutes = Integer.valueOf(this.torneioNivelProx.DuracaoBlinds__c);
                configNovoLevel(tev, minutes);
                
            } else {
                tev.Status__c = 'Parado';
                
            }
        }
        
        UPDATE tev;
        
        atualizarPainel();
    }
    
    public void alterarNivel() {
        TorneioEvento__c tev = new TorneioEvento__c(Id=torneioEvento.Id);
        tev.Nivel__c = torneioEvento.Nivel__c;
        
        TorneioNivel__c nivel = [
            SELECT Id, DuracaoBlinds__c
            FROM TorneioNivel__c
            WHERE ID =: torneioEvento.Nivel__c
        ];
        
        Integer minutes = Integer.valueOf(nivel.DuracaoBlinds__c);
        configNovoLevel(tev, minutes);
        
        
        UPDATE tev;
        atualizarPainel();
    }
    
    public PageReference telao() {
        PageReference redirectPage = Page.TorneioPainel;
        redirectPage.getParameters().put('id', torneioEventoId);
        return redirectPage;
    }
}