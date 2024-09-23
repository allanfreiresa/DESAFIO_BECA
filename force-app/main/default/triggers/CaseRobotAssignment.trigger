trigger CaseRobotAssignment on Case (before insert, before update) {
    // Chama o método da classe handler para preencher o robô automaticamente
    CaseRobotHandler.assignRobotToCase(Trigger.new);
}
