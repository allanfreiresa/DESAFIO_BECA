@IsTest
public class CaseMonitorControllerTest {

    @TestSetup
    static void setup() {
        // Criação de uma conta de teste para associar aos cases
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Usando CaseBuilder e CaseFactory para criar os casos de teste com diferentes Record Types
        Case solicitacaoCase = CaseFactory.getFactory()
            .createCase()
            .account(testAccount)
            .recordType('Request')
            .status('New')
            .priority('Medium')
            .calculatedSLA('8')
            .subject('Solicitação de Teste')
            .get();  // Correção: o retorno de get() é um Case, não um CaseBuilder
        
        Case instalacaoCase = CaseFactory.getFactory()
            .createCase()
            .account(testAccount)
            .recordType('Installation')
            .status('New')
            .priority('High')
            .calculatedSLA('4')
            .subject('Instalação de Teste')
            .get();  // Correção: o retorno de get() é um Case, não um CaseBuilder

        Case suporteCase = CaseFactory.getFactory()
            .createCase()
            .account(testAccount)
            .recordType('Support')
            .status('New')
            .priority('Low')
            .calculatedSLA('24')
            .subject('Suporte de Teste')
            .get();  // Correção: o retorno de get() é um Case, não um CaseBuilder

        // Inserção dos casos criados
        insert new List<Case> { solicitacaoCase, instalacaoCase, suporteCase };
    }

    @IsTest
    static void testGetSolicitacaoCases() {
        // Inicia o teste isolado
        Test.startTest();
        // Chama o método para buscar os Cases do tipo 'Solicitação'
        List<Case> solicitacaoCases = CaseMonitorController.getSolicitacaoCases();
        Test.stopTest();

        // Verifica se o caso foi retornado corretamente
        System.assert(!solicitacaoCases.isEmpty(), 'A lista de casos de solicitação não deve estar vazia.');
        System.assertEquals('Solicitação', solicitacaoCases[0].RecordType.Name, 'O RecordType deve ser Solicitação.');
    }

    @IsTest
    static void testGetInstalacaoCases() {
        // Inicia o teste isolado
        Test.startTest();
        // Chama o método para buscar os Cases do tipo 'Instalação'
        List<Case> instalacaoCases = CaseMonitorController.getInstalacaoCases();
        Test.stopTest();

        // Verifica se o caso foi retornado corretamente
        System.assert(!instalacaoCases.isEmpty(), 'A lista de casos de instalação não deve estar vazia.');
        System.assertEquals('Instalação', instalacaoCases[0].RecordType.Name, 'O RecordType deve ser Instalação.');
    }

    @IsTest
    static void testGetSuporteCases() {
        // Inicia o teste isolado
        Test.startTest();
        // Chama o método para buscar os Cases do tipo 'Suporte'
        List<Case> suporteCases = CaseMonitorController.getSuporteCases();
        Test.stopTest();

        // Verifica se o caso foi retornado corretamente
        System.assert(!suporteCases.isEmpty(), 'A lista de casos de suporte não deve estar vazia.');
        System.assertEquals('Suporte', suporteCases[0].RecordType.Name, 'O RecordType deve ser Suporte.');
    }
}
