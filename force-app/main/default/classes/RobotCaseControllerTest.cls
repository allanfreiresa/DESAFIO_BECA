@IsTest
public class RobotCaseControllerTest {

    @TestSetup
    static void setup() {
        // Criação de um robô com localização válida
        Robo__c robotAmerica = new Robo__c(Name = 'Robô A1', Location__c = 'Fábrica - América');
        insert robotAmerica;

        // Criação de um país pertencente ao mesmo continente do robô
        Country__c paisAmerica = new Country__c(Name = 'Estados Unidos', Continent__c = 'América', Robot__c = robotAmerica.Id);
        insert paisAmerica;

        // Criação de uma conta associada ao robô e ao país
        Account accountWithRobot = new Account(Name = 'Cliente com Robô A1', Robot__c = robotAmerica.Id, CountryRobot__c = paisAmerica.Id);
        insert accountWithRobot;

        // Criação de casos associados à conta, com robô e país corretos
        Case caseWithRobot = CaseFactory.getFactory()
            .createCase()
            .account(accountWithRobot)
            .status('New')
            .priority('High')
            .calculatedSLA('4')  // SLA correto para prioridade alta
            .subject('Case para Cliente com Robô A1')
            .get();

        insert caseWithRobot;
    }

    @IsTest
    static void testGetRobotCaseCounts() {
        Test.startTest();
        
        // Chama o método de contagem de casos por robô
        List<RobotCaseController.RobotCaseCountDTO> result = RobotCaseController.getRobotCaseCounts();

        // Valida se a consulta está retornando corretamente
        System.assertEquals(1, result.size(), 'O número de robôs com casos retornados está incorreto');
        System.assertEquals('Robô A1', result[0].robotName, 'Nome do robô retornado está incorreto');
        System.assertEquals(1, result[0].caseCount, 'Número de casos para o Robô A1 está incorreto');

        Test.stopTest();
    }
}
