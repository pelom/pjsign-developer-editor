public class UtilApex {

    public static Map<String, String> mapaSemana { 
        get {
            Map<String, String> mapa = new Map<String, String>();
            mapa.put('Sunday', 		'Dom');
            mapa.put('Monday', 		'Seg');
            mapa.put('Tuesday', 	'Ter');
            mapa.put('Wednesday', 	'Qua');
            mapa.put('Thursday', 	'Qui');
            mapa.put('Friday', 		'Sex');
            mapa.put('Saturday', 	'Sáb');
            return mapa;
        }
    }
    
    private static Map< String, Map<String, Id>> recordTypeMap;
    
    public static Id getRecordTypeId(String SObjectType, String DeveloperName) {
        
        if(String.isEmpty( SObjectType ) || String.isEmpty(DeveloperName)) {
            throw new UtilApexException( 'You must provide valid SObject type and developer name arguments.' );
        }
        
        if(recordTypeMap == null) {
            recordTypeMap = new Map<String, Map<String, Id>>();
            
            for(RecordType recType : [SELECT Id, SObjectType, DeveloperName FROM RecordType] ) {
                Map<String, Id> SObjectMap = recordTypeMap.get(recType.SObjectType);
                
                if(SObjectMap == null) {
                    SObjectMap = new Map<String, Id> { recType.DeveloperName => recType.Id };
                        
                        recordTypeMap.put( recType.SObjectType, SObjectMap );
                    
                } else {
                    SObjectMap.put( recType.DeveloperName, recType.Id ); 
                    
                }
            }
            
        }
        
        Map<String, Id> SObjectMap = recordTypeMap.get( SObjectType );
        if(SObjectMap == null) throw new UtilApexException( 'Invalid SObject type.' );
        
        Id recTypeId = SObjectMap.get( DeveloperName );
        if(recTypeId == null) {
			throw new UtilApexException('Invalid developer name for SObject type "' + SObjectType + '".' );
        }
        
        return recTypeId;
    }

    public static Integer betweenMinutes(Datetime a, Datetime b) {
        Long tempo = b.getTime() - a.getTime();
        return Math.round(tempo/1000/60);
    }
    
    public static Integer betweenSegunds(Datetime a, Datetime b) {
        Long tempo = b.getTime() - a.getTime();
        return Math.round(tempo/1000);
    }
    
    public class UtilApexException extends Exception {
    }
    
    public interface UtilApexTriggerListener {
        void afterInsert(List<SObject> newList);
        void beforeInsert(List<SObject> newList);
        void beforeUpdate(List<SObject> newList);
    }
}