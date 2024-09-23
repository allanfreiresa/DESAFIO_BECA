public class CaseTriggerHandler {
    public static void preventInvalidCloning(List<Case> newCases) {
        // Recupera o nome do perfil do usuário logado
        String currentProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        
        // Se o perfil é o que precisa ser restrito
        if (currentProfileName == 'Minimum Access - Salesforce') {
            for (Case c : newCases) {                
                if (Trigger.isInsert && c.CreatedDate == null) {  
                    // Exibe uma mensagem de erro, bloqueando a criação se for clonado
                    c.addError('Você não tem permissão para clonar este tipo de registro.');
                }
            }
        }
    }
}
