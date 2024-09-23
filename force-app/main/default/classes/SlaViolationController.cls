public with sharing class SlaViolationController {
    @AuraEnabled(cacheable=true)
    public static List<ClientViolationDTO> getClientsWithSlaViolations() {
        List<ClientViolationDTO> violations = new List<ClientViolationDTO>();
        
        // Consulta para buscar os casos que têm um SLA definido
        List<Case> cases = [
            //SELECT Id, CaseNumber, Subject, Status, Priority, CreatedDate, Account.Name, AccountId, Robot__r.Name, CalculatedSLA__c
            
            SELECT Id, CaseNumber, Account.Name,Status, InstallationDetails__c, Type, Priority, CalculatedSLA__c, Subject,Description,
            Product__c,RobotsLocation__c,Robot__r.Name,Origin,SupportTechnician__r.LastName,Owner.Name,CreatedDate,RecordType.Name
            FROM Case
            WHERE CalculatedSLA__c != null 
            AND Status != 'Closed'
            ORDER BY CreatedDate, Priority DESC // Garantir que o SLA esteja definido
        ];

        // Itera sobre os casos para calcular a violação de SLA
        for (Case c : cases) {
            // Calcula a data de vencimento do SLA somando as horas do SLA ao CreatedDate
            DateTime slaDueDate = c.CreatedDate.addHours(Integer.valueOf(c.CalculatedSLA__c));            

            // Verifica se o chamado está com SLA vencido
            if (DateTime.now() > slaDueDate) {
                violations.add(new ClientViolationDTO(
                    c.Account.Name, 
                    c.CaseNumber, 
                    Integer.valueOf(c.CalculatedSLA__c), 
                    c.CreatedDate, 
                    c.Robot__r != null ? c.Robot__r.Name : 'N/A',
                    c.Owner.Name,
                    c.Priority,
                    c.recordType.Name,
                    slaDueDate
                ));
                
            }
        }
                
        return violations;

        
    }

    // DTO para enviar ao LWC
    public class ClientViolationDTO {
        @AuraEnabled public String clientName;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public Integer slaHours;
        @AuraEnabled public DateTime createdDate;
        @AuraEnabled public String robotName;
        @AuraEnabled public String responsavel;
        @AuraEnabled public String prioridade;
        @AuraEnabled public String tipoChamado;
        @AuraEnabled public DateTime dataVencida;

        public ClientViolationDTO(String clientName, String caseNumber, Integer slaHours, DateTime createdDate, String robotName, String responsavel, String Prioridade, String tipoChamado, DateTime dataVencida) {
            
            this.clientName = clientName;
            this.caseNumber = caseNumber;
            this.slaHours = slaHours;
            this.createdDate = createdDate;
            this.robotName = robotName;
            this.responsavel = responsavel;
            this.prioridade = prioridade;
            this.tipoChamado = tipoChamado;
            this.dataVencida = dataVencida;


        }
    }
}
