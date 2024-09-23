trigger CountryRobotTrigger on Country__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            // Chama o handler para validar duplicidade de robôs no objeto País
            System.debug('Chamando o handler de validação para verificar duplicidades.');
            CountryRobotValidationHandler.validateDuplicateRobots(Trigger.new);
        }
    }
}
