<template>
    <div>
        <b-modal id="CedeRunModal" :title="data.AnalysisName" ok-only size="xl"> 
            <b-card header="RUN DETAILS" header-bg-variant="info" no-body>
                <b-row class="m-2">
                    <b-col sm="2"><label for="description" class="col-form-label col-form-label-sm">Description:</label></b-col>
                    <b-col sm="10"> <b-input id="description" v-model="data.Description" size="sm" disabled /></b-col>
                </b-row>
                <b-row class="m-2">
                    <b-col sm="2">
                        <label for="event_set" class="col-form-label col-form-label-sm">
                            Event set:
                        </label>
                    </b-col>
                    <b-col sm="10">
                        <b-input id="event_set" v-model="data.EventSet" size="sm" disabled />
                    </b-col>
                </b-row>
                <b-row class="m-2">
                    <b-col sm="2">
                        <label for="exposure_set" class="col-form-label col-form-label-sm">
                            Exposure set:
                        </label>
                    </b-col>
                    <b-col sm="4">
                        <b-input id="exposure_set" v-model="data.ExposureSetName" size="sm" disabled />
                    </b-col>
                    <b-col sm="2">
                        <label for="lob" class="col-form-label col-form-label-sm">
                            Line of business:
                        </label>
                    </b-col>
                    <b-col sm="4">
                        <b-input id="lob" v-model="data.LineOfBusiness" size="sm" disabled />
                    </b-col>
                </b-row>
                <b-row class="m-2">
                    <b-col sm="2">
                        <label for="currency_code" class="col-form-label col-form-label-sm">
                            Currency:
                        </label>
                    </b-col>
                    <b-col sm="4">
                        <b-input id="currency_code" v-model="data.CurrencyCode" size="sm" disabled />
                    </b-col>
                    <b-col sm="2">
                        <label for="exchange_rate_set" class="col-form-label col-form-label-sm">
                            Exchange rate set:
                        </label>
                    </b-col>
                    <b-col sm="4">
                        <b-input id="exchange_rate_set" v-model="data.CurrencyExchangeRateSet" size="sm" disabled />
                    </b-col>
                </b-row>
                <b-row class="m-2">
                    <b-col sm="2">
                        <label for="demand_surge" class="col-form-label col-form-label-sm">
                            Demand surge:
                        </label>
                    </b-col>
                    <b-col sm="4">
                        <b-input id="demand_surge" v-model="data.DemandSurgeOptionCode" size="sm" disabled />
                    </b-col>
                    <b-col sm="2">
                        <label for="source_template" class="col-form-label col-form-label-sm">
                            Source template:
                        </label>
                    </b-col>
                    <b-col sm="4">
                        <b-input id="source_template" v-model="data.SourceTemplateName" size="sm" disabled />
                    </b-col>
                </b-row>
                <b-row class="m-2">
                    <b-col sm="2">
                        <label for="analysis_model_version" class="col-form-label col-form-label-sm">
                            Analysis product version:
                        </label>
                    </b-col>
                    <b-col sm="4">
                        <b-input id="analysis_model_version" v-model="data.AnalysisProductVersion" size="sm" disabled />
                    </b-col>
                    <b-col sm="2">
                        <label for="source_template" class="col-form-label col-form-label-sm">
                            Event set product version:
                        </label>
                    </b-col>
                    <b-col sm="4">
                        <b-input id="event_set_model_version" v-model="data.EventSetProductVersion" size="sm" disabled />
                    </b-col>
                </b-row>
            </b-card>
            <b-card header="OUTPUT SELECTIONS" header-bg-variant="info" no-body>
                <b-row class="m-2">
                    <b-col sm="2">
                        <label for="output_type" class="col-form-label col-form-label-sm">
                            Output type:
                        </label>
                    </b-col>
                    <b-col sm="2">
                        <b-input id="output_type" v-model="data.OutputTypeCode" size="sm" disabled />
                    </b-col>
                    <b-col sm="2">
                        <label for="geo_level" class="col-form-label col-form-label-sm">
                            Geography level:
                        </label>
                    </b-col>
                    <b-col sm="2">
                        <b-input id="geo_level" v-model="data.GeoLevelCode" size="sm" disabled />
                    </b-col>
                    <b-col sm="2">
                        <label for="group_by" class="col-form-label col-form-label-sm">
                            Group by:
                        </label>
                    </b-col>
                    <b-col sm="2">
                        <b-input id="group_by" v-model="data.OutputGroupByCode" size="sm" disabled />
                    </b-col>
                </b-row>
            </b-card>
            <b-card header="AAL BY MODEL" header-bg-variant="info" no-body>
                <div class="m-2">
                    <b-table ref="CedeRunAALs"
                        :items="data.AALs"
                        :fields="fields"
                        striped hover small responsive show-empty>
                        <template v-slot:cell(GrossLoss)="data">
                            {{ data.value | toDecimal }}
                        </template>
                        <template v-slot:cell(NetOfPreCATLoss)="data">
                            {{ data.value | toDecimal }}
                        </template>
                        <template v-slot:cell(PostCATNetLoss)="data">
                            {{ data.value | toDecimal }}
                        </template>
                    </b-table>
                </div>
            </b-card>
        </b-modal>
    </div>
</template>

<script>
    import { mapState, mapGetters } from 'vuex';
    export default {
        data() {
            return {
                fields: [
                    { key: "ModelCode", label: "Model" },
                    { key: "PerilSet", label : "Perils"},
                    { key: "GrossLoss", label: "Gross" },
                    { key: "NetOfPreCATLoss", label: "Net pre-CAT" },
                    { key: "PostCATNetLoss", label: "Net post-CAT"}
                ]
            }
        },
        computed: {
            ...mapState({
                data: (state, get) => get['account/get']('files/cedeRes/item')('modalCede')
            })
        }
    }
</script>

<style lang="scss" scoped>

</style>