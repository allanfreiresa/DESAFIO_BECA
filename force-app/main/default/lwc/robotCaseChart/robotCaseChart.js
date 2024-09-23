/* global Chart */

import { LightningElement, wire, track } from 'lwc';
import getRobotCaseCounts from '@salesforce/apex/RobotCaseController.getRobotCaseCounts';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { loadScript } from 'lightning/platformResourceLoader';
import { refreshApex } from '@salesforce/apex';
import chartJs from '@salesforce/resourceUrl/ChartJs'; // Certifique-se de que o nome aqui corresponde ao Static Resource

export default class RobotCaseChart extends LightningElement {
    chart;
    chartjsInitialized = false;
    error;
    chartData = [];
    subscription = null;
    channelName = '/data/CaseChangeEvent'; // Nome do canal CDC
    wiredCaseCountsResult; // Variável para armazenar o resultado da chamada @wire

    @wire(getRobotCaseCounts)
    wiredCaseCounts(result) {
        this.wiredCaseCountsResult = result; // Armazenando o resultado para usar com refreshApex
        const { error, data } = result;
        if (data) {
            this.chartData = data; // Armazena os dados para referência futura
            this.updateChart(); // Atualiza o gráfico com os dados
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }

    connectedCallback() {
        this.subscribeToCaseChanges();

        // Carrega o Chart.js quando o componente é conectado ao DOM
        if (!this.chartjsInitialized) {
            loadScript(this, chartJs)
                .then(() => {
                    // Verifique se o Chart.js foi carregado corretamente
                    if (typeof Chart === 'undefined') {
                        console.error('Chart.js não foi carregado corretamente');
                        return;
                    }
                    this.chartjsInitialized = true;
                    console.log('Chart.js carregado com sucesso');
                    this.updateChart(); // Tenta atualizar o gráfico após o carregamento do script
                })
                .catch(error => {
                    this.error = error;
                    console.error('Erro ao carregar o ChartJs:', error);
                });
        }
    }

    disconnectedCallback() {
        this.unsubscribeFromCaseChanges();

        // Destroi o gráfico ao desconectar o componente do DOM
        if (this.chart) {
            this.chart.destroy();
            this.chart = null;
        }
    }

    subscribeToCaseChanges() {
        subscribe(this.channelName, -1, (message) => {
            try {
                console.log('Received Case Change Event: ', message);
                this.refreshData(); // Chama o refresh quando um evento é recebido
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
            refreshApex(this.wiredCaseCountsResult) // Atualiza os dados do gráfico dinamicamente
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

    updateChart() {
        // Verifica se o Chart.js está carregado e se o canvas do gráfico está disponível
        if (!this.chartjsInitialized || !this.template.querySelector('canvas.chart')) {
            return; // Retorna se o script Chart.js não estiver carregado ou o canvas não estiver pronto
        }

        // Destroi o gráfico se ele já existir para evitar duplicação
        if (this.chart) {
            this.chart.destroy();
        }

        const ctx = this.template.querySelector('canvas.chart').getContext('2d');

        const labels = this.chartData.map(item => (item.robotName ? String(item.robotName) : 'N/A'));
        const caseCounts = this.chartData.map(item => (typeof item.caseCount === 'number' ? item.caseCount : 0));

        // Cria um novo gráfico com os dados
        this.chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Número de Chamados',
                    data: caseCounts,
                    backgroundColor: 'rgba(54, 162, 235, 0.6)'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }
}
