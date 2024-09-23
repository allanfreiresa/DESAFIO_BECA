import { LightningElement, wire, track } from 'lwc';
import getClientsWithSlaViolations from '@salesforce/apex/SlaViolationController.getClientsWithSlaViolations';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { refreshApex } from '@salesforce/apex'; // Importando o refreshApex para atualização dos dados

export default class SlaViolationRank extends LightningElement {
    @track slaViolations = [];
    clientsWithViolations = [];
    error;
    subscription = null;
    channelName = '/data/CaseChangeEvent'; // Nome do canal CDC
    wiredSolicitationCasesResult; // Variável para armazenar o resultado da chamada @wire

    columns = [
        { label: 'Cliente', fieldName: 'clientName', type: 'text', wrapText: true },
        { label: 'Número do Chamado', fieldName: 'caseNumber', type: 'text', wrapText: true },
        {
            label: 'Prioridade',
            fieldName: 'prioridade',
            type: 'text',
            wrapText: true,
            cellAttributes: {
                class: { fieldName: 'priorityClass' }
            }
        },
        { label: 'SLA (Horas)', fieldName: 'slaHours', type: 'text', wrapText: true, cellAttributes: { alignment: 'center' } },
        { label: 'Data de Abertura', fieldName: 'createdDate', type: 'date', wrapText: true },
        { label: 'Data de Vencimento', fieldName: 'dataVencida', type: 'datetime', wrapText: true },
        { label: 'Robô', fieldName: 'robotName', type: 'text', wrapText: true },
        { label: 'Responsável', fieldName: 'responsavel', type: 'text', wrapText: true },
    ];

    connectedCallback() {
        this.subscribeToCaseChanges();
    }

    disconnectedCallback() {
        this.unsubscribeFromCaseChanges();
    }

    subscribeToCaseChanges() {
        subscribe(this.channelName, -1, (message) => {
            try {
                console.log('SLA VIOLATION Received Case Change Event: ', message);
                this.refreshData();
            } catch (error) {
                console.error('Error handling Case Change Event: ', error);
            }
        }).then((response) => {
            console.log('Subscribed to Case Change Event: ', response);
            this.subscription = response;
        }).catch((error) => {
            console.error('Error subscribing to Case Change Event: ', error);
        });

        onError((error) => {
            console.error('Error on channel subscription:', error);
        });
    }

    unsubscribeFromCaseChanges() {
        if (this.subscription) {
            unsubscribe(this.subscription, (response) => {
                console.log('Unsubscribed from Case Change Event:', response);
            });
        }
    }

    @wire(getClientsWithSlaViolations)
    wiredCases(result) {
        this.wiredSolicitationCasesResult = result; // Armazenando o resultado para usar com refreshApex
        const { error, data } = result;
        if (data) {
            console.log('Initial Data Fetch:', data);
            this.updateClientViolations(data);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.clientsWithViolations = [];
        }
    }

    updateClientViolations(data) {
        // Atualiza a lista de violações de clientes com reatividade
        this.clientsWithViolations = data.map(record => {
            let priorityClass = '';
            switch (record.prioridade) {
                case 'High':
                    priorityClass = 'slds-text-color_error';
                    break;
                case 'Medium':
                    priorityClass = 'custom-medium-text';
                    break;
                case 'Low':
                    priorityClass = 'slds-text-color_success';
                    break;
            }
            return { ...record, priorityClass };
        });
        this.slaViolations = [...this.clientsWithViolations];
    }

    refreshData() {
        try {
            console.log('Refreshing data...');
            // Usando refreshApex para forçar a atualização dos dados
            refreshApex(this.wiredSolicitationCasesResult)
                .then(() => {
                    console.log('Data refreshed successfully.');
                })
                .catch((error) => {
                    console.error('Error refreshing data:', error);
                });
        } catch (error) {
            console.error('Error during data refresh:', error);
        }
    }
}
