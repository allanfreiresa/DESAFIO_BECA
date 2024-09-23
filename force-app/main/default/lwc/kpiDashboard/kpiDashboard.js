import { LightningElement, track, wire } from 'lwc';
import getKpiData from '@salesforce/apex/KpiDashboardController.getKpiData';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { refreshApex } from '@salesforce/apex';

export default class KpiDashboard extends LightningElement {
    @track totalOpenCases = 0;
    @track overdueCases = 0;
    @track criticalOverdueCases = 0;
    @track casesByOwner = ''; // Mudar para string para exibição
    @track criticalCasesClass = 'kpi-value';
    subscription = null;
    channelName = '/data/CaseChangeEvent';
    wiredKpiDataResult;

    connectedCallback() {
        this.subscribeToCaseChanges();
    }

    disconnectedCallback() {
        this.unsubscribeFromCaseChanges();
    }

    subscribeToCaseChanges() {
        subscribe(this.channelName, -1, (message) => {
            try {
                console.log('Received Case Change Event: ', message);
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

    refreshData() {
        try {
            console.log('Refreshing data...');
            refreshApex(this.wiredKpiDataResult)
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

    @wire(getKpiData)
    wiredKpiData(result) {
        this.wiredKpiDataResult = result;
        const { error, data } = result;
        if (data) {
            this.totalOpenCases = data.totalOpenCases;
            this.overdueCases = data.overdueCases;
            this.criticalOverdueCases = data.criticalOverdueCases;

            // Formatar casesByOwner para exibição
            this.casesByOwner = Object.keys(data.casesByOwner).map(key => {
                return `${key}: ${data.casesByOwner[key]}`;
            }).join('\n');

            this.criticalCasesClass = this.criticalOverdueCases > 0 ? 'kpi-value critical' : 'kpi-value';
        } else if (error) {
            console.error('Error fetching KPI data:', error);
        }
    }

    get criticalClass() {
        return this.criticalOverdueCases > 0 ? 'kpi-box critical' : 'kpi-box';
    }

    get criticalStyle() {
        return this.criticalOverdueCases > 0 ? 'color: red;' : '';
    }
}
