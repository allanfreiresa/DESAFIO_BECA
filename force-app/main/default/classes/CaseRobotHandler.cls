public with sharing class CaseRobotHandler {

    // Método para associar o robô correto ao caso baseado no cliente selecionado
    public static void assignRobotToCase(List<Case> cases) {
        // Mapa para armazenar os robôs associados aos clientes
        Map<Id, Id> clientToRobotMap = new Map<Id, Id>();
        System.debug('entrou');

        // Coleta os IDs dos clientes relacionados aos casos no Trigger
        Set<Id> clientIds = new Set<Id>();
        for (Case caseRecord : cases) { // Trigger.new passa os casos em processo de inserção ou atualização
            if (caseRecord.AccountId != null) {
                clientIds.add(caseRecord.AccountId); // Coleta apenas os IDs dos clientes envolvidos no Trigger
            }
        }
        System.debug('total Ids'+ clientIds );
        // Consulta os clientes para pegar o robô associado a cada um
        if (!clientIds.isEmpty()) {
            // Consultando o objeto Account para obter o robô associado (campo Robot__c)
            List<Account> accounts = [SELECT Id, Robot__c FROM Account WHERE Id IN :clientIds];
            
            // Preencher o mapa com as associações corretas entre o cliente e o robô
            for (Account acc : accounts) {
                if (acc.Robot__c != null) {
                    clientToRobotMap.put(acc.Id, acc.Robot__c);
                }
            }
        }

        // Associa o robô correto aos casos
        for (Case caseRecord : cases) {
            if (caseRecord.AccountId != null && clientToRobotMap.containsKey(caseRecord.AccountId)) {
                // Define o robô no chamado a partir do robô associado ao cliente
                caseRecord.Robot__c = clientToRobotMap.get(caseRecord.AccountId);
            }else {
                System.debug('entrou no else, nuylo sem robô');                
            }
        }
    }
}
