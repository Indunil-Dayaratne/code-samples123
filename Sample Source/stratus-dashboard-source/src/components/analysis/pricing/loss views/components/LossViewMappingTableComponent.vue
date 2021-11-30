<template>
    <b-container>
        <b-table :id="`mapping-table_${activeView}`"
            :fields="fields"
            :items="inputs"
            striped>
            <template v-slot:cell(name)="data">
                <div class="mapping-table-name">
                    {{data.item.data.name}}
                </div>
            </template>
            <template v-slot:cell(mapping)="data">
                <b-modal :id="`map-modal-${data.item.id}`"
                    header-bg-variant="secondary"
                    header-text-variant="dark"
                    size="xl"
                    ok-only
                    ok-title="Close">
                    <template v-slot:modal-title>
                        Select loss set
                    </template>
                    <template v-slot:default>
                        <multi-column-filter-table single
                            :value="data.item.data.pathsObj[view.identifier]" 
                            :fields="modalFields"
                            :options="lossSetOptions(data.item.data.currency)"
                            @input="handleLossSetMappingchange($event, data.item.id)">
                        </multi-column-filter-table>
                        <p class="ml-4">Mapping run on row selection</p>
                    </template>
                </b-modal>
                <b-button block variant="outline-dark" @click="$bvModal.show(`map-modal-${data.item.id}`)"
                    :disabled="mappingButtonsDisabled">
                    {{getSelectedLossSetButtonText(data.item.data.pathsObj[view.identifier])}}
                </b-button>
            </template>
        </b-table>
    </b-container>
</template>

<script>
import {mapState, mapGetters} from 'vuex';
import Multiselect from 'vue-multiselect';
import MultiColumnFilterTable from '../../../../utils/MultiColumnFilterTable';
import moment from 'moment';
    export default {
        name: 'LossViewMappingTable',
        components: {
            Multiselect,
            MultiColumnFilterTable
        },
        data() {
            return {
                selected: null,
                fields: [
                    {
                        key: 'name',
                        label: 'Name'
                    },
                    {
                        key: 'mapping',
                        label: 'Selected loss set'
                    }
                ],
                modalFields: [
                    {
                        key: 'yoa',
                        label: 'YOA'
                    },
                    {
                        key: 'dataType',
                        label: 'Source'
                    },
                    {
                        key: 'eventCatalogType',
                        label: 'Catalog'
                    }, 
                    {
                        key: 'runCatalogType',
                        label: 'Run'
                    },
                    {
                        key: 'currency',
                        label: 'Currency'
                    },
                    {
                        key: 'userField1',
                        label: 'UDF1'
                    },
                    {
                        key: 'userField2',
                        label: 'UDF2'
                    },
                    {
                        key: 'simulations',
                        label: 'Sims'
                    },
                    {
                        key: 'uploadedOn',
                        label: 'Uploaded On'
                    }
                ]
            }
        },
        computed: {
            ...mapState({
                inputs: state => state.pricing.structure.inputs,
                activeView: state => state.pricing.views.activeView,
                lossSets: state => state.pricing.lossSets.data
            }),
            ...mapGetters('pricing/views', [
                'getViewById'
            ]),
            view() {
                return this.getViewById(this.activeView);
            },
            lossSetOptions() {
                return function(currency) {
                    if(!this.view.type) return [];
                    return this.lossSets.filter(x => !currency || x.currency === currency)
                        .filter(x => !this.view.simulations || this.view.simulations === 0 || x.simulations === this.view.simulations)
                        .filter(x => this.view.type === 'STC' ? x.eventCatalogType === 'STC' : x.eventCatalogType === 'DET')
                        .sort((a, b) => {
                            return moment(b.uploadedOn, config.dateFormat) - moment(a.uploadedOn, config.dateFormat)
                        });
                }
            },
            mappingButtonsDisabled() {
                return !this.view.type;
            }
        },
        methods: {
            
            async handleLossSetMappingchange(val, id) {
                await this.$store.dispatch('pricing/views/mapInput', {
                    inputId: id,
                    viewId: this.activeView,
                    viewIdentifier: this.view.identifier,
                    filePath: val ? val.fileUrl : "",
                    currency: val ? val.currency : '',
                    simulations: val ? val.simulations : 0,
                    lossSet: val
                });
            },
            getSelectedLossSetButtonText(lossSet) {
                if(!this.view.type) return "Select loss view type..."
                if(!lossSet) return "Select...";
                return `${lossSet.programRef} - ${lossSet.runCatalogType} - ${lossSet.userField1} - ${lossSet.userField2} - ${lossSet.currency}`;
            }
        }
    }
</script>

<style lang="scss" scoped>
.mapping-table-name {
    font-size: 15px;
    margin-top: 6px;
}
</style>