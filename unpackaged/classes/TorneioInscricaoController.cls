public with sharing class TorneioInscricaoController {
    
    public Account accClube 			{ get;set; }
    
    public String textoChave 			{ get;set; }
    public List<Contact> jogadorList 	{ get;set; }

    public String torSelect				{ get;set; }
    public String evtSelect				{ get;set; }
    
    public Torneio__c			torneio	  { get;set; }
    public TorneioEvento__c 	evento	  { get;set; }
    public TorneioEstrutura__c 	estrutura { get;set; }
    
    public Contact 				  jogador 	  { get;set; }
    public TorneioInscricao__c	  inscricao	  { get;set; }
    public TorneioCompra__c 	  tCompra     { get;set; }
    public List<TorneioCompra__c> comprasList { get;set; }
    
    public List<TorneioInscricao__c> inscricaoList { get;set; }
    public Boolean isByIn {
        get {
            
            if(this.estrutura.StackBuyIn__c == null) {
                return false;
            }
            
            for(TorneioCompra__c c : comprasList) {
                if(c.Tipo__c == 'Buy In') {
                    return false;
                }
            }
            return true;
        }
    }

    public Boolean isInscricao {
        get {
            if(evtSelect == null || this.estrutura.StackBuyIn__c == null ||
               inscricao.Id != null) {
                   return false;
               }
            
            if(this.evento.Nivel__r.Nivel__c == null || 
               this.evento.Nivel__r.Nivel__c > this.estrutura.NivelRebuy__r.Nivel__c) {
                   return false;
               } 
            
            return true;
        }
    }
    
    public Boolean isRebuy {
        get {
            if(torneio.ValorRebuy__c == 0) {
                return false;
            }
            
            if(this.evtSelect == null || 
               this.estrutura.StackBuyIn__c == null || 
               this.inscricao.Id == null) {
                   return false;
               }
            
            if(this.evento.Status__c != 'Em Andamento') {
                return false;
            }
            
            if(this.evento.Nivel__r.Nivel__c == null || 
               this.evento.Nivel__r.Nivel__c > this.estrutura.NivelRebuy__r.Nivel__c) {
                   return false;
               } 
            
            for(TorneioCompra__c c : comprasList) {
                if(c.Tipo__c == 'Rebuy' && c.Id == null) {
                    return false;
                }
            }
            
            return true;
        }
    }
    
    public Boolean isAddOn {
        get {
            if(torneio.ValorAddOn__c == 0) {
                return false;
            }
            
            if(this.evtSelect == null || 
               this.estrutura.StackAddOn__c == null || 
               this.inscricao.Id == null) {
                   return false;
               }
            
            if(this.evento.Status__c != 'Em Andamento') {
                return false;
            }
            
            if(this.evento.Nivel__r.Nivel__c == null || 
               this.evento.Nivel__c != this.estrutura.NivelAddon__c) {
                   return false;
               } 
            
            for(TorneioCompra__c c : comprasList) {
                if(c.Tipo__c == 'Add On') {
                    return false;
                }
            }
            
            return true;
        }
    }
    
    public List<SelectOption> eventoSelect { get;set;}
    public List<SelectOption> torneioSelect {
        get {
            List<SelectOption> listSelect = new List<SelectOption>();
            
            Datetime dat = Datetime.newInstance(
                Datetime.now().date().year(), 
                Datetime.now().date().month(), 
                Datetime.now().date().day(), 0, 0, 0);
            
            List<TorneioEvento__c> torneioList = [
                SELECT Torneio__c, Torneio__r.Name, Torneio__r.Titulo__c
                FROM TorneioEvento__c
                
                WHERE Data__c >: dat 
                AND Status__c != 'Finalizado' 
                AND Nivel__c != null
                AND Estrutura__c != null
                ORDER BY Torneio__r.Titulo__c DESC
            ];
            
            Set<String> titulosSet = new Set<String>();
            for(TorneioEvento__c tv : torneioList) {
                if(this.torSelect == null) {//nenhum torneio selecionado?
                    this.torSelect = tv.Torneio__c;
                    selectTorneio();
                }
                
                String titulo = tv.Torneio__r.Titulo__c + ' ' + tv.Torneio__r.Name;
                if(!titulosSet.contains(titulo)) {
                    titulosSet.add(titulo);
                    listSelect.add(new SelectOption(tv.Torneio__c, titulo));
                }
                
            }
           
            return listSelect;
        }
    }
    
    public TorneioInscricaoController() {
        this.accClube = 
            ClubeServico.getServico().obterClube(UserInfo.getUserId());
        this.evento = new TorneioEvento__c();
        this.eventoSelect = new List<SelectOption>();
        this.comprasList = new List<TorneioCompra__c>();
        this.inscricaoList = new List<TorneioInscricao__c>();
    }
    
    public void selectJogador() {
        String jogId = 
            Apexpages.currentPage().getParameters().get('jogId');
        if(String.isEmpty(jogId)) {
            return;
        } 
        
        this.jogador = [
            SELECT Id, FirstName, LastName
            FROM Contact
            WHERE Id =: jogId
        ];
        
        selectEvento();
        
        this.textoChave = null;
    }
    
    public void selectTorneio() {
        if(String.isEmpty(torSelect)) {
            return;
        }
        limparForm();//LIMPAR DADOS SELECIONADOS
        
        this.torneio = [
            SELECT Titulo__c, ValorBuyIn__c, ValorRebuy__c, 
            ValorAddOn__c, ValorTaxa__c, Descricao__c
            FROM Torneio__c
            WHERE Id =:torSelect
        ];
        
        Datetime dat = Datetime.newInstance(
            Datetime.now().date().year(), 
            Datetime.now().date().month(), 
            Datetime.now().date().day(), 0, 0, 0);
        
        List<TorneioEvento__c> torneioList = [
            SELECT Name, Data__c
            FROM TorneioEvento__c
            WHERE Torneio__c =: torSelect 
            AND Data__c >: dat 
            AND Status__c != 'Finalizado' 
            AND Nivel__c != null
            AND Estrutura__c != null
            ORDER BY Data__c DESC
        ];
        
        this.eventoSelect.clear();
        for(TorneioEvento__c ev : torneioList) {
            this.eventoSelect.add(new SelectOption(ev.Id, ev.Name));
        }
    }
    
    public void selectEvento() {
        limparForm();
        if(String.isEmpty(evtSelect)) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.INFO, 'Selecione um evento para a inscrição do torneio'));
            return;
        }
        
        this.evento = [
            SELECT Name, Data__c, Estrutura__c,
            Nivel__r.Name,  Nivel__r.Nivel__c, Nivel__r.DuracaoBlinds__c, 
            Status__c
            
            FROM TorneioEvento__c
            WHERE Id =: evtSelect
        ];
        
        List<TorneioEstrutura__c> estList = [
            SELECT StackBuyIn__c, StackAddOn__c,
            NivelRebuy__r.Nivel__c, NivelAddon__c
            FROM TorneioEstrutura__c
            WHERE Id=: evento.Estrutura__c 
        ];
        
        if(estList.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.WARNING, 
                'O Evento selecionado não possui estrutura configurada.'));
            return;
            
        } else {
            this.estrutura = estList.get(0);
            this.inscricaoList = [
                SELECT Name, DataInscricao__c,
                Jogador__c, Jogador__r.FirstName, Jogador__r.LastName, 
                Status__c, StatusPlayer__c
                FROM TorneioInscricao__c
                WHERE Torneio_Evento__c =: evtSelect 
                AND Status__c = 'Inscrito' AND StatusPlayer__c != 'Caiu'
            ];
            
            if(jogador == null) {
                return; 
            }
            
            List<TorneioInscricao__c> insList = [
                SELECT Name, DataInscricao__c,
                Torneio__r.Titulo__c, Torneio_Evento__r.Name,
                Jogador__c, Jogador__r.FirstName, Jogador__r.LastName, 
                Status__c, StatusPlayer__c
                FROM TorneioInscricao__c
                WHERE Torneio_Evento__c =: evtSelect AND Jogador__c =: jogador.Id 
                AND Status__c = 'Inscrito' AND StatusPlayer__c != 'Caiu'
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            if(!insList.isEmpty()) {
                this.inscricao = insList.get(0);
                this.jogador = new Contact();
                this.jogador.Id = this.inscricao.Jogador__c;
                this.jogador.FirstName = this.inscricao.Jogador__r.FirstName;
                this.jogador.LastName = this.inscricao.Jogador__r.LastName;
                
                this.comprasList = [
                    SELECT Tipo__c, Valor__c, ValorTotal__c, Fichas__c, Status__c,
                    FormaPagamento__c, CreatedById
                    FROM TorneioCompra__c
                    WHERE TorneioInscricao__c =: this.inscricao.Id
                ];
                 
            } else {
                addByIn();    
            }
        }
    }
    
    private void limparForm() {
        this.evento = new TorneioEvento__c();
        this.tCompra = new TorneioCompra__c();
        this.inscricao = new TorneioInscricao__c();
        this.inscricao.Jogador__c = (this.jogador != null) ? this.jogador.Id : null;     
        this.comprasList.clear();
        this.inscricaoList.clear();
        ApexPages.getMessages().clear();
    }
    
    public void buscar() {
        
        if(String.isEmpty(this.textoChave)) {
            return;
        }
        
        this.textoChave = this.textoChave.trim();
        
        jogadorList = Database.query(
            'SELECT Id, FirstName, LastName, MobilePhone, Email ' 	+ 
            'FROM Contact ' + 
            'WHERE RecordTypeId = \'' + UtilApex.getRecordTypeId('Contact', 'Jogador') + '\'' 				+
            (String.isNotBlank( textoChave ) ? ' AND (FirstName LIKE \'%' + this.textoChave + 
             '%\' OR LastName LIKE \'%' 		+ this.textoChave + 
             '%\' OR Email LIKE \'%' 			+ this.textoChave +
             '%\' OR MobilePhone LIKE \'%' 		+ this.textoChave +
             '%\')' : '') +
            ' ORDER BY LastName ASC LIMIT 100'
        );
    }
    
    public void addAddOn() {
        if(!isAddOn) {
            return;
        }
        
        TorneioCompra__c tc = new TorneioCompra__c();
        tc.Tipo__c 			= 'Add On';
        tc.Valor__c 		= torneio.ValorAddOn__c;
        tc.Fichas__c 		= this.estrutura.StackAddOn__c;
        
        this.comprasList.add(tc);
        
        atualizarCompra();
    }
    
    public void addRebuy() {
        if(!isRebuy) {
            return;
        }
        TorneioCompra__c tc = new TorneioCompra__c();
        tc.Tipo__c 			= 'Rebuy';
        tc.Valor__c 		= torneio.ValorRebuy__c;
        tc.Fichas__c 		= this.estrutura.StackBuyIn__c;
        
        TorneioCompra__c tx = new TorneioCompra__c();
        tx.Tipo__c 			= 'Taxa Rebuy';
        tx.Valor__c 		= torneio.ValorTaxa__c;
        tx.Fichas__c 		= 0;
        
        this.comprasList.add(tx);
        this.comprasList.add(tc);
        
        atualizarCompra();
    }
    
    public void addByIn() {
        TorneioCompra__c tc = new TorneioCompra__c();
        tc.Tipo__c 			= 'Buy In';
        tc.Valor__c 		= torneio.ValorBuyIn__c;
        tc.Fichas__c 		= this.estrutura.StackBuyIn__c;
        
        TorneioCompra__c tx = new TorneioCompra__c();
        tx.Tipo__c 			= 'Taxa BuyIn';
        tx.Valor__c 		= torneio.ValorTaxa__c;
        tx.Fichas__c 		= 0;
        
        comprasList.add(tx);
        comprasList.add(tc);
        
        atualizarCompra();
    }
    
    private void atualizarCompra() {
        Decimal total = 0;
        for(TorneioCompra__c t : comprasList) {
            if(t.Id == null) {
                total += t.Valor__c;
            }
        }
        
        this.tCompra = new TorneioCompra__c();
        this.tCompra.Status__c 		= 'Pago';
        this.tCompra.ValorTotal__c = total;
    }
    
    public void formaPagamento() {
        if(String.isEmpty(this.tCompra.FormaPagamento__c)) {
            return;
        }
        
        Decimal total = 0;
        for(TorneioCompra__c t : comprasList) {
            if(t.Id == null) {
                t.FormaPagamento__c = this.tCompra.FormaPagamento__c;
                Decimal valor = ClubeServico.getServico().calcTaxa(
                    this.tCompra.FormaPagamento__c, t.Valor__c);
                t.ValorTotal__c = valor;
                total += valor;
            }
        }
        this.tCompra.ValorTotal__c = total;
    }
    
    public void fazerInscricao() {
        
        if(String.isEmpty(tCompra.FormaPagamento__c)) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.WARNING, 
                'Forma de Pagamento: É necessário informar'));
            return;
            
        }
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            this.inscricao.Jogador__c = this.jogador.Id;
            this.inscricao.DataInscricao__c = Datetime.now();
            this.inscricao.Status__c = 'Inscrito';
            this.inscricao.Torneio__c = torneio.Id;
            this.inscricao.Torneio_Evento__c = evento.Id;
            
            INSERT this.inscricao;
            
            for(TorneioCompra__c c : comprasList) {
                c.FormaPagamento__c = this.tCompra.FormaPagamento__c;
                c.Torneio__c		= this.torneio.Id;
                c.TorneioEvento__c 	= this.evento.Id;
                c.TorneioInscricao__c = this.inscricao.Id;
                c.Status__c			= this.tCompra.Status__c;
            }
            
            UPSERT this.comprasList;
            
            selectEvento();
            
        } catch(Exception ex) {
            Database.rollback(sp);
            System.debug('Ex: ' + ex);
            
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Ex: ' + ex.getMessage()));
        }
    }
    
    public void salvar() {
        if(String.isEmpty(tCompra.FormaPagamento__c)) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.WARNING, 
                'Forma de Pagamento: É necessário informar'));
            return;
            
        }
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            List<TorneioCompra__c> saveList = new List<TorneioCompra__c>();
            for(TorneioCompra__c c : comprasList) {
                if(c.Id == null) {
                    c.Torneio__c		= this.torneio.Id;
                    c.TorneioEvento__c 	= this.evento.Id;
                    c.TorneioInscricao__c = this.inscricao.Id;
                    c.Status__c			= this.tCompra.Status__c;
                    saveList.add(c);     
                }
            }
            
            INSERT saveList;
            
            selectEvento();
            
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.CONFIRM, 
                'Alterações salvas com sucesso'));
            
        } catch(Exception ex) {
            Database.rollback(sp);
            System.debug('Ex: ' + ex);
            
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Ex: ' + ex.getMessage()));
        }
    }
}