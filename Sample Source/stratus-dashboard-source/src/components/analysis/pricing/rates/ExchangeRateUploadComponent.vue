<template>
    <b-container fluid>
        <b-row class="mb-3">
            <b-col>
                <h2>Exchange rates</h2>
            </b-col>
        </b-row>
        <b-row class="mb-3">
            <b-col>
                <b-form-file
                    v-model="file"
                    :state="fileState"
                    placeholder="Choose a file or drop it here..."
                    drop-placeholder="Drop file here..."
                    accept="text/csv">
                </b-form-file>
                <div style="min-height: 1em">{{parseErrorMsg}}</div>
            </b-col>
        </b-row>
        <b-row>
            <b-col>
                <b-button variant="primary"
                    @click="downloadRates">
                    Download current rates
                </b-button>
            </b-col>
            <b-col class="d-flex justify-content-end">
                <b-button variant="primary"
                    :disabled="!uploadData"
                    @click="uploadRates">
                    Upload exchange rates
                </b-button>
            </b-col>
        </b-row>
        <b-row>
            <b-col class="d-flex justify-content-end">
                <div style="font-size: 0.85em">
                    <em>This will affect all Graphene analyses</em>
                </div>
            </b-col>
        </b-row>
        <b-row>
            <b-col>
                <h4>Current exchange rates</h4>
                <b-table :fields="fields"
                    :items="currentRates"
                    striped hover>
                </b-table>
            </b-col>
            <b-col>
                <template v-if="!!uploadData">
                    <h4>Rates to upload</h4>
                    <b-table :fields="fields"
                        :items="uploadData"
                        striped hover>
                    </b-table>
                </template>
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
    import {mapState} from 'vuex';
    export default {
        name: 'ExchangeRateUploadComponent',
        data() {
            return {
                file: null,
                uploadData: null,
                parseErrorMsg: '',
                fields: [
                    { key: 'currency', label: 'Currency', sortable: true },
                    { key: 'rate', label: 'Rate' }
                ]
            }
        },
        computed: {
            ...mapState({
                currentRates: s => s.pricing.exchangeRates
            }),
            fileState() {
                return !!this.file && !this.parseErrorMsg;
            }
        },
        methods: {
            parseData() {
                this.reset();
                if(!this.file) return;

                this.$papa.parse(this.file, {
                    header: true,
                    complete: (results) => {
                        if(results.meta.fields.length !== 2 
                            || !results.meta.fields.includes('currency')
                            || !results.meta.fields.includes('rate')) {
                            this.parseErrorMsg = 'File must contain only columns \'currency\' and \'rate\'';
                            return;
                        }

                        this.uploadData = results.data;
                    },
                    error: (err) => {
                        this.parseErrorMsg = this.parseErrorMsg || err.message;
                    }
                })
            },
            async uploadRates() {
                let rates = this.$papa.unparse(this.uploadData, {
                    columns: ['currency', 'rate'],
                    quotes: [true, false]
                })
                await this.$store.dispatch('pricing/uploadExchangeRates', rates);
                this.reset();
                this.file = null;
            },
            downloadRates() {
                let csv = this.$papa.unparse(this.currentRates);
                this.$papa.download(csv, "current_rates");
            },
            reset() {
                this.parseErrorMsg = '';
                this.uploadData = null;
            }
        },  
        watch: {
            file(newValue, oldValue) {
                this.parseData();
            }
        },  
    }
</script>

<style lang="scss" scoped>

</style>