// CaseMonitorController.cls
public with sharing class CaseMonitorController {
    @AuraEnabled(cacheable=true)
    public static List<Case> getSolicitacaoCases() {
        Schema.RecordType solicitacaoType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Solicitação' LIMIT 1];
        return [
            
            SELECT Id, CaseNumber, Account.Name, Status, Type, Priority, CalculatedSLA__c, Subject,Description,Owner.Name,RecordType.Name, CreatedDate
            FROM Case
            WHERE RecordTypeId = :solicitacaoType.Id
            AND Status != 'Closed'
            ORDER BY CaseNumber DESC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Case> getInstalacaoCases() {
        Schema.RecordType instalacaoType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Instalação' LIMIT 1];
        return [
            SELECT Id, CaseNumber, Account.Name,Status, InstallationDetails__c, Type, Priority, CalculatedSLA__c, Subject,Description,
            Product__c,RobotsLocation__c,Robot__r.Name,Origin,SupportTechnician__r.LastName,Owner.Name,RecordType.Name, CreatedDate
            FROM Case            
            WHERE RecordTypeId = :instalacaoType.Id
            AND Status != 'Closed'
            ORDER BY CaseNumber DESC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Case> getSuporteCases() {
        Schema.RecordType suporteType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Suporte' LIMIT 1];
        return [
            SELECT Id, CaseNumber, Account.Name, Status,Type, Priority, CalculatedSLA__c, Subject,Description,
            Robot__r.Name,Origin,SupportTechnician__r.LastName,Owner.Name ,RecordType.Name, CreatedDate                   
            FROM Case
            WHERE RecordTypeId = :suporteType.Id
            AND Status != 'Closed'
            ORDER BY CaseNumber DESC
        ];
    }
}
