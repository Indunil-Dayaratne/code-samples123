<template>
    <b-card>
        <b-container fluid>
            <b-row>
                <b-col cols="3">
                    <template v-if="type === stcString">
                        <b-card title="Node">
                            <b-container fluid>
                                <b-row>
                                    <b-col>
                                        <multiselect :id="`${networkId}_${type}_node_selection`"
                                            :options="nodeOptions"
                                            v-model="selectedNodes"
                                            track-by="id"
                                            group-values="nodes"
                                            group-label="name"
                                            :group-select="true"
                                            @input="getNodeResults"
                                            :multiple="true"
                                            :disabled="selectedLossViews.length > 0 && selectedLossViews[0].type === detString"
                                            :show-labels="false"
                                            :close-on-select="false">
                                            <template v-slot:singleLabel="data">
                                                <template v-if="data.option.$isLabel">
                                                    {{data.option.$groupLabel}}
                                                </template>
                                                <template v-else>
                                                    {{data.option.node && data.option.node.data.name ? data.option.node.data.name : data.option.id}}
                                                </template>
                                            </template>
                                            <template v-slot:option="data">
                                                 <template v-if="data.option.$isLabel">
                                                    {{data.option.$groupLabel}}
                                                </template>
                                                <template v-else>
                                                    {{data.option.node && data.option.node.data.name ? data.option.node.data.name : data.option.id}}
                                                </template>
                                            </template>
                                            <template v-slot:tag="data">
                                            <span class="multiselect__tag">
                                                <span>
                                                    {{data.option.node && data.option.node.data.name ? `${data.option.node.data.name}${getNodeSuffix(data.option.node)}` : data.option.id}}
                                                </span>
                                                <i aria-hidden="true" tabindex="1" class="multiselect__tag-icon"
                                                    @click="data.remove(data.option)">
                                                </i>
                                            </span>
                                        </template>
                                        </multiselect>
                                    </b-col>
                                </b-row>
                            </b-container>
                        </b-card>
                    </template>
                    <template v-else>
                        <b-card title="Event">
                            <b-container fluid>
                                <b-row>
                                    <b-col>
                                        <multiselect :id="`${networkId}_${type}_event_selection`"
                                            :options="eventOptions"
                                            v-model="selectedEvent"
                                            @input="getEventResult"
                                            :show-labels="false">
                                        </multiselect>
                                    </b-col>
                                </b-row>
                            </b-container>
                        </b-card>
                    </template>
                    <b-card title="Filters">
                        <b-container fluid>
                            <b-row>
                                <b-col>
                                    <label :for="`${networkId}_${type}_loss_view_selection`">
                                        Loss view
                                    </label>
                                    <multiselect :id="`${networkId}_${type}_loss_view_selection`" 
                                        v-model="selectedLossViews"
                                        :options="lossViewOptions"
                                        track-by="identifier"
                                        :multiple="true"
                                        :closeOnSelect="false"
                                        @input="updateTableData"
                                        :show-labels="false">
                                        <template v-slot:tag="data">
                                            <span class="multiselect__tag">
                                                <span>
                                                    {{data.option.label || data.option.identifier}}
                                                </span>
                                                <i aria-hidden="true" tabindex="1" class="multiselect__tag-icon"
                                                    @click="data.remove(data.option)">
                                                </i>
                                            </span>
                                        </template>
                                        <template v-slot:option="data">
                                            <div class="mb-1">
                                                {{data.option.label || data.option.identifier}}
                                            </div>
                                            <div style="font-size: 0.7rem; font-style: italic;">
                                                {{data.option.type}}
                                            </div>
                                        </template>
                                    </multiselect>
                                </b-col>
                            </b-row>
                            <b-row>
                                <b-col>
                                    <label :for="`${networkId}_${type}_model_selection`">
                                        Model
                                    </label>
                                    <multiselect :id="`${networkId}_${type}_model_selection`" 
                                        v-model="selectedModels"
                                        :options="modelOptions"
                                        :multiple="true"
                                        :closeOnSelect="false"
                                        @input="updateTableData"
                                        :show-labels="false">
                                    </multiselect>
                                </b-col>
                            </b-row>
                            <b-row>
                                <b-col>
                                    <label :for="`${networkId}_${type}_country_selection`">
                                        Country
                                    </label>
                                    <multiselect :id="`${networkId}_${type}_country_selection`" 
                                        v-model="selectedCountries"
                                        :options="countryOptions"
                                        :multiple="true"
                                        :closeOnSelect="false"
                                        @input="updateTableData"
                                        :show-labels="false">
                                    </multiselect>
                                </b-col>
                            </b-row>
                            <b-row>
                                <b-col>
                                    <label :for="`${networkId}_${type}_area_selection`">
                                        Area
                                    </label>
                                    <multiselect :id="`${networkId}_${type}_area_selection`" 
                                        v-model="selectedAreas"
                                        :options="areaOptions"
                                        :multiple="true"
                                        :closeOnSelect="false"
                                        @input="updateTableData"
                                        :show-labels="false">
                                    </multiselect>
                                </b-col>
                            </b-row>
                        </b-container>
                    </b-card>
                    <b-card title="Export">
                        <b-container fluid>
                            <b-row class="mb-2">
                                <b-col>
                                    <b-button block variant="primary"
                                        @click="downloadTable"
                                        :disabled="!selectedNodes.length || !data.length">
                                        Table
                                    </b-button>
                                </b-col>
                                <b-col>
                                    <b-button block variant="primary"
                                        @click="$bvModal.show(yeltExportId)" >
                                        YELT
                                    </b-button>
                                </b-col>
                            </b-row>
                            <b-row>
                                <b-col>
                                    <b-button block variant="primary"
                                        @click="$bvModal.show(primeExportId)" >
                                        Export to <i>Prime</i>
                                    </b-button>
                                </b-col>
                            </b-row>   
                        </b-container>
                    </b-card>
                </b-col>
                <b-col cols="9">
                    <b-card>
                        <b-container fluid>
                            <b-row class="mb-2" style="min-height: 1.5rem;">
                                <b-col md="2" class="d-flex justify-content-end align-items-center mb-2">
                                    <multiselect :id="`${networkId}_${type}_currency_selection`" 
                                        v-model="selectedCurrency"
                                        :options="currencyOptions"
                                        @input="handleCurrencyChange"
                                        :disabled="currencyOptions.length <= 1"
                                        :show-labels="false">
                                    </multiselect>
                                </b-col>
                                <b-col md="2" class="d-flex justify-content-end align-items-center mb-2">
                                    <template v-if="type === stcString">
                                        <span class="mr-2" style="white-space: nowrap">Max results:</span>
                                        <b-input type="number" v-model="maxResults" min="1"></b-input>
                                    </template>
                                </b-col>
                                <b-col class="d-flex justify-content-end align-items-center mb-2">
                                    <template v-if="type === stcString">
                                        <stratus-switch v-model="showVar" true-text="VaR" false-text="TVaR"/>
                                        <stratus-switch v-model="showAep" true-text="AEP" false-text="OEP" />
                                    </template>
                                    <b-button size="sm" variant="primary" @click="hardRefresh">
                                        <fa-icon icon="sync-alt"/>
                                    </b-button>
                                </b-col>
                            </b-row>
                            <b-row>
                                <b-col>
                                    <template v-if="showSpinner">
                                        <div class="mt-2">
                                            <b-spinner variant="primary" small></b-spinner>
                                            <span>{{message}}</span>
                                        </div>
                                    </template>
                                </b-col>
                            </b-row>
                            <b-row>
                                <b-col class="">
                                    <div v-if="nodes.length === 0">
                                        No results found for network. Please run analysis.
                                    </div>
                                    <div :style="{ 'overflow-x': 'auto' }">
                                        <b-table :id="`${networkId}_${type}_${tableId}`"
                                            ref="resultTable"
                                            class="results-table"
                                            striped hover outlined responsive small
                                            :items="data" :fields="fields">
                                            <template v-slot:table-colgroup="scope">
                                                <col v-for="field in scope.fields" 
                                                    :key="field.key"
                                                    :style="{ 'width': field.isRowHeader ? '250px' : '150px' }">
                                            </template>
                                            <template v-slot:thead-top>
                                                <template v-for="(header, index) in headersForSlot">
                                                    <tr :key="index">
                                                        <th></th>
                                                        <th v-for="(def, innerIndex) in header.data" :key="`${innerIndex}_${def.text}`" :colspan="def.span" class="header-border">
                                                            {{def.text}}
                                                        </th>
                                                    </tr>
                                                </template>
                                            </template>
                                            <template v-slot:head(rowHeader)="data">
                                                {{data.label}}
                                            </template>
                                            <template v-slot:head()="data">
                                                {{data.field[labelKey]}}
                                            </template>
                                            <template v-slot:cell(rowHeader)="data">
                                                {{data.item.rowHeader === 1
                                                    ? 'AAL'
                                                    : data.value}}
                                            </template>
                                            <template v-slot:cell()="data">
                                                {{getDisplayValue(data, selectedCurveType, selectedMetricType) | toNumber(data.item.decimals)}}
                                            </template>
                                        </b-table>
                                    </div>
                                </b-col>
                            </b-row>
                        </b-container>
                    </b-card>
                </b-col>
            </b-row>
        </b-container>
        <event-catalog-selector :modal-id="eventCatalogSelectorId" :bySplits="requiredEventCatalogSplits" @ok="exportToPrime(primeExportMode, $event)" @cancel="primeExportMode = '' " />
        <yelt-export-modal :modal-id="yeltExportId" />
        <prime-export-modal :modal-id="primeExportId" />
    </b-card>
    
