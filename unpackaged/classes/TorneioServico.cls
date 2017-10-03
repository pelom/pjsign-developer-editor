public with sharing class TorneioServico {

    public static TorneioServico torneioServico = null;
    public static TorneioServico getServico() {
        if(torneioServico == null) {
            torneioServico = new TorneioServico();
        }
        return torneioServico;
    }
    
    public List<TorneioEvento__c> obterEventos(String torneioId) {
        if(!String.isEmpty(torneioId)) {
            List<TorneioEvento__c> torneioList = [
                SELECT Name, Data__c
                FROM TorneioEvento__c
                WHERE Torneio__c =: torneioId 
                AND Data__c >: Datetime.now() 
                AND Status__c != 'Finalizado' 
                AND Nivel__c != null
                AND Estrutura__c != null
                ORDER BY Data__c DESC
            ];     
        }
       
        return [
            SELECT Torneio__c, Torneio__r.Name, Torneio__r.Titulo__c
            FROM TorneioEvento__c
            WHERE Data__c >: Datetime.now() AND Status__c != 'Finalizado' AND Nivel__c != null
            ORDER BY Torneio__r.Titulo__c DESC
        ];
    }
}