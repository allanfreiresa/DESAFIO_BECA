public with sharing abstract class AbstractFactory {
    
    // Método protegido que retorna RecordTypeInfo baseado no DeveloperName
    protected RecordTypeInfo getRecordTypeInfo(SObjectType sobj, String name) {
        RecordTypeInfo rt;
        try {
            rt = sobj.getDescribe().getRecordTypeInfosByDeveloperName().get(name);
            // Verifica se o RecordType foi encontrado
            System.assertNotEquals(null, rt, 'RecordType "' + name + '" não foi encontrado para ' + sobj.getDescribe().getName() + '.');
        } catch (Exception e) {
            System.debug('Exception caught: ' + e.getMessage());
        }
        return rt;
    }
}
