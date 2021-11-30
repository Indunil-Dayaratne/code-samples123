<template>
    <div>
        <b-row>
            <b-col class="mb-2">
                <span class="back-btn" @click="deactivateView">
                    <fa-icon icon="arrow-left" size="lg" />
                </span>
                <span class="filter-header">
                    Detail
                </span>
            </b-col>
        </b-row>    
        <b-card no-body>
            <b-row class="mt-3 ml-2 mr-2">
                <b-col>
                    <b-form-group label="Program Ref:" label-size="sm" label-cols="3">
                            <b-input-group>
                                <b-input v-model="analysis.ProgramRef" size="sm" disabled />
                                <b-input-group-append>
                                    <b-btn variant="info" :to="{ name:'AnalysisDetails', params: { programRef: analysis.ProgramRef, id:analysis.AnalysisId } }" target="_blank" size="sm">...</b-btn>
                                </b-input-group-append>
                            </b-input-group>
                    </b-form-group>
                </b-col>
                <b-col>
                    <b-form-group label="Account Name:" label-size="sm" label-cols="3">
                        <b-input v-model="analysis.AccountName" size="sm" disabled />
                    </b-form-group>
                </b-col>
                <b-col>
                    <b-form-group label="Summary:"  label-size="sm" label-cols="3">
                        <b-input v-model="analysis.Summary" size="sm" disabled />
                    </b-form-group>
                </b-col>
            </b-row>
            <b-row class="ml-2 mr-2">
                <b-col>
                    <b-form-group label="Run Catalog:" label-size="sm" label-cols="3">
                        <b-input v-model="runCatalog" size="sm" disabled />
                    </b-form-group>
                </b-col>
                <b-col>
                    <b-form-group label="Event Catalog:" label-size="sm" label-cols="3">
                        <b-input v-model="eventCatalogType" size="sm" disabled />
                    </b-form-group>
                </b-col>
                <b-col>
                    <b-form-group label="Loss File Name:"  label-size="sm" label-cols="3">
                        <b-input v-model="lossSet.parquetfileName" size="sm" disabled />
                    </b-form-group>
                </b-col>
            </b-row>
            <b-row class="ml-2 mr-2">
                <b-col>
                    <b-form-group label="Currency:" label-size="sm" label-cols="3">
                        <b-input v-model="lossSet.currency" size="sm" disabled />
                    </b-form-group>
                </b-col>
                <b-col>
                    <b-form-group label="Field 1:" label-size="sm" label-cols="3">
                        <b-input v-model="lossSet.userField1" size="sm" disabled />
                    </b-form-group>
                </b-col>
                <b-col>
                    <b-form-group label="Field 2:"  label-size="sm" label-cols="3">
                        <b-input v-model="lossSet.userField2" size="sm" disabled />
                    </b-form-group>
                </b-col>
            </b-row> 
            <b-row class="ml-2 mr-2">
                <b-col md="4">
                    <b-form-group label="Data Type:" label-size="sm" label-cols="3">
                        <b-input v-model="lossSet.dataType" size="sm" disabled />
                    </b-form-group>
                </b-col>
                <b-col md="4">
                    <b-form-group label="Source File Name:" label-size="sm" label-cols="3">
                        <b-input v-model="lossSet.sourcefileName" size="sm" disabled />
                    </b-form-group>
                </b-col> 
                <b-col md="4">
                    <b-form-group label="Simulations:" label-size="sm" label-cols="3">
                        <b-input v-model="lossSet.simulations" size="sm" disabled />
                    </b-form-group>
                </b-col>    
            </b-row>
            <b-row class="ml-2 mr-2">
                <b-col md="4">
                    <b-form-group label="Network Id:" label-size="sm" label-cols="3">
                        <b-input v-model="lossSet.networkId" size="sm" disabled />
                    </b-form-group>
                </b-col>
                <b-col md="4">
                    <b-form-group label="Node Id:" label-size="sm" label-cols="3">
                        <b-input v-model="lossSet.nodeId" size="sm" disabled />
                    </b-form-group>
                </b-col>     
            </b-row>
            <b-row class="ml-2 mr-2">
                <b-col md="4">
                    <b-form-group label="Uploaded By:" label-size="sm" label-cols="3">
                        <b-input v-model="lossSet.uploadedBy" size="sm" disabled />
                    </b-form-group>
                </b-col>
                <b-col md="4">
                    <b-form-group label="Uploaded On:" label-size="sm" label-cols="3">
                        <b-input v-model="lossSet.uploadedOn" size="sm" disabled />
                    </b-form-group>
                </b-col>
            </b-row>         
        </b-card>
        <GrapheneResultsComponent :networkId="lossSet.networkId" :type="lossSet.eventCatalogType"/>
    </div>
</template>

<script>
import {mapState, mapGetters} from 'vuex';
import Multiselect from 'vue-multiselect';
import GrapheneResultsComponent from '@/components/analysis/pricing/results/GrapheneResultsComponent.vue'

    export default {
        name: 'LossViewDetails',
        components: {
            Multiselect,
            GrapheneResultsComponent
        },
        computed: {
            ...mapState({
                activeLossSet: state => state.pricing.lossSets.activeLossSet,
                groupAnalyses: (state, get) => get['account/get']('groupAnalyses'),
                runCatalogTypes: s => s.cedeExposure.runCatalogTypes                              
            }),
            ...mapGetters('pricing/lossSets', [
                'getLossSetById'
            ]),
            lossSet() {
                return this.getLossSetById(this.activeLossSet);
            },
            analysis() {
                return this.groupAnalyses.filter(x => x.ProgramRef === this.lossSet.programRef && x.AnalysisId === this.lossSet.analysisId)[0];
            },
            runCatalog() {
                let expRunCatalog = this.runCatalogTypes.filter(x => x.code === this.lossSet.runCatalogType);
                if (expRunCatalog.Length > 0) return expRunCatalog[0].text;
                return this.lossSet.runCatalogType;
            },
            eventCatalogType() {
                return this.lossSet.eventCatalogType === "STC" ? "Stochastic" : "Deterministic"
            }
        },
        methods: {
            deactivateView() {
                this.$store.commit('pricing/lossSets/deactivateLossSet');
            }
        }
    }
</script>

<style lang="scss" scoped>
.back-btn {
    cursor: pointer;
    padding: 5px;
    border-radius: 0.25em;
    display: inline-block;
    color: #20a8d8;
    
    &:hover {
        background-color: rgba(211,211, 211, 0.4)
    }
}

.filter-header {
    font-size: 20px;
    display: inline-block;
}
</style>