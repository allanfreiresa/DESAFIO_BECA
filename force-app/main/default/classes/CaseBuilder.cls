public with sharing class CaseBuilder {

    private Case caseRecord;

    // Construtor público
    public CaseBuilder() {
        this.caseRecord = new Case();
    }

    public CaseBuilder account(Account account) {
        this.caseRecord.AccountId = account.Id;
        return this;
    }

    public CaseBuilder recordType(String recordTypeName) {
        // Corrigido para chamar o método getFactory() corretamente
        RecordTypeInfo rtInfo = CaseFactory.getFactory().fetchRecordTypeInfo(Case.SObjectType, recordTypeName);
        System.assertNotEquals(null, rtInfo, 'RecordType "' + recordTypeName + '" não encontrado para Case.');
        this.caseRecord.RecordTypeId = rtInfo.getRecordTypeId();
        return this;
    }

    public CaseBuilder status(String status) {
        this.caseRecord.Status = status;
        return this;
    }

    public CaseBuilder priority(String priority) {
        this.caseRecord.Priority = priority;
        return this;
    }

    public CaseBuilder subject(String subject) {
        this.caseRecord.Subject = subject;
        return this;
    }

    public CaseBuilder calculatedSLA(String slaHours) {
        this.caseRecord.CalculatedSLA__c = slaHours;
        return this;
    }

    // Método para definir o proprietário (Owner) do caso
    public CaseBuilder owner(User owner) {
        this.caseRecord.OwnerId = owner.Id;
        return this;
    }

    public Case get() {
        return this.caseRecord;
    }
}
