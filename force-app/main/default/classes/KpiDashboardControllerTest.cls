@IsTest
public class KpiDashboardControllerTest {

    @TestSetup
    static void setup() {
        // Criação de uma conta de teste
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Criação de usuários para serem donos dos casos
        User user1 = [SELECT Id FROM User WHERE Profile.Name = 'Minimum Access - Salesforce' LIMIT 1];
        User user2 = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];

        // Definindo uma data de criação simulada para os casos atrasados
        DateTime pastDateForOverdue = DateTime.now().addDays(-5); // Data no passado para simular casos atrasados
        DateTime recentDate = DateTime.now().addMinutes(-10); // Data recente para simular um caso não atrasado

        // Criação de casos de teste com diferentes prioridades e SLAs
        Case caseHighPriority = CaseFactory.getFactory()
            .createCase()
            .account(testAccount)
            .status('New')
            .priority('High')
            .calculatedSLA('4')
            .owner(user1)
            .subject('High Priority Case')
            .get();

        Case caseMediumPriority = CaseFactory.getFactory()
            .createCase()
            .account(testAccount)
            .status('New')
            .priority('Medium')
            .calculatedSLA('8')
            .owner(user2)
            .subject('Medium Priority Case')
            .get();

        Case caseLowPriority = CaseFactory.getFactory()
            .createCase()
            .account(testAccount)
            .status('New')
            .priority('Low')
            .calculatedSLA('24')
            .owner(user1)
            .subject('Low Priority Case')
            .get();

        // Inserção dos casos criados
        insert new List<Case> { caseHighPriority, caseMediumPriority, caseLowPriority };

        // Simulando que dois dos casos foram criados em uma data passada para testar atraso
        Test.setCreatedDate(caseHighPriority.Id, pastDateForOverdue);
        Test.setCreatedDate(caseMediumPriority.Id, pastDateForOverdue);

        // Deixando um caso sem atraso com data recente
        Test.setCreatedDate(caseLowPriority.Id, recentDate);
    }

    @IsTest
    static void testGetKpiData() {
        // Re-consulta os usuários criados no setup
        User user1 = [SELECT Id, Name FROM User WHERE Profile.Name = 'Minimum Access - Salesforce' LIMIT 1];
        User user2 = [SELECT Id, Name FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];

        // Inicia o teste isolado
        Test.startTest();
        // Chama o método para obter os dados do KPI
        Map<String, Object> kpiData = KpiDashboardController.getKpiData();
        Test.stopTest();

        // Verifica se os dados do KPI foram retornados corretamente
        System.assertNotEquals(null, kpiData, 'Os dados do KPI não devem ser nulos.');

        // Verifica se os dados sobre casos abertos foram retornados corretamente
        Integer totalOpenCases = (Integer) kpiData.get('totalOpenCases');
        System.assertEquals(3, totalOpenCases, 'Deveria haver três casos abertos.');

        // Verifica se o número de casos atrasados está correto
        Integer overdueCases = (Integer) kpiData.get('overdueCases');
        System.assertEquals(2, overdueCases, 'Deveria haver dois casos atrasados.');

        // Verifica se o número de casos críticos atrasados está correto
        Integer criticalOverdueCases = (Integer) kpiData.get('criticalOverdueCases');
        System.assertEquals(1, criticalOverdueCases, 'Deveria haver um caso crítico atrasado.');

        // Verifica se os casos por responsável estão corretos
        Map<String, Integer> casesByOwner = (Map<String, Integer>) kpiData.get('casesByOwner');
        System.assertNotEquals(null, casesByOwner, 'A lista de casos por responsável não deve ser nula.');
        System.assertEquals(2, casesByOwner.get(user1.Name), 'O Operador deveria ter dois casos atribuídos.');
        System.assertEquals(1, casesByOwner.get(user2.Name), 'O Administrador do Sistema deveria ter um caso atribuído.');
    }
}
