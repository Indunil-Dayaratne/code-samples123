<template>
    <b-card no-body>
        <b-card-body>
            <b-container>
                
                <b-row class="mb-2">
                    <b-col md="6" class="d-flex align-items-center">
                        {{lastUpdateText}}
                        <span class="pl-1">{{countdownText}}</span>
                    </b-col>
                    <b-col class="d-flex justify-content-end align-items-center">
                        <span>Average change over: </span>
                    </b-col>
                    <b-col md="2">
                        <b-select v-model="calculateRateForSeconds" :options="selectRateOptions" @change="updateLengthChanges"></b-select>
                    </b-col>
                </b-row>
                <b-row>
                    <b-col>
                        <b-table :fields="fields"
                            :items="response.queues"
                            sort-by="messageCount"
                            :sort-desc="true"
                            striped hover bordered>
                            <template v-slot:cell(ragStatus)="data">
                                <span :class="['queue-rag-light', data.item.ragStatus]"></span>
                            </template>
                            <template v-slot:cell(change)="data">
                                <span :class="getRateClass(data.item.name)">
                                    <fa-icon v-if="data.item.change > 0" icon="angle-up"></fa-icon>
                                    <fa-icon v-else-if="data.item.change < 0" icon="angle-down"></fa-icon>
                                    <fa-icon v-else icon="angle-left" class="queue-rate"></fa-icon>
                                    {{ Math.abs(data.item.change).toFixed(1) }} /min
                                </span>
                                
                            </template>
                        </b-table>
                    </b-col>
                </b-row>
            </b-container>
        </b-card-body>
    </b-card>
</template>

<script>
    import moment from 'moment';
    import api from '../../shared/api';
    export default {
        data() {
            return {
                requestIntervalSecs: 10,
                secondsUntilNextRequest: 0,
                lastRequestTime: null,
                requestInProgress: false,
                fields: [
                    { key: 'ragStatus', label: 'Status', sortable: true },
                    { key: 'messageCount', label: 'Queue length', sortable: true },
                    { key: 'change', label: 'Change', sortable: true },
                    { key: 'userFriendlyName', label: 'Name', sortable: true }
                ],
                response: {
                    requestTime: null,
                    queues: []
                },
                requestPoll: 0,
                countdownPoll: 0,
                lengthChanges: {

                },
                calculateRateForSeconds: 60,
                selectRateOptions: [
                    { value: 30, text: '30 secs' },
                    { value: 60, text: '1 min' },
                    { value: 120, text: '2 mins' },
                    { value: 300, text: '5 mins' },
                    { value: 600, text: '10 mins' }
                ]
            }
        },
        computed: {
            lastUpdateText() {
                if(!this.lastRequestTime) return "";
                return `Last update: ${moment(this.lastRequestTime).format(config.dateFormat)}`;
            },
            countdownText() {
                if(this.requestInProgress) return "- Updating...";
                if(this.secondsUntilNextRequest > 5) return "";
                if(this.secondsUntilNextRequest < 0) return "- Update pending..."
                return `- Update in ${this.secondsUntilNextRequest}s...`
            },
            requestsPerMinute() {
                return Math.floor(60 / this.requestIntervalSecs);
            },
            requestsToIncludeInRateCalculation() {
                return Math.floor(this.requestsPerMinute * this.calculateRateForSeconds / 60);
            }
        },
        methods: {
            async updateData() {
                this.requestInProgress = true;
                clearInterval(this.countdownPoll);
                this.response = await api.getQueueStatus();
                this.updateLengthChanges();
                this.lastRequestTime = new Date();
                this.requestPoll = setTimeout(this.updateData, this.requestIntervalSecs * 1000);
                this.updateCountDown();
                this.countdownPoll = setInterval(this.updateCountDown, 1000)
                this.requestInProgress = false;
            },
            updateCountDown() {
                this.secondsUntilNextRequest = moment(this.lastRequestTime).add(this.requestIntervalSecs, 'seconds').diff(moment(), 'seconds');
            },
            updateLengthChanges() {
                for (let i = 0; i < this.response.queues.length; i++) {
                    const queue = this.response.queues[i];
                    if(!this.lengthChanges[queue.name]) this.$set(this.lengthChanges, queue.name, { previousValue: queue.messageCount, changes: [] });
                    const queueChange = this.lengthChanges[queue.name];
                    queueChange.changes.push(queue.messageCount - queueChange.previousValue);
                    queueChange.previousValue = queue.messageCount;
                    this.$set(queue, 'change', this.getAverageChange(queue.name))
                }
            },
            getAverageChange(queueName) {
                const queueChange = this.lengthChanges[queueName]; 
                if(!queueChange) return 0;
                const availableRequests = Math.min(queueChange.changes.slice(-this.requestsToIncludeInRateCalculation).length, this.requestsToIncludeInRateCalculation);
                return (this.requestsPerMinute * queueChange.changes.slice(-this.requestsToIncludeInRateCalculation).reduce((a, b) => a + b, 0) / availableRequests) || 0; 
            },
            getRateClass(queueName) {
                const rate = this.getAverageChange(queueName);
                if(rate > 0) return "queue-rate increase";
                if(rate < 0) return "queue-rate decrease";
                else return "queue-rate";
            }
        },
        mounted() {
            this.updateData();
        },
        destroyed() {
            clearTimeout(this.requestPoll);
            clearInterval(this.countdownPoll);
        },
    }
</script>

<style lang="scss" scoped>
.queue-rag-light {
    height: 20px;
    width: 20px;
    background-color: grey;
    border-radius: 50%;
    display: inline-block;

    &.red {
        background-color: red;
    }

    &.amber {
        background-color: orange;
    }

    &.green {
        background-color: green;
    }
}

.queue-rate {
    &.increase {
        color: red;
    }
    &.decrease {
        color: green;
    }
}
</style>