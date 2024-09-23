trigger CasePreventClone on Case (before insert) {
    // Chama o handler para executar a lógica
    CaseTriggerHandler.preventInvalidCloning(Trigger.new);
}
