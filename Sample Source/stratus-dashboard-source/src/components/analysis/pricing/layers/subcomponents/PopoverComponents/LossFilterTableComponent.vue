<template>
    <b-container fluid>
        <b-row>
            <b-col md="4" class="pt-2 ">
                <stratus-switch v-model="relationship.data.lossFilter.exclude" true-text="Exclude" false-text="Include"/>
            </b-col>
            <b-col md="4" class="pt-2 ml-n3" >
                <stratus-switch v-model="relationship.data.lossFilter.all" true-text="All" false-text="Any" />
            </b-col>
            <b-col class="mr-n3">
                <b-button variant="success"
                    size="sm"
                    @click="addFilter"
                    class="float-right m-1">
                    Add
                </b-button>
            </b-col>
        </b-row>
        <b-row>
            <b-table id="lossfilter-table"
                :fields="fields"
                :items="relationship.data.lossFilter.data"
                striped small>
                <template v-slot:table-colgroup="scope">
                    <col v-for="field in scope.fields"
                        :key="field.key"
                        :style="field.style" >
                </template>
                <template v-slot:cell(filter)="data">
                    <div class="small-multiselect">
                        <multiselect :id="data.item.id"
                            v-model="data.item.filter"
                            :options="filterOptions"
                            :multiple="false"
                            :show-labels="false"
                            :allow-empty="false">
                        </multiselect>
                    </div>
                </template>
                <template v-slot:cell(not)="data">
                    <div class="mt-1">
                        <b-checkbox v-model="data.item.not">
                            {{data.item.not ? 'Not' : '-'}}
                        </b-checkbox>
                    </div>
                </template>
                <template v-slot:cell(value)="data">
                    <div class="small-multiselect">
                        <multiselect :id="data.item.id"
                            v-model="data.item._valueObj"
                            :options="getFilterOptions(data.item.filter)"
                            track-by="Name"
                            label="Name"
                            :multiple="false"
                            :show-labels="false"
                            :allow-empty="false"
                            @input="handleValueSelection">
                        </multiselect>
                    </div>
                </template>
                <template v-slot:cell(remove)="data">
                    <b-button :id="`delete-btn_${data.item.id}`"
                        pill variant="danger" small
                        @click="handleFilterDelete(data.item.id)"
                        class="delete-item-btn">
                        -
                    </b-button>
                </template>
            </b-table>
        </b-row>
    </b-container>
</template>

<script>
import {mapState, mapGetters} from 'vuex';
import Multiselect from 'vue-multiselect';
import StratusSwitch from '../../../../../utils/StratusSwitch';
    export default {
        name: 'LossFilterTable',
        components: {
            Multiselect,
            StratusSwitch
        },
        data() {
            return {
                fields: [
                    {
                        key: 'filter',
                        label: 'Filter',
                        style: 'width: 150px;'
                    },
                    {
                        key: 'not',
                        label: 'Not?',
                        style: 'width: 100px;'
                    },
                    {
                        key: 'value',
                        label: 'Value',
                        style: 'width: 250px;'
                    }, 
                    {
                        key: 'remove',
                        label: '',
                        style: 'width: 35px;'
                    }
                ]
            }
        },
        computed: {
            ...mapState({
                activeRelationship: state => state.pricing.structure.activeRelationship,
                filterOptions: state => state.pricing.filter.filterColumnOptions
            }),
            ...mapGetters('pricing/structure', [
                'getRelationshipById',
                'getRelationshipForLossFilterById'
            ]),
            ...mapGetters('pricing/filter', [
                'getFilterOptions'
            ]),
            relationship() {
                return this.getRelationshipById(this.activeRelationship) || {
                    data: {
                        lossFilter : {
                            data: []
                        }
                    }
                };
            }

        },
        watch: {
            relationship: {
                deep: true,
                handler: function(val, oldVal) {
                    if(!val.id) return;
                    this.$store.dispatch('pricing/structure/commitChange', {mutation: 'updateRelationship', data: val});
                }
            }
        },
        methods: {
            addFilter() {
                this.$store.dispatch('pricing/structure/commitChange', {mutation: 'addLossFilter', data: this.relationship.id});
            },
            handleFilterDelete(id) {
                this.$store.dispatch('pricing/structure/commitChange', {mutation: 'deleteLossFilter', data: {
                        relationshipId: this.relationship.id,
                        filterId: id
                    }
                });
            },
            handleValueSelection(value, id){
                let relationship = this.getRelationshipForLossFilterById(id);
                if(!relationship) return;
                let filter = relationship.data.lossFilter.data.find(x => x.id === id);
                if(filter._valueObj.Model) { filter.value = filter._valueObj.Model; }
                else if (filter._valueObj.GeographySid) { filter.value = filter._valueObj.GeographySid; }
                this.$store.dispatch('pricing/structure/commitChange', {mutation: 'updateRelationship', data: relationship});
            }
        }
    }
</script>

<style lang="scss">
    .selected-option-switch {
        font-weight: bold;
    }
    .custom-switch {
        .custom-control-label {
            &::before, 
            &::after {
                cursor: pointer;
            }
        } 
    } 
</style>