@IsTest
public class CaseRobotHandlerTest {

    @TestSetup
    static void setup() {
        // Criação de contas de teste com robôs associados
        Account accountWithRobot = new Account(Name = 'Account with Robot', Robot__c = 'a00aj00000IvaPOAAZ', CountryRobot__c='a01aj00000WyOSDAA3'); // Substitua pelo Id do Robô válido em seu ambiente
        Account accountWithoutRobot = new Account(Name = 'Account without Robot');
        insert new List<Account> { accountWithRobot, accountWithoutRobot };

        // Criação de casos de teste usando CaseFactory e CaseBuilder com valores de SLA ajustados automaticamente
        Case caseWithRobotAccount = CaseFactory.getFactory()
            .createCase()
            .account(accountWithRobot)
            .status('New')
            .priority('High')
            .calculatedSLA('4') // Adicionando o método calculatedSLA para definir o SLA corretamente com base na prioridade High
            .subject('Case with Robot Account')
            .get();

        Case caseWithoutRobotAccount = CaseFactory.getFactory()
            .createCase()
            .account(accountWithoutRobot)
            .status('New')
            .priority('Medium')
            .calculatedSLA('8') // Adicionando o método calculatedSLA para definir o SLA corretamente com base na prioridade Medium
            .subject('Case without Robot Account')
            .get();

        Case caseWithNoAccount = CaseFactory.getFactory()
            .createCase()
            .status('New')
            .priority('Low')
            .calculatedSLA('24') // Adicionando o método calculatedSLA para definir o SLA corretamente com base na prioridade Low
            .subject('Case with No Account')
            .get();

        // Inserção dos casos criados
        insert new List<Case> { caseWithRobotAccount, caseWithoutRobotAccount, caseWithNoAccount };
    }

    @IsTest
    static void testAssignRobotToCase() {
        // Consulta os casos de teste criados na configuração
        List<Case> cases = [SELECT Id, AccountId, Robot__c, CalculatedSLA__c, Priority FROM Case];

        // Verifica se os casos foram criados corretamente antes do teste
        System.assertEquals(3, cases.size(), 'Deveria haver três casos criados.');

        // Chama o método a ser testado
        Test.startTest();
        CaseRobotHandler.assignRobotToCase(cases);
        Test.stopTest();

        // Consulta os casos após a execução do método para validar as associações
        List<Case> updatedCases = [SELECT Id, AccountId, Robot__c, CalculatedSLA__c, Priority FROM Case];
                
        // Verificação: o caso associado à conta com robô deve ter o robô associado corretamente
        Case updatedCaseWithRobotAccount = updatedCases[0];
        System.assertNotEquals(null, updatedCaseWithRobotAccount.Robot__c, 'O robô deveria estar associado ao caso.');
        System.assertEquals('a00aj00000IvaPOAAZ', updatedCaseWithRobotAccount.Robot__c, 'O robô associado ao caso deve corresponder ao robô da conta.');
        System.assertEquals('4', updatedCaseWithRobotAccount.CalculatedSLA__c, 'O SLA calculado deve ser 4 para prioridade alta.');
        // Verificação: o caso associado à conta sem robô não deve ter um robô associado
        Case updatedCaseWithoutRobotAccount = updatedCases[1];
        System.assertEquals(null, updatedCaseWithoutRobotAccount.Robot__c, 'Nenhum robô deve estar associado ao caso.');
        System.assertEquals('8', updatedCaseWithoutRobotAccount.CalculatedSLA__c, 'O SLA calculado deve ser 8 para prioridade média.');

        // Verificação: o caso sem conta também não deve ter um robô associado
        Case updatedCaseWithNoAccount = updatedCases[2];
        System.assertEquals(null, updatedCaseWithNoAccount.Robot__c, 'Nenhum robô deve estar associado ao caso sem conta.');
        System.assertEquals('24', updatedCaseWithNoAccount.CalculatedSLA__c, 'O SLA calculado deve ser 24 para prioridade baixa.');
    }
}
