<template>
    <b-container fluid>
        <b-row>
            <b-col>
                <b-button variant="success"
                    size="sm"
                    @click="addRelationship"
                    class="float-right m-1">
                    Add
                </b-button>
                <b-button variant="danger"
                    size="sm"
                    v-show="anySelected()"
                    @click="removeRelationship"
                    class="float-right m-1">
                    Remove
                </b-button>
            </b-col>
        </b-row>
        <b-row>
            <b-col class="relationship-table">
                <b-table :items="items"
                    :fields="fields"
                    striped small>
                    <template v-slot:table-colgroup="scope">
                        <col v-for="field in scope.fields"
                            :key="field.key"
                            :style="field.style" >
                    </template>
                    <template v-slot:cell(name)="data">
                        <template v-if="!data.item.source">
                            <div class="small-multiselect">
                                <multiselect :id="data.item.id"
                                    v-model="data.item._sourceObj"
                                    :options="getRelationshipOptions(data.item)"
                                    :multiple="false"
                                    group-values="options"
                                    group-label="type"
                                    :group-select="false"
                                    track-by="id"
                                    :custom-label="sourceLabel"
                                    :show-labels="false"
                                    @input="handleSourceSelection">
                                </multiselect>
                            </div>
                        </template>
                        <template v-else>
                            <div class="cell-text">
                                {{data.item.source ? getNodeById(data.item.source).data.name : ''}}
                            </div>
                        </template>
                    </template>
                    <template v-slot:cell(nodeType)="data">
                        <div class="cell-text">
                            {{data.item.source ? capitalize(getNodeById(data.item.source).data.objType) : ''}}
                        </div>
                    </template>
                    <template v-slot:cell(item)="data">
                        <div class="small-multiselect">
                            <multiselect v-model="data.item.data.item"
                                :options="perspectiveOptions(data.item)"
                                :multiple="false"
                                :show-labels="false"
                                @input="handlePerspectiveSelection(data.item)">
                                <template v-slot:singleLabel="data">
                                    {{capitalize(data.option)}}
                                </template>
                                <template v-slot:option="data">
                                    {{capitalize(data.option)}}
                                </template>
                            </multiselect>
                        </div>
                    </template>
                    <template v-slot:cell(factor)="data">
                        <b-input :id="`factor_${data.item.id}`"
                            v-model="data.item.data.factor"
                            type="number"
                            size="sm"
                            class="factor-input">
                        </b-input>
                    </template>
                    <template v-slot:cell(filter)="data">
                        <div style="position: relative; width: 100%;">
                            <div class="filter-header cell-text text-truncate"
                                :ready="!!data.item.source">
                                {{getFilterHeader(data.item)}}
                            </div>
                            <b-button :id="`edit-filter-btn_${data.item.id}`"
                                variant="primary" small
                                class="edit-filter-btn"
                                @click="activateRelationship(data.item.id)"
                                :ready="!!data.item.source">
                                Edit
                            </b-button>
                        </div>
                    </template>
                    <template v-slot:cell(select)="data">
                        <b-button :id="`delete-btn_${data.item.id}`"
                            pill variant="danger" small
                            @click="handleRelationshipDelete(data.item.id)"
                            class="delete-item-btn">
                            -
                        </b-button>
                    </template>
                </b-table>
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
import {mapState, mapGetters} from 'vuex';
import Multiselect from 'vue-multiselect';
import _ from 'lodash';
    export default {
        name: 'RelationshipTable',
        props: ['layerId'],
        components: {
            Multiselect
        },
        data() {
            return {
                fields: [
                    {
                        key: 'name', 
                        label: 'Name',
                        style: "width: 200px;"
                    },
                    {
                        key: 'nodeType',
                        label: 'Type',
                        style: "width: 50px;"
                    }, 
                    {
                        key: 'item',
                        label: 'Item',
                        style: "width: 150px;"
                    },
                    {
                        key: 'factor',
                        label: 'Factor',
                        style: "width: 60px;"
                    },
                    {
                        key: 'filter',
                        label: 'Filter',
                        style: 'width: 250px;'
                    },
                    {
                        key: 'select',
                        label: '',
                        style: "width: 35px;"
                    }
                ]
            }
        },
        computed: {
            ...mapState({
                layers: state => state.pricing.structure.layers,
                inputs: state => state.pricing.structure.inputs,
                relationshipItems: state => state.pricing.structure.relationshipItems
            }),
            ...mapGetters('pricing/structure', [
                'getRelationshipsByToNode',
                'getNodeById',
                'getRelationshipById',
                'getPerspectiveOptionsForSourceNode',
                'getRelationshipOptions',
                'getPerspectiveLayer'
            ]),
            items() {
                return this.getRelationshipsByToNode(this.layerId);
            },
            nameDropdownOptions() {
                return [
                    {
                        type: 'Inputs',
                        options: this.inputs
                    },
                    {
                        type: 'Layers',
                        options: this.layers.filter(x => x.id !== this.layerId)
                    }
                ]
            }
        },
        watch: {
            items: {
                deep: true,
                handler: function(val, oldVal) {
                    for (const relationship of val) {
                        this.$store.dispatch('pricing/structure/commitChange', {mutation: 'updateRelationship', data: relationship});
                    }
                }
            }
        },
        methods: {
            addRelationship() {
                this.$store.dispatch('pricing/structure/commitChange', {mutation: 'addRelationship', data: this.layerId});
            },
            removeRelationship() {
                this.$store.dispatch('pricing/structure/commitChange', {mutation: 'deleteRelationship', data: this.items.filter(x => x._selectedToRemove).map(x => x.id)});
            },
            anySelected() {
                return this.items.map(x => x._selectedToRemove).some(x => x);
            },
            sourceLabel(item) {
                return item.data.name;
            },
            handleSourceSelection(value, id) {
                var relationship = this.getRelationshipById(id);
                relationship.source = relationship._sourceObj.id;
                relationship.data.sourceType = _.capitalize(relationship._sourceObj.data.objType);
                relationship.data.item = relationship._sourceObj.data.objType !== 'layer' ? 'gross' : relationship._sourceObj.data.layer_type;
                relationship._sourceObj = null;
                this.$store.dispatch('pricing/structure/commitChange', {mutation: 'updateRelationship', data: relationship});
            },
            handlePerspectiveSelection(relationship) {
                const perspLayer = this.getPerspectiveLayer(relationship.source, relationship.data.item);
                relationship.source = perspLayer.id;
                this.$store.dispatch('pricing/structure/commitChange', {mutation: 'updateRelationship', data: relationship});
            },  
            handleRelationshipDelete(id) {
                this.$store.dispatch('pricing/structure/commitChange', {mutation: 'deleteRelationship', data: [id]});
            },
            capitalize(input) {
                return _.capitalize(input);
            },
            getFilterHeader(relationship) {
                if(relationship.data.lossFilter.data.length === 0) return 'None';
                var header = '';
                //let filters = _.uniq(relationship.Data.lossFilter.data.map(x => x.filter));
                let filters = relationship.data.lossFilter.data.map(x => x.filter);
                header += filters.join('/');
                // let values = _.uniq(relationship.Data.lossFilter.data.map(x => (x.not ? 'not ' : '') + x.value.Name));
                // header += `: ${values.join('/')}`
                return header;
            },
            activateRelationship(id) {
                this.$store.commit('pricing/structure/activateRelationship', id);
            },
            perspectiveOptions(relationship) {
                if(!relationship.source) return [];
                return this.getPerspectiveOptionsForSourceNode(relationship.source);
            },
            linkOptions(relationship) {
                if(!relationship) return [];
                return this.getRelationshipOptions(relationship);
            }
        }
    }
</script>

<style >

.relationship-table .cell-text {
    padding-top: 6px; 
    padding-left: 5px;
    width: 100%;
}

.relationship-table .factor-input {
    width: 65px;
    margin-top: 1px;
}

.filter-header {
    position: absolute;
    transition: all 0.2s;
}

td:hover .filter-header[ready] {
    opacity: 0;
    transform: translateY(-8px);
}
</style>