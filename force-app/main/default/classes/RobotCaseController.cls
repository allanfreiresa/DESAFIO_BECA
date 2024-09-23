public with sharing class RobotCaseController {
    @AuraEnabled(cacheable=true)
    public static List<RobotCaseCountDTO> getRobotCaseCounts() {
        List<RobotCaseCountDTO> caseCounts = new List<RobotCaseCountDTO>();

        // Consulta para contar os casos por robô
        AggregateResult[] results = [
            SELECT Robot__r.Name robotName, COUNT(Id) totalCases
            FROM Case
            WHERE Robot__c != null
            GROUP BY Robot__r.Name
            ORDER BY COUNT(Id) DESC
        ];

        // Adiciona os resultados à lista de DTOs
        for (AggregateResult ar : results) {
            // Acessa o COUNT(Id) pelo nome padrão 'expr0' usado pelo Salesforce
            caseCounts.add(new RobotCaseCountDTO(
                (String) ar.get('robotName'),
                (Integer) ar.get('totalCases') // Acessa o resultado do COUNT(Id)
            ));
        }

        return caseCounts;
    }

    // DTO para transferir os dados do robô e número de chamados
    public class RobotCaseCountDTO {
        @AuraEnabled public String robotName;
        @AuraEnabled public Integer caseCount;

        public RobotCaseCountDTO(String robotName, Integer caseCount) {
            this.robotName = robotName;
            this.caseCount = caseCount;
        }
    }
}
