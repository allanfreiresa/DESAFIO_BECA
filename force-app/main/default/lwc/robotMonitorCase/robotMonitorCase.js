import { LightningElement, wire, track } from 'lwc';
import getSolicitacaoCases from '@salesforce/apex/CaseMonitorController.getSolicitacaoCases';
import getInstalacaoCases from '@salesforce/apex/CaseMonitorController.getInstalacaoCases';
import getSuporteCases from '@salesforce/apex/CaseMonitorController.getSuporteCases';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { subscribe, unsubscribe } from 'lightning/empApi';

export default class RobotMonitorCase extends NavigationMixin(LightningElement) {
    @track solicitationCases = [];
    @track installationCases = [];
    @track supportCases = [];

    @track filteredSolicitationCases = [];
    @track filteredInstallationCases = [];
    @track filteredSupportCases = [];

    wiredSolicitationCasesResult;
    wiredInstallationCasesResult;
    wiredSupportCasesResult;
    subscription = {};

    @track solicitacaoColumns = [
        { label: 'Chamado', fieldName: 'CaseNumber', type: 'text', wrapText: true },
        { label: 'Cliente', fieldName: 'AccountName', type: 'text', wrapText: true },
        { label: 'Status', fieldName: 'Status', type: 'text' },
        { label: 'Tipo', fieldName: 'Type', type: 'text', wrapText: true },
        { label: 'Prioridade', fieldName: 'Priority', type: 'text', wrapText: true },
        { label: 'SLA', fieldName: 'CalculatedSLA__c', type: 'text', wrapText: true, cellAttributes: { alignment: 'center' } },
        { label: 'Assunto', fieldName: 'Subject', type: 'text', wrapText: true },
        { label: 'Descrição', fieldName: 'Description', type: 'text', wrapText: true },
        { label: 'Responsável', fieldName: 'OwnerName', type: 'text', wrapText: true },
        { label: 'Data de Criação', fieldName: 'CreatedDate', type: 'datetime',  wrapText: true,typeAttributes: { year: "numeric", month: "long", day: "2-digit", hour: "2-digit", minute: "2-digit", second: "2-digit", hour12: false } },
        { type: 'action', typeAttributes: { rowActions: [{ label: 'View', name: 'view' }] } }
    ];

    @track instalacaoColumns = [
        { label: 'Chamado', fieldName: 'CaseNumber', type: 'text', wrapText: true },
        { label: 'Cliente', fieldName: 'AccountName', type: 'text', wrapText: true },
        { label: 'Status', fieldName: 'Status', type: 'text' },
        { label: 'Tipo', fieldName: 'Type', type: 'text' },
        { label: 'Prioridade', fieldName: 'Priority', type: 'text', wrapText: true },
        { label: 'SLA', fieldName: 'CalculatedSLA__c', type: 'text', wrapText: true, cellAttributes: { alignment: 'center' } },
        { label: 'Assunto', fieldName: 'Subject', type: 'text', wrapText: true },
        { label: 'Descrição', fieldName: 'Description', type: 'text', wrapText: true },
        { label: 'Produto', fieldName: 'Product__c', type: 'text', wrapText: true },
        { label: 'Nome Robô', fieldName: 'RobotName', type: 'text', wrapText: true },
        { label: 'Responsável', fieldName: 'OwnerName', type: 'text', wrapText: true },
        { label: 'Técnico de Suporte', fieldName: 'SupportTechnicianName', type: 'text', wrapText: true },
        { label: 'Data de Criação', fieldName: 'CreatedDate', type: 'datetime', wrapText: true, typeAttributes: { year: "numeric", month: "long", day: "2-digit", hour: "2-digit", minute: "2-digit", second: "2-digit", hour12: false } },
        { type: 'action', typeAttributes: { rowActions: [{ label: 'View', name: 'view' }] } }
    ];

    @track suporteColumns = [
        { label: 'Chamado', fieldName: 'CaseNumber', type: 'text', wrapText: true },
        { label: 'Cliente', fieldName: 'AccountName', type: 'text', wrapText: true },
        { label: 'Status', fieldName: 'Status', type: 'text' },
        { label: 'Tipo', fieldName: 'Type', type: 'text', wrapText: true },
        { label: 'Prioridade', fieldName: 'Priority', type: 'text', wrapText: true },
        { label: 'SLA', fieldName: 'CalculatedSLA__c', type: 'text', wrapText: true, cellAttributes: { alignment: 'center' } },
        { label: 'Assunto', fieldName: 'Subject', type: 'text', wrapText: true },
        { label: 'Descrição', fieldName: 'Description', type: 'text', wrapText: true },
        { label: 'Nome Robô', fieldName: 'RobotName', type: 'text', wrapText: true },
        { label: 'Técnico', fieldName: 'SupportTechnicianName', type: 'text', wrapText: true },
        { label: 'Responsável', fieldName: 'OwnerName', type: 'text', wrapText: true },
        { label: 'Data de Criação', fieldName: 'CreatedDate', type: 'datetime', wrapText: true, typeAttributes: { year: "numeric", month: "long", day: "2-digit", hour: "2-digit", minute: "2-digit", second: "2-digit", hour12: false } },
        { type: 'action', typeAttributes: { rowActions: [{ label: 'View', name: 'view' }] } }
    ];

    @wire(getSolicitacaoCases)
    wiredSolicitationCases(result) {
        this.wiredSolicitationCasesResult = result;
        const { data, error } = result;
        if (data) {
            try {
                this.solicitationCases = data.map(caseRecord => ({
                    ...caseRecord,
                    AccountName: caseRecord.Account?.Name ?? '',
                    OwnerName: caseRecord.Owner?.Name ?? '',
                    CreatedDate: caseRecord.CreatedDate
                }));
                this.filteredSolicitationCases = [...this.solicitationCases];
            } catch (err) {
                console.error('Error processing Solicitation Cases:', err);
            }
        } else if (error) {
            console.error('Error fetching Solicitation Cases:', error);
        }
    }

