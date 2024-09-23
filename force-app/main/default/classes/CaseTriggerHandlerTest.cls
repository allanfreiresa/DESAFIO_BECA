@IsTest
public class CaseTriggerHandlerTest {

    @TestSetup
    static void setup() {
        // Criação de uma conta de teste
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Criação de casos de teste usando CaseFactory e CaseBuilder com valores de SLA ajustados automaticamente
        Case caseWithMediumPriority = CaseFactory.getFactory()
            .createCase()
            .account(testAccount)
            .status('New')
            .priority('Medium')
            .calculatedSLA('8') // Ajusta o SLA corretamente com base na prioridade Medium
            .subject('Test Case with Medium Priority')
            .get();

        // Inserção do caso criado
        insert caseWithMediumPriority;
    }

    @IsTest
    static void testPreventInvalidCloningForRestrictedProfile() {
        // Consulta o caso de teste criado na configuração
        Case originalCase = [SELECT Id, AccountId, CalculatedSLA__c, Priority FROM Case LIMIT 1];

        // Clonagem do caso para simular a inserção de um caso clonado
        Case clonedCase = originalCase.clone(false, false, false, false);
        clonedCase.Id = null; // Limpa o ID para simular um novo registro
        clonedCase.CalculatedSLA__c = originalCase.CalculatedSLA__c; // Reatribui o valor do campo SLA para garantir que é um valor válido

        // Consulta um usuário existente com o perfil "Minimum Access - Salesforce"
        User restrictedUser;
        try {
            restrictedUser = [SELECT Id FROM User WHERE Profile.Name = 'Minimum Access - Salesforce' LIMIT 1];
        } catch (Exception e) {
            System.assert(false, 'Usuário com o perfil "Minimum Access - Salesforce" não encontrado. Verifique se o perfil e o usuário existem.');
        }

        // Simula o comportamento do usuário com perfil restrito
        Test.startTest();
        System.runAs(restrictedUser) {
            try {
                // Tenta inserir o caso clonado e espera que a inserção falhe
                insert clonedCase;
                System.debug('usuario restrito ' + clonedCase);
                System.assert(false, 'A inserção deveria ter falhado com um erro de permissão.');
            } catch (DmlException e) {
                // Verifica se a mensagem de erro é a esperada
                System.assert(e.getMessage().contains('Você não tem permissão para clonar este tipo de registro.'), 
                    'A mensagem de erro esperada não foi retornada.');

                    System.debug(e);
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testAllowCreationForDifferentProfile() {
        // Consulta o caso de teste criado na configuração
        Case originalCase = [SELECT Id, AccountId, CalculatedSLA__c, Priority FROM Case LIMIT 1];

        // Clonagem do caso para simular a inserção de um caso clonado
        Case clonedCase = originalCase.clone(false, false, false, false);
        clonedCase.Id = null; // Limpa o ID para simular um novo registro
        clonedCase.CalculatedSLA__c = originalCase.CalculatedSLA__c; // Reatribui o valor do campo SLA para garantir que é um valor válido

        // Consulta um usuário existente com perfil que não é restrito (por exemplo, "Administrador")
        User nonRestrictedUser = [SELECT Id FROM User WHERE Id = '005aj000007lKyXAAU' LIMIT 1];

        // Verifica se o usuário existe
        System.assertNotEquals(null, nonRestrictedUser, 'Usuário não encontrado para o teste com perfil diferente.');

        // Simula o comportamento do usuário com perfil não restrito
        Test.startTest();
        System.runAs(nonRestrictedUser) {
            // Tenta inserir o caso clonado, que deve ser permitido
            insert clonedCase;
            System.debug('usuario NAO restrito ' + clonedCase);
            // Consulta para verificar se o caso foi inserido corretamente
            Case insertedCase = [SELECT Id FROM Case WHERE Id = :clonedCase.Id];
            System.assertNotEquals(null, insertedCase, 'O caso deveria ser inserido sem problemas.');

            System.debug('RESULTADO CLONE ' + insertedCase);
        }
        Test.stopTest();
    }
}
