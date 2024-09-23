@IsTest
public class SlaViolationControllerTest {

    @TestSetup
    static void setup() {
        // Criação de uma conta para associar aos casos
        Account accountWithRobot = new Account(Name = 'Cliente com Robô A1');
        insert accountWithRobot;

        // Criação de um país pertencente ao mesmo continente do robô
        Country__c paisAmerica = new Country__c(Name = 'Estados Unidos', Continent__c = 'América');
        insert paisAmerica;

        // Criação de casos de teste usando Factory e Builder com SLA ajustado conforme a prioridade
        Case caseWithViolation = CaseFactory.getFactory()
            .createCase()
            .account(accountWithRobot)
            .status('New')
            .priority('High')
            .calculatedSLA('4')  // SLA para prioridade alta
            .subject('Caso com Violação de SLA')
            .get();

        Case caseWithoutViolation = CaseFactory.getFactory()
            .createCase()
            .account(accountWithRobot)
            .status('New')
            .priority('Low')
            .calculatedSLA('24')  // SLA para prioridade baixa
            .subject('Caso sem Violação de SLA')
            .get();

        insert new List<Case> { caseWithViolation, caseWithoutViolation };

        // Manipulação do tempo para simular a violação de SLA no primeiro caso
        Test.setCreatedDate(caseWithViolation.Id, DateTime.now().addDays(-1));  // SLA já vencido
        Test.setCreatedDate(caseWithoutViolation.Id, DateTime.now());           // SLA ainda válido
    }

    @IsTest
    static void testGetClientsWithSlaViolations() {
        Test.startTest();

        // Chama o método e valida o retorno
        List<SlaViolationController.ClientViolationDTO> violations = SlaViolationController.getClientsWithSlaViolations();

        Test.stopTest();

        // Verifica se apenas o caso com SLA vencido foi retornado
        System.assertEquals(1, violations.size(), 'Deveria haver apenas um caso com SLA vencido');
        
        // Verifica o CaseNumber gerado, não o assunto (subject)
        Case caseWithViolation = [SELECT CaseNumber FROM Case WHERE Subject = 'Caso com Violação de SLA' LIMIT 1];
        System.assertEquals(caseWithViolation.CaseNumber, violations[0].caseNumber, 'O caso retornado está incorreto');
    }

    @IsTest
    static void testNoSlaViolations() {
        // Simula a ausência de casos com SLA vencido ao deletar todos os casos
        delete [SELECT Id FROM Case];

        Test.startTest();
        
        // Chama o método e valida o retorno
        List<SlaViolationController.ClientViolationDTO> violations = SlaViolationController.getClientsWithSlaViolations();

        Test.stopTest();

        // Verifica se não há violações de SLA
        System.assertEquals(0, violations.size(), 'Não deveria haver casos com SLA vencido');
    }
}
