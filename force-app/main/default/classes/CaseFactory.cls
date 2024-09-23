public with sharing class CaseFactory extends AbstractFactory {

    private static CaseFactory instance = null;

    // Método estático para obter a instância única (Singleton)
    public static CaseFactory getFactory() {
        if (instance == null) {
            instance = new CaseFactory();
        }
        return instance;
    }

    // Método para criar um CaseBuilder
    public CaseBuilder createCase() {
        return new CaseBuilder();
    }

    // Método para obter o RecordTypeInfo
    public RecordTypeInfo fetchRecordTypeInfo(SObjectType sobj, String name) {
        return getRecordTypeInfo(sobj, name);
    }
}
