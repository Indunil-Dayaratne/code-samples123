<template>
    <b-container fluid>
        <b-row>
            <b-table id="lossSet-table"
                :fields="fields"
                :items="lossSets"        
                striped
                sort-by="uploadedOn"
                :sort-desc="true">
                <template v-slot:cell(programRef)="data" >
                    <span class="program-ref-link" @click="activateLossSet(data.item.id, data.item.networkId)">{{data.value}}</span>
                </template>
            </b-table>
        </b-row>
    </b-container>
</template>

<script>
import {mapState, mapGetters} from 'vuex';
    export default {
        data() {
            return {
                fields: [                    
                    {
                        key: 'programRef',
                        label: 'Program Ref'
                    },
                    {
                        key: 'yoa',
                        label: 'YOA',
                        sortable: true
                    },
                    {
                        key: 'accountName',
                        label: 'Account',
                        formatter: (value, key, item) => {
                            let filtered =  this.groupAnalyses.find(x => x.ProgramRef === item.programRef && x.AnalysisId === item.analysisId);
                            if(!filtered) return '';
                            return filtered.AccountName;
                        }                        
                    },
                    {
                        key: 'summary',
                        label: 'Summary',
                        formatter: (value, key, item) => {
                           let filtered =  this.groupAnalyses.find(x => x.ProgramRef === item.programRef && x.AnalysisId === item.analysisId);
                            if(!filtered) return '';
                            return filtered.Summary;
                        },
                        sortable: true            
                    },
                    {
                        key: 'runCatalogType',
                        label: 'Run Catalog',
                        formatter: (value, key, item) => {
                            let filtered =  this.runCatalogTypes.filter(x => x.code === value);
                            if(!filtered) return '';
                            return filtered.text;
                        },
                        sortable: true
                    },                    
                    {
                        key: 'eventCatalogType',
                        label: 'Event Catalog',
                        sortable: true
                    },   
                    {
                        key: 'currency',
                        label: 'Currency',
                        sortable: true
                    },
                    {
                        key: 'userField1',
                        label: 'Field 1',
                        sortable: true
                    }, 
                    {
                        key: 'userField2',
                        label: 'Field 2',
                        sortable: true
                    },                                                                         
                    {
                        key: 'uploadedOn',
                        label: 'Uploaded On',
                        sortable: true
                    },
                    {
                        key: 'uploadedBy',
                        label: 'Uploaded By',
                        sortable: true
                    }
                ]
            }
        },
        computed: {
            ...mapState({
                lossSets: s => s.pricing.lossSets.data,
                runCatalogTypes: s => s.cedeExposure.runCatalogTypes,
                groupAnalyses: (state, get) => get['account/get']('groupAnalyses')
            }),
            dateFormat() {
                return 'DD-MM-YYYY HH:mm';
            }     
        },
        methods: {
            activateLossSet(id, networkId) {
                this.$store.commit('pricing/lossSets/activateLossSet', id);
                this.$store.dispatch('pricing/getNetwork', {
                    networkId: networkId,
                    revision: null
                });
            }
        }        
    }
</script>

<style lang="scss" scoped>

.program-ref-link {
    color: #20a8d8;
    text-decoration: none;
    background-color: transparent;

    &:hover {
        color: #167495;
        text-decoration: underline;
        cursor: pointer;
    }
}


</style>