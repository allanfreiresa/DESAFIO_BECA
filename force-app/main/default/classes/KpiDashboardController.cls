public with sharing class KpiDashboardController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getKpiData() {
        Map<String, Object> kpiData = new Map<String, Object>();

        // Total de Chamados Abertos
        Integer totalOpenCases = [SELECT COUNT() FROM Case WHERE Status != 'Closed'];
        kpiData.put('totalOpenCases', totalOpenCases);

        // Chamados Atrasados com base no SLA
        List<Case> overdueCasesList = [
            SELECT Id, CreatedDate, CalculatedSLA__c, Priority, Status
            FROM Case
            WHERE CalculatedSLA__c != null 
            AND Status != 'Closed'
        ];

        Integer overdueCasesCount = 0;
        Integer criticalOverdueCasesCount = 0;

        for (Case c : overdueCasesList) {
            DateTime slaDueDate = c.CreatedDate.addHours(Integer.valueOf(c.CalculatedSLA__c));

            if (DateTime.now() > slaDueDate) {
                overdueCasesCount++;
                if (c.Priority == 'High') {
                    criticalOverdueCasesCount++;
                }
            }
        }

        kpiData.put('overdueCases', overdueCasesCount);
        kpiData.put('criticalOverdueCases', criticalOverdueCasesCount);

        // Ajuste: Total de Chamados por Responsável (agora agrupando por OwnerId)
        List<AggregateResult> caseCountByOwnerResult = [
            SELECT COUNT(Id) totalCases, OwnerId
            FROM Case
            WHERE Status != 'Closed'
            GROUP BY OwnerId
        ];

        // Crie um Map para armazenar os nomes dos Owners e a contagem dos casos
        Map<String, Integer> casesByOwner = new Map<String, Integer>();
        Set<Id> ownerIds = new Set<Id>();

        for (AggregateResult ar : caseCountByOwnerResult) {
            ownerIds.add((Id)ar.get('OwnerId'));
        }

        // Busque os nomes dos Owners
        Map<Id, User> ownersMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :ownerIds]);

        for (AggregateResult ar : caseCountByOwnerResult) {
            String ownerName = ownersMap.get((Id)ar.get('OwnerId')).Name;
            Integer count = (Integer)ar.get('totalCases');
            casesByOwner.put(ownerName, count);
        }

        kpiData.put('casesByOwner', casesByOwner);

        return kpiData;
    }
}