    @wire(getInstalacaoCases)
    wiredInstallationCases(result) {
        this.wiredInstallationCasesResult = result;
        const { data, error } = result;
        if (data) {
            try {
                this.installationCases = data.map(caseRecord => ({
                    ...caseRecord,
                    AccountName: caseRecord.Account?.Name ?? '',
                    RobotName: caseRecord.Robot__r?.Name ?? '',
                    OwnerName: caseRecord.Owner?.Name ?? '',
                    SupportTechnicianName: caseRecord.SupportTechnician__r?.LastName ?? '',
                    CreatedDate: caseRecord.CreatedDate
                }));
                this.filteredInstallationCases = [...this.installationCases];
            } catch (err) {
                console.error('Error processing Installation Cases:', err);
            }
        } else if (error) {
            console.error('Error fetching Installation Cases:', error);
        }
    }

    @wire(getSuporteCases)
    wiredSupportCases(result) {
        this.wiredSupportCasesResult = result;
        const { data, error } = result;
        if (data) {
            try {
                this.supportCases = data.map(caseRecord => ({
                    ...caseRecord,
                    AccountName: caseRecord.Account?.Name ?? '',
                    RobotName: caseRecord.Robot__r?.Name ?? '',
                    OwnerName: caseRecord.Owner?.Name ?? '',
                    SupportTechnicianName: caseRecord.SupportTechnician__r?.LastName ?? '',
                    CreatedDate: caseRecord.CreatedDate
                }));
                this.filteredSupportCases = [...this.supportCases];
            } catch (err) {
                console.error('Error processing Support Cases:', err);
            }
        } else if (error) {
            console.error('Error fetching Support Cases:', error);
        }
    }

    connectedCallback() {
        this.subscribeToCaseChanges();
    }

    disconnectedCallback() {
        this.unsubscribeFromCaseChanges();
    }

    subscribeToCaseChanges() {
        const channel = '/data/CaseChangeEvent';
        subscribe(channel, -1, (message) => {
            try {
                this.refreshData();
            } catch (error) {
                console.error('Error handling Case Change Event:', error);
            }
        }).then((response) => {
            this.subscription = response;
        }).catch((error) => {
            console.error('Error subscribing to Case Change Event:', error);
        });
    }

    unsubscribeFromCaseChanges() {
        unsubscribe(this.subscription, response => {
            console.log('Unsubscribed from Case Change Event:', response);
        });
    }

    refreshData() {
        try {
            refreshApex(this.wiredSolicitationCasesResult);
            refreshApex(this.wiredInstallationCasesResult);
            refreshApex(this.wiredSupportCasesResult);
        } catch (error) {
            console.error('Error refreshing data:', error);
        }
    }

    // Funções de busca (incluindo CreateDate nas buscas)
    handleSolicitacaoSearch(event) {
        const searchKey = event.target.value.toLowerCase();
        this.filteredSolicitationCases = this.solicitationCases.filter(caseRecord =>
            (caseRecord.CaseNumber?.toLowerCase().includes(searchKey)) ||
            (caseRecord.AccountName?.toLowerCase().includes(searchKey)) ||
            (caseRecord.CreatedDate && caseRecord.CreatedDate.toLowerCase().includes(searchKey))
        );
    }

    handleInstalacaoSearch(event) {
        const searchKey = event.target.value.toLowerCase();
        this.filteredInstallationCases = this.installationCases.filter(caseRecord =>
            (caseRecord.CaseNumber?.toLowerCase().includes(searchKey)) ||
            (caseRecord.AccountName?.toLowerCase().includes(searchKey)) ||
            (caseRecord.InstallationDetails__c?.toLowerCase().includes(searchKey)) ||
            (caseRecord.Type?.toLowerCase().includes(searchKey)) ||
            (caseRecord.Priority?.toLowerCase().includes(searchKey)) ||
            (caseRecord.Subject?.toLowerCase().includes(searchKey)) ||
            (caseRecord.Description?.toLowerCase().includes(searchKey)) ||
            (caseRecord.RobotName?.toLowerCase().includes(searchKey)) ||
            (caseRecord.OwnerName?.toLowerCase().includes(searchKey)) ||
            (caseRecord.CreatedDate && caseRecord.CreatedDate.toLowerCase().includes(searchKey))
        );
    }

    handleSuporteSearch(event) {
        const searchKey = event.target.value.toLowerCase();
        this.filteredSupportCases = this.supportCases.filter(caseRecord =>
            (caseRecord.CaseNumber?.toLowerCase().includes(searchKey)) ||
            (caseRecord.AccountName?.toLowerCase().includes(searchKey)) ||
            (caseRecord.Type?.toLowerCase().includes(searchKey)) ||
            (caseRecord.Priority?.toLowerCase().includes(searchKey)) ||
            (caseRecord.Subject?.toLowerCase().includes(searchKey)) ||
            (caseRecord.Description?.toLowerCase().includes(searchKey)) ||
            (caseRecord.RobotName?.toLowerCase().includes(searchKey)) ||
            (caseRecord.OwnerName?.toLowerCase().includes(searchKey)) ||
            (caseRecord.CreatedDate && caseRecord.CreatedDate.toLowerCase().includes(searchKey))
        );
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'view') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.Id,
                    actionName: 'view'
                }
            });
        }
    }
}
