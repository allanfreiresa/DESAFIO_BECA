public class CountryRobotValidationHandler {
    
    // Método para validar duplicidade de robôs no mesmo país e continente
    public static void validateDuplicateRobots(List<Country__c> countries) {
        // Map para armazenar combinações únicas de País, Robô e Continente
        Map<String, Country__c> robotMap = new Map<String, Country__c>();
        System.debug('Iniciando validação de duplicidade para Países. Total de registros recebidos: ' + countries.size());

        // Itera sobre os registros que estão sendo inseridos ou atualizados
        for (Country__c country : countries) {
            // Criando uma chave única para identificar cada combinação
            String key = country.Robot__c + '-' + country.Name + '-' + country.Continent__c;
            System.debug('Verificando País: ' + country.Name);
            System.debug('Chave única criada para o País e Robô: ' + key);

            // Verifica se a combinação já existe no banco de dados
            List<Country__c> existingCountries = [SELECT Id FROM Country__c 
                                                  WHERE Robot__c = :country.Robot__c 
                                                  AND Name = :country.Name 
                                                  AND Continent__c = :country.Continent__c 
                                                  LIMIT 1];
            System.debug('Consulta ao banco de dados executada. Total de combinações encontradas: ' + existingCountries.size());

            // Se a combinação existir, retorna um erro
            if (!existingCountries.isEmpty()) {
                System.debug('Duplicidade encontrada no banco de dados para o Robô: ' + country.Robot__c + ' no País: ' + country.Name);
                country.addError('Não é permitido associar o mesmo Robô ao mesmo País e Continente.');
            } else {
                // Se a combinação ainda não existir, adiciona ao map
                if (robotMap.containsKey(key)) {
                    System.debug('Duplicidade encontrada na execução atual para a chave: ' + key);
                    country.addError('Este robô já está associado a este país e continente.');
                } else {
                    System.debug('Adicionando combinação ao map para controle de duplicidade: ' + key);
                    robotMap.put(key, country);
                }
            }
        }
        System.debug('Validação de duplicidade concluída.');
    }
}