</template>

<script>
import azure from 'azure-storage';
import {mapState, mapGetters} from 'vuex';
import AzureStorageUtils from '@/shared/azure-storage-utils';
import Multiselect from 'vue-multiselect';
import StratusSwitch from '@/components/utils/StratusSwitch.vue'
import EventCatalogSelector from '../../../utils/EventCatalogSelectionModal';
import YeltExportModal from './YeltExportModal';
import PrimeExportModal from './PrimeExportModal';
import { capitalize } from 'lodash';
import api from '../../../../shared/api'

    export default {
        name: 'GrapheneResultsComponent',
        props: {
            networkId: {
                type: [String, Number],
                required: true
            },
            type: {
                type: String,
                default: 'STC'
            }
        },
        components: {
            Multiselect,
            StratusSwitch,
            EventCatalogSelector,
            YeltExportModal,
            PrimeExportModal
        },
        data() {
            return {
                selectedLossViews: [],
                selectedModels: [],
                selectedCountries: [],
                selectedAreas: [],
                selectedNodes: [],
                selectedEvent: null,
                showVar: true,
                showAep: true,
                allString: 'All',
                headers: [],
                fields:[],
                data: [],
                labelKey: null,
                detString: 'DET',
                stcString: 'STC',
                exportToPrimeOptions: ['Layers', 'Inputs', 'All'],
                exportToPrimeString: 'Export to Prime',
                defaultExportToPrimeString: 'Export to Prime',
                primeExportMode: '',
                selectedCurrency: null,
                defaultCurrency: 'USD'
            }
        },
        computed: {
            tableId() {
                return `results-table-${this.networkId}-${this.type}`;
            },
            ...mapState({
                group: (state, get) => get['account/get']('group'),
                nodes: state => state.pricing.results.nodeOptions,
                showSpinner: (state, get) => get['pricing/results/isLoading'],
                message: state => state.pricing.results.uiMessage
            }),
            ...mapGetters('pricing/structure', [
                'getNodeById'
            ]),
            ...mapGetters('pricing/results',[
                'getResult',
                'tableName',
                'getEventIds',
                'validateSelectedNodes'
            ]),
            nodeOptions() {
                return [
                    {
                        name: 'Inputs',
                        nodes: this.nodes.filter(x => (x.node.data.objType && x.node.data.objType.toLowerCase() === 'input') || (x.node.data.type && x.node.data.type.toLowerCase() === 'input'))
                    },
                    {
                        name: 'Subject Loss',
                        nodes: this.nodes.filter(x => (x.node.data.objType && x.node.data.objType === api.pricingConstants.objectTypes.SUBJECT_LOSS))
                    },
                    {
                        name: 'Gross',
                        nodes: this.nodes.filter(x => x.node.data.objType && x.node.data.objType.toLowerCase() === 'layer' && x.node.data.layer_type === 'gross').sort((a, b) => a.id - b.id)
                    },
                    {
                        name: 'Ceded',
                        nodes: this.nodes.filter(x => x.node.data.objType && x.node.data.objType.toLowerCase() === 'layer' && (x.node.data.layer_type === 'ceded' || !x.node.data.layer_type)).sort((a, b) => a.id - b.id)
                    },
                    {
                        name: 'Net',
                        nodes: this.nodes.filter(x => x.node.data.objType && x.node.data.objType.toLowerCase() === 'layer' && x.node.data.layer_type === 'net').sort((a, b) => a.id - b.id)
                    }
                ]
            },
            results() {
                if(this.type !== this.detString) {
                    if(!this.selectedNodes.length || this.selectedNodes.map(x => x.id).every(x => !x)) return [];
                    return this.getResult(this.stcString, this.selectedNodes.map(x => x.id));
                } else {
                    if(!this.selectedLossViews.length || !this.nodeResults.length) return [];
                    return this.getResult(this.detString, 
                        this.networkId, 
                        [this.selectedEvent],
                        this.selectedLossViews.map(x => x.identifier),
                        this.selectedCurrency);
                }
            },
            nodeResults() {
                if(!this.selectedNodes.length || this.selectedNodes.map(x => x.id).every(x => !x)) return [];
                return this.getResult(this.stcString, this.selectedNodes.map(x => x.id));
            },
            lossViewOptions(){
                if(!this.nodeResults.length) return []; 
                const output = [];
                this.nodeResults.forEach(res => {
                    res.structure.data.lossViews.forEach(lv => {
                        if(!lv || lv.type !== this.type) return;
                        if(!output.find(out => out.identifier === lv.identifier)) {
                            output.push(lv);
                        }
                    });
                });
                return output;
            },
            eventOptions() {
                return this.getEventIds(this.networkId) || [];
            },
            modelOptions(){
                switch (this.type) {
                    case this.stcString:
                        if(!this.results.length) return [];
                        let options = this.results.reduce((acc, x) => {
                            acc.push(...x.options.model.filter(x=>!!x && x !== '0'));
                            return acc;
                        }, []);
                        if(!options.length) return [];
                        return [this.allString, ...new Set(options)];

                    case this.detString:
                        if(!this.results.length) return [];
                        let set = new Set(this.results.map(x => x.model));
                        if(set.size === 0) return [];
                        return [this.allString, ...[...set].sort()];
                
                    default:
                        return [];
                }
            },
            countryOptions(){
                switch (this.type) {
                    case this.stcString:
                        if(!this.results) return [];
                        let options = this.results.reduce((acc, x) => {
                            acc.push(...x.options.country.filter(x=>!!x));
                            return acc;
                        }, []);
                        if(!options.length) return [];
                        return [this.allString, ...new Set(options)];

                    case this.detString:
                        if(!this.results) return [];
                        let set = new Set(this.results.map(x => x.country));
                        if(set.size === 0) return [];
                        return [this.allString, ...[...set].sort()];
                
                    default:
                        return [];
                }
                
            },
            areaOptions(){
                switch (this.type) {
                    case this.stcString:
                        if(!this.results) return [];
                        let options = this.results.reduce((acc, x) => {
                            acc.push(...x.options.area.filter(x=>!!x));
                            return acc;
                        }, []);
                        if(!options.length) return [];
                        return [this.allString, ...new Set(options)];

                    case this.detString:
                        if(!this.results) return [];
                        let set = new Set(this.results.map(x => x.area));
                        if(set.size === 0) return [];
                        return [this.allString, ...[...set].sort()];
                
                    default:
                        return [];
                }
            },
            currencyOptions(){
                const currencies = this.nodeResults.reduce((acc, x) => {
                    const set = new Set(acc);
                    if(x.currencies) x.currencies.forEach(x => { 
                        if(!!x) set.add(x)
                    });
                    return [...set];
                }, [])
                if(!currencies.length) {
                    this.selectedCurrency = this.selectedCurrency || this.defaultCurrency;
                    return [this.selectedCurrency];
                }
                if(!this.selectedCurrency || !currencies.includes(this.selectedCurrency)) {
                    this.selectedCurrency = currencies[0];
                }
                return currencies;
            },
            headersForSlot(){
                return this.headers.slice(0, -1);
            },
            selectedCurveType() {
                return this.showAep ? 'Aep' : 'Oep';
            },
            selectedMetricType() {
                return this.showVar ? 'var': 'tvar';
            },
            eventCatalogSelectorId() {
                return `network-${this.networkId}-${this.type}-catalog-selector`;
            },
            yeltExportId() {
                 return `network-${this.networkId}-${this.type}-yelt-export`;
            },
            primeExportId() {
                return `network-${this.networkId}-${this.type}-prime-export`;
            },
            canExportToPrime() {
                return this.lossViewOptions.map(x => x.label).every(x => !!x);
            },
            requiredEventCatalogSplits() {
                if(!this.canExportToPrime) return [];
                return this.lossViewOptions.map(x => x.label);
            },
            keyByNode() {
                return this.type !== this.detString;
            },
            maxResults: {
                get() {
                    return this.$store.state.pricing.results.maxResultCount;
                },
                set(value) {
                    this.$store.commit('pricing/results/updateMaxResultCount', value);
                    this.selectedNodes = this.validateSelectedNodes(this.selectedNodes);
                    this.updateTableData();
                }
            }
        },
        methods: {
            async getNodeResults() {
                try {
                    this.spinnerMessage('Getting node data...');
                    await this.$store.dispatch('pricing/results/getNodeResults', this.selectedNodes.map(x => {
                            return {
                                nodeId: x.id,
                                url: x.url
                            }
                        })
                    );
                    this.selectedNodes = this.validateSelectedNodes(this.selectedNodes);
                    this.updateTableData();
                } catch (err) {
                    console.error(err);  
                } finally {
                    this.hideSpinner();
                }
            },
            async getEventResult(selectedOption, id) {
                try {
                    if(this.selectedEvent) {
                        if(!this.results || !this.results.length) {
                            await this.$store.dispatch('pricing/results/getYeltData', {
                                networkId: this.networkId,
                                lossViewIdentifiers: this.lossViewOptions.map(x => x.identifier),
                                currency: this.selectedCurrency,
                                eventIds: [selectedOption]
                            });
                        }
                    }
                    this.updateTableData();
                } catch (err) {
                    console.error(err);  
                }
            },
            getLossViewIdentifier(item) {
                return !!item.lossView ? item.lossView.identifier : item.lossViewIdentifier;
            },
            getLossViewName(item) {
                let val = null;
                if(!!item.lossView) {
                    val = item.lossView.label;
                    if(!val) val = !!this.lossViewOptions.find(x => x.identifier === item.lossView.identifier) 
                        ? this.lossViewOptions.find(x => x.identifier === item.lossView.identifier).label
                        : null;
                    if(!val) val = item.lossView.identifier;
                } else {
                    val = !!this.lossViewOptions.find(x => x.identifier === item.lossViewIdentifier) 
                        ? this.lossViewOptions.find(x => x.identifier === item.lossViewIdentifier).label
                        : null;
                    if(!val) val = item.lossViewIdentifier;
                }
                return val;
            },
            filterData(data, requireBlanks = true) {
                return data.filter(x => {
                    let lossViewCheck = !this.selectedLossViews.length 
                        ? false 
                        : this.selectedLossViews.some(view => view.identifier === this.getLossViewIdentifier(x));
                    let modelCheck = !this.selectedModels.length 
                        ? !requireBlanks || (x.model === null)
                        : this.selectedModels.some(model => (model === this.allString && !!x.model && x.model !== '0') || model === x.model);
                    let countryCheck = !this.selectedCountries.length 
                        ? (!!this.selectedAreas.length || (!requireBlanks || (x.country === null))) 
                        : this.selectedCountries.some(country => (country === this.allString && !!x.country) || country === x.country);
                    let areaCheck = !this.selectedAreas.length 
                        ? !requireBlanks || (x.area === null) 
                        : this.selectedAreas.some(area => (area === this.allString && !!x.area) || area === x.area);
                    let currencyCheck = !this.selectedCurrency
                        ? false
                        : (!x.currency && this.selectedCurrency === this.defaultCurrency) || (x.currency === this.selectedCurrency)
                    return lossViewCheck && modelCheck && countryCheck && areaCheck && currencyCheck;
                });
            },
            getFilterColumns() {
                let output = [null, null, null, null];
                // We always filter on loss view
                output[0] = 'lossView';
                if(!!this.selectedModels.length) output[1] = 'model';
                if(!!this.selectedCountries.length || !!this.selectedAreas.length) output[2] = 'country';
                if(!!this.selectedAreas.length) output[3] = 'area';
                return output;
            },
            getFields(data) {
                let filterCols = this.getFilterColumns();
                let fields = data.reduce((acc, val) => {
                    let key = this.getDataItemKey(val);
                    if(!acc.find(x => x.key === key)) {
                        acc.push({
                            key: key,
                            nodeId: val.nodeId,
                            nodeName: val.nodeName || val.nodeId,
                            perspective: val.perspective,
                            lossView: this.getLossViewIdentifier(val),
                            lossViewName: this.getLossViewName(val),
                            model: filterCols.includes('model') ? val.model : null,
                            country: filterCols.includes('country') ? val.country : null,
                            area: filterCols.includes('area') ? val.area : null,
                            tdClass: 'results-cell',
                            thClass: 'header-border'
                        });
                    };
                    return acc;
                }, []);
                fields.sort((a, b) => {
                    return a.nodeId - b.nodeId ||
                        this.orderString(a.lossView, b.lossView) ||
                        this.orderString(a.model, b.model) ||
                        this.orderString(a.country, b.country) ||
                        this.orderString(a.area, b.area)
                });
                return fields;
            },
            generateHeaderData(fields) {
                let output = {
                    headerData: [],
                    labelToUse: null
                };
                var nodeIds = [...new Set(fields.map(x => x.nodeId))];
                let headerKeys = ['lossViewName', 'model', 'country', 'area'];
                if(this.keyByNode) headerKeys.unshift('nodeName', { prop: 'perspective', cap: true });

                const keyFn = function (filteredFields, key, output) {
                    let prop = key.prop || key;
                    let set = new Set(filteredFields.filter(y => !!y[prop]).map(y => y[prop]));
                    if(set.size) {
                        const keyExists = !!output.headerData.find(x => x.level === prop)
                        let item = output.headerData.find(x => x.level === prop) 
                            || {
                                level: prop,
                                data: []
                            };
                        set.forEach(val => {
                            item.data.push({
                                text: key.cap ? capitalize(val) : val,
                                span: filteredFields.filter(x => x[prop] === val).length
                            })
                        });
                        if(!keyExists) output.headerData.push(item);
                        output.labelToUse = key;
                    };
                }

                if(this.keyByNode) {
                    nodeIds.forEach(id => {
                        const filteredFields = fields.filter(x => x.nodeId === id);
                        headerKeys.forEach(key => keyFn(filteredFields, key, output));
                    });
                } else {
                    headerKeys.forEach(key => keyFn(fields, key, output));
                }               
                return output;
            },
            updateTableData() {
                switch (this.type) {
                    case this.stcString:
                        this.processTableData(!!this.results 
                            ? this.results.reduce((acc, x) => {
                                acc.push(...x.metrics); 
                                return acc;
                            }, []) 
                            : null, 
                        true, this.addStcData);
                        break;

                    case this.detString:
                        this.processTableData(this.results, false, this.addDetData);
                        break;
                
                    default:
                        break;
                }
            },
            processTableData(fullData, requireBlanksInFilter, addRowFieldAndDataFn) {
                if(!fullData || !Array.isArray(fullData) || !this.selectedCurrency) {
                    this.reset();
                    return;
                }
                
                this.spinnerMessage('Updating table...');
                let filtered = this.filterData(fullData, requireBlanksInFilter)
                if(!filtered.length) {this.reset(); return;}

                let organisedData = {
                    fields: this.getFields(filtered),
                    data: []
                }

                addRowFieldAndDataFn(filtered, organisedData);

                let processedHeaderData = this.generateHeaderData(organisedData.fields);
                this.data = organisedData.data;
                this.fields = organisedData.fields;
                this.headers = processedHeaderData.headerData;
                this.labelKey = processedHeaderData.labelToUse;
                this.hideSpinner();
            },
            addDetData(filtered, organised) {
                organised.fields.unshift({
                    key: 'rowHeader',
                    label: 'Node',
                    isRowHeader: true,
                    stickyColumn: true,
                    class: 'header-border'
                });

                filtered.forEach((val) => {
                    let key = this.getDataItemKey(val);
                    let node = this.getNodeById(val.nodeId);
                    const rowHeader = node ? node.data.name + this.getNodeSuffix(node) : val.nodeId;
                    let row = organised.data.find(x => x.rowHeader === rowHeader);
                    let data = !!row && !!row[key] && !!row[key]['Aep'] 
                        ? row[key]['Aep']
                        : { var: 0 };

                    data.var += -val.value;
                    this.updateOrAddDataRow(organised, rowHeader, key, 'Aep', data);    
                });
            },
            addStcData(filtered, organised) {
                organised.fields.unshift({
                    key: 'rowHeader',
                    label: 'Return Period',
                    isRowHeader: true,
                    stickyColumn: true,
                    class: 'header-border'
                });

                filtered.forEach(val => {
                    let key = this.getDataItemKey(val);
                    val.returnPeriods.filter(x => x.returnPeriod > 1)
                        .sort((a, b) => b.returnPeriod - a.returnPeriod)
                        .forEach(rp => {
                            this.updateOrAddDataRow(organised, rp.returnPeriod, key, val.aggregationMethod, {
                                var: -rp.values.max, 
                                tvar: -rp.values.mean
                            });
                        });

                    val.returnPeriods.filter(x => x.returnPeriod === 1).forEach(rp => {
                        this.updateOrAddDataRow(organised, 'AAL', key, val.aggregationMethod, {
                            var: -rp.values.mean, 
                            tvar: -rp.values.mean
                        });
                        this.updateOrAddDataRow(organised, 'SD', key, val.aggregationMethod, {
                            var: rp.values.standardDeviation, 
                            tvar: rp.values.standardDeviation
                        });
                        this.updateOrAddDataRow(organised, 'CoV', key, val.aggregationMethod, {
                            var: rp.values.standardDeviation/(-rp.values.mean), 
                            tvar: rp.values.standardDeviation/(-rp.values.mean)
                        }, 2);
                    });

                    val.thresholds.filter(x => x.threshold.value === 0).forEach(threshold => {
                        this.updateOrAddDataRow(organised, 'Entry %', key, val.aggregationMethod, {
                            var: threshold.probability * 100,
                            tvar: threshold.probability * 100
                        }, 2)
                        this.updateOrAddDataRow(organised, 'Entry year', key, val.aggregationMethod, {
                            var: this.getReturnPeriodString(threshold.probability),
                            tvar: this.getReturnPeriodString(threshold.probability)
                        })
                    });

                    const selectedNode = this.selectedNodes.find(x => x.id == val.nodeId);
                    const nodeResult = this.nodeResults.find(x => x.id === val.nodeId);
                    if(selectedNode && selectedNode.node) {
                        if(selectedNode.node.data.occurrence_limit_value) {
                            val.returnPeriods.filter(x => x.returnPeriod === 1).forEach(rp => {
                                this.updateOrAddDataRow(organised, 'ELoL % (occurence)', key, val.aggregationMethod, {
                                    var: (nodeResult.convertToBaseCurrency(-rp.values.mean, val)/selectedNode.node.data.occurrence_limit_value) * 100,
                                    tvar: (nodeResult.convertToBaseCurrency(-rp.values.mean, val)/selectedNode.node.data.occurrence_limit_value) * 100
                                }, 2);
                            });
                            val.thresholds
                                .filter(x => nodeResult.getThreshold(x.threshold.value, nodeResult.baseCurrency(), val).threshold.value 
                                        === -selectedNode.node.data.occurrence_limit_value)
                                .forEach(x => {
                                    const baseThreshold = nodeResult.getThreshold(x.threshold.value, nodeResult.baseCurrency(), val);
                                    this.updateOrAddDataRow(organised, 'Exhaustion % (occurence)', key, val.aggregationMethod, {
                                        var: baseThreshold.probability * 100,
                                        tvar: baseThreshold.probability * 100
                                    }, 2);
                                    this.updateOrAddDataRow(organised, 'Exhaustion year (occurence)', key, val.aggregationMethod, {
                                        var: this.getReturnPeriodString(baseThreshold.probability),
                                        tvar: this.getReturnPeriodString(baseThreshold.probability)
                                });
                            });
                        };

                        if(selectedNode.node.data.aggregate_limit_value) {
                            val.returnPeriods.filter(x => x.returnPeriod === 1).forEach(rp => {
                                this.updateOrAddDataRow(organised, 'ELoL % (aggregate)', key, val.aggregationMethod, {
                                    var: (nodeResult.convertToBaseCurrency(-rp.values.mean, val)/selectedNode.node.data.aggregate_limit_value) * 100,
                                    tvar: (nodeResult.convertToBaseCurrency(-rp.values.mean, val)/selectedNode.node.data.aggregate_limit_value) * 100
                                }, 2);
                            });
                            val.thresholds.filter(x => {
                                return nodeResult.getThreshold(x.threshold.value, nodeResult.baseCurrency(), val).threshold.value 
                                    === -selectedNode.node.data.aggregate_limit_value
                            }).forEach(x => {
                                const baseThreshold = nodeResult.getThreshold(x.threshold.value, nodeResult.baseCurrency(), val);
                                this.updateOrAddDataRow(organised, 'Exhaustion % (aggregate)', key, val.aggregationMethod, {
                                    var: baseThreshold.probability * 100,
                                    tvar: baseThreshold.probability * 100
                                }, 2)
                                this.updateOrAddDataRow(organised, 'Exhaustion year (aggregate)', key, val.aggregationMethod, {
                                    var: this.getReturnPeriodString(baseThreshold.probability),
                                    tvar: this.getReturnPeriodString(baseThreshold.probability)
                                })
                            });

                        };

                        if(selectedNode.node.data.premium_value) {
                             val.returnPeriods.filter(x => x.returnPeriod === 1).forEach(rp => {
                                this.updateOrAddDataRow(organised, 'AAL / Premium (%)', key, val.aggregationMethod, {
                                    var: (nodeResult.convertToBaseCurrency(-rp.values.mean, val) / selectedNode.node.data.premium_value) * 100, 
                                    tvar: (nodeResult.convertToBaseCurrency(-rp.values.mean, val) / selectedNode.node.data.premium_value) * 100
                                }, 2);
                             })
                        }
                    }
                });
                
            },
            getReturnPeriodString(probability) {
                return `1 in ${this.$options.filters.toNumber(1 / (probability))}`;
            },
            reset() {
                this.data = [];
                this.fields = [];
                this.headers = [];
                this.labelKey = '';
                this.hideSpinner();
            },
            resetSelections() {
                this.selectedNodes = [];
                this.selectedEvent = null;
                this.selectedLossViews = [];
                this.selectedModels = [];
                this.selectedCountries = [];
                this.selectedAreas = [];
            },
            updateOrAddDataRow(organisedData, rowKey, valueKey, aggregationKey, values, decimals = 0) {
                let dataRow = organisedData.data.find(x => x.rowHeader === rowKey);
                if(dataRow) {
                    if(!dataRow[valueKey]) dataRow[valueKey] = {};
                    dataRow[valueKey][aggregationKey] = values;
                } else {
                    let newRow = {
                        rowHeader: rowKey,
                        decimals: decimals
                    };
                    newRow[valueKey] = {}
                    newRow[valueKey][aggregationKey] = values;
                    organisedData.data.push(newRow);
                }
            },
            getDataItemKey(val) {
                let filterCols = this.getFilterColumns();
                let keyVals = this.keyByNode ? [val.nodeId] : [];
                keyVals.push(
                    this.getLossViewIdentifier(val), 
                    filterCols.includes('model') ? val.model : null, 
                    filterCols.includes('country') ? val.country : null, 
                    filterCols.includes('area') ? val.area : null
                );
                return keyVals.join('.');
            },
            orderString(a, b) {
                if(a > b) return 1;
                if(a < b) return -1;
                return 0;
            },
            spinnerMessage(message) {
                this.$store.commit('pricing/results/updateLoadingState', message);
            },
            hideSpinner() {
                this.$store.commit('pricing/results/updateLoadingState', '');
            },
            async onCreated() {
                this.reset();
                //await this.getAvailableNodes();
                if(this.nodes.length !== 0) {
                    if(!this.selectedNodes.length) this.selectedNodes.push(this.nodes[0]);
                    await this.getNodeResults();
                    if (this.type === this.detString) {
                        await this.$store.dispatch('pricing/results/getEventIds', { 
                            networkId: this.networkId,
                            lossViewIdentifiers: this.lossViewOptions.map(x => x.identifier)
                        });
                    }
                }

            },
            async hardRefresh() {
                //this.resetSelections();
                switch (this.type) {
                    case this.detString:
                        if(!this.selectedNodes.length) this.selectedNodes.push(this.nodes[0]);
                        await this.$store.dispatch('pricing/results/getEventIds', { 
                            networkId: this.networkId,
                            lossViewIdentifiers: this.lossViewOptions.map(x => x.identifier)
                        });
                        this.updateTableData();
                        break;
                
                    default:
                        this.$store.commit('pricing/results/clearResults');
                        this.getNodeResults();
                        break;
                }
                
            },
            downloadTable() {
                let self = this;
                let colsToIgnore = ['decimals'];
                let exportData = this.data.map(x => {
                    return Object.keys(x).reduce((acc, k) => {
                        if(k === 'rowHeader') {
                            acc.row = x[k];
                            return acc;
                        } else if (colsToIgnore.includes(k)) {
                            return acc;
                        }
                        acc[k] = x[k][self.selectedCurveType][self.selectedMetricType];
                        return acc;
                    }, {});
                });

                let csv = this.$papa.unparse(exportData);
                let fileName = this.type !== this.detString 
                    ? `${this.networkId}_${this.selectedCurrency}_${this.headers.map(x => x.level.toUpperCase()).join('_')}_${this.selectedCurveType.toUpperCase()}_${this.selectedMetricType.toUpperCase()}`
                    : `${this.networkId}_${this.selectedCurrency}_${this.selectedEvent}_${this.headers.map(x => x.level.toUpperCase()).join('_')}`
                this.$papa.download(csv, fileName);
            },
            async exportToPrime(selection, eventCatalogIds) {
                if(!selection && !this.primeExportMode) return;
                this.primeExportMode = selection;
                if(!eventCatalogIds) {
                    this.$bvModal.show(this.eventCatalogSelectorId);
                    return;
                }
                this.exportToPrimeString = 'Exporting nodes';
                await this.$store.dispatch('pricing/results/exportToPrime', {networkId: this.networkId, mode: selection, eventCatalogIds});
                var self = this;
                setTimeout(() => self.exportToPrimeString = 'Exporting nodes', 500);
                setTimeout(() => self.exportToPrimeString = 'Complete', 1500);
                setTimeout(() => self.exportToPrimeString = self.defaultExportToPrimeString, 3000);
            },
            handleCurrencyChange() {
                if(this.type !== this.detString) {
                    this.updateTableData();
                } else {
                    this.getEventResult(this.selectedEvent);
                }
            },
            getDisplayValue(data, curveType, metricType) {
                const defaultValue = this.type !== this.detString ? "" : 0;
                const nullOrUndefCheck = function(val) {
                    return val === null || val === undefined;
                };
                if(nullOrUndefCheck(data.value[curveType])) return defaultValue;
                return !nullOrUndefCheck(data.value[curveType][metricType])
                    ? data.value[curveType][metricType]
                    : defaultValue;
            },
            getNodeSuffix(node) {
                if(!node.data.layer_type) return '';
                return ' - ' + capitalize(node.data.layer_type || 'ceded');
            }
        },
        async created () {
            await this.onCreated();
        },
        updated() {
            this.$refs.resultTable.$el.style.width = 250 + 150 * (this.fields.length - 1) + 'px'
        },
        watch: {
            networkId: function(val, oldVal) {
                this.resetSelections();
                this.onCreated();
            }
        },
    }
</script>

<style lang="scss" scoped>
</style>
