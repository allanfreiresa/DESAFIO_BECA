@IsTest
public class CountryRobotValidationHandlerTest {

    @TestSetup
    static void setup() {
        // Criação de robôs de exemplo
        Robo__c robo1 = new Robo__c(Name = 'Robo 1');
        Robo__c robo2 = new Robo__c(Name = 'Robo 2');
        insert new List<Robo__c> { robo1, robo2 };

        // Criação de países com robôs associados para teste de duplicidade
        Country__c country1 = new Country__c(Name = 'Brazil', Continent__c = 'América', Robot__c = robo1.Id);
        Country__c country2 = new Country__c(Name = 'Argentina', Continent__c = 'América', Robot__c = robo1.Id);
        insert new List<Country__c> { country1, country2 };
    }

    @IsTest
    static void testValidateDuplicateRobots_NoDuplicates() {
        // Criando uma lista de países sem duplicidade para validação
        Robo__c robo = [SELECT Id FROM Robo__c WHERE Name = 'Robo 1' LIMIT 1];
        Country__c country = new Country__c(Name = 'Chile', Continent__c = 'América', Robot__c = robo.Id);
        
        Test.startTest();
        CountryRobotValidationHandler.validateDuplicateRobots(new List<Country__c> { country });
        Test.stopTest();

        // Verifica se nenhum erro foi adicionado ao registro
        System.assertEquals(false, country.hasErrors(), 'Não deveria haver erros para registros sem duplicidade.');
    }

    @IsTest
    static void testValidateDuplicateRobots_DuplicateInDatabase() {
        // Criação de um país que já existe no banco de dados para verificar duplicidade
        Robo__c robo = [SELECT Id FROM Robo__c WHERE Name = 'Robo 1' LIMIT 1];
        Country__c duplicateCountry = new Country__c(Name = 'Brazil', Continent__c = 'América', Robot__c = robo.Id);

        Test.startTest();
        CountryRobotValidationHandler.validateDuplicateRobots(new List<Country__c> { duplicateCountry });
        Test.stopTest();

        // Verifica se o erro de duplicidade foi adicionado ao registro
        System.assertEquals(true, duplicateCountry.hasErrors(), 'Deveria ter ocorrido um erro de duplicidade no banco de dados.');
        System.assert(duplicateCountry.getErrors()[0].getMessage().contains('Não é permitido associar o mesmo Robô ao mesmo País e Continente.'),
                      'A mensagem de erro esperada não foi retornada.');
    }

    @IsTest
    static void testValidateDuplicateRobots_DuplicateInExecution() {
        // Criação de dois países com a mesma combinação de robô e localização para testar duplicidade na execução atual
        Robo__c robo = [SELECT Id FROM Robo__c WHERE Name = 'Robo 1' LIMIT 1];
        Country__c country1 = new Country__c(Name = 'Peru', Continent__c = 'América', Robot__c = robo.Id);
        Country__c country2 = new Country__c(Name = 'Peru', Continent__c = 'América', Robot__c = robo.Id);

        Test.startTest();
        CountryRobotValidationHandler.validateDuplicateRobots(new List<Country__c> { country1, country2 });
        Test.stopTest();

        // Verifica se o erro de duplicidade foi adicionado ao registro
        System.assertEquals(true, country2.hasErrors(), 'Deveria ter ocorrido um erro de duplicidade na execução atual.');
        System.assert(country2.getErrors()[0].getMessage().contains('Este robô já está associado a este país e continente.'),
                      'A mensagem de erro esperada não foi retornada.');
    }
}
