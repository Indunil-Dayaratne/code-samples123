<template>
    <b-container fluid>
        <b-row>
            <b-col class="mb-2">
                <label :for="`type-input_${layerId}`">Type</label>
                <multiselect :id="`type-input_${layerId}`"
                    v-model="layer.data.type"
                    :options="typeOptions"
                    :searchable="false"
                    placeholder="Select type"
                    :allowEmpty="false"
                    @select="updateSchema">
                </multiselect>
            </b-col>
        </b-row>
        <template v-if="layer.data.type">
            <b-row v-for="(value, name) in financialDefinition" v-bind:key="name">
                <b-col>
                    <template v-if="!value.custom">
                        <b-form-group :id="`${name}-group_${layerId}`"
                            :label="value.text"
                            :label-for="`${name}-input_${layerId}`"
                            v-show="showInput(name)">
                                <b-form-input :id="`${name}-input_${layerId}`"
                                    :type="value.type"
                                    :number="value.isNumber"
                                    v-model="layer.data[name]">
                                </b-form-input>
                        </b-form-group>
                    </template>
                    <template v-if="value.custom && name === 'reinstatements' && showInput(name)">
                        <ReinstatementsTableComponent :layerId="layerId"/>
                    </template>
                    <template v-if="value.custom && name === 'currency'">
                        <b-form-group :id="`${name}-group_${layerId}`"
                            :label="value.text"
                            :label-for="`${name}-input_${layerId}`"
                            v-show="showInput(name)">
                                <multiselect :options="currencyOptions"
                                   v-model="layer.data[name]" />
                        </b-form-group>
                    </template>
                    <template v-if="value.custom && ['raw_expiry_date', 'raw_inception_date'].includes(name)">
                        <b-form-group :id="`${name}-group_${layerId}`"
                            :label="value.text"
                            :label-for="`${name}-input_${layerId}`"
                            v-show="showInput(name)">
                                <datepicker v-model="layer.data[name]" format="dd/MM/yyyy" :bootstrap-styling="true" input-class="date-control" />
                        </b-form-group>
                    </template>
                </b-col>
            </b-row>
        </template>

    </b-container>
</template>

<script>
import { mapState, mapGetters } from 'vuex';
import Multiselect from 'vue-multiselect';
import ReinstatementsTableComponent from './ReinstatementsTableComponent';
import Datepicker from 'vuejs-datepicker';

    export default {
        props: {
            layerId: Number
        },
        components: {
            Multiselect,
            ReinstatementsTableComponent,
            Datepicker
        },
        data() {
            return {
                
            }
        },
        computed: {
            ...mapState('pricing/structure',{
                typeOptions: state => state.layerTypes,
                financialDefinition: state => state.financialDefinition,
                typeSchemaMapping: state => state.schemaMappings
            }),
            ...mapState('pricing', {
                currencyExchangeRates: state => state.exchangeRates
            }),
            ...mapGetters('pricing/structure', {
                getLayerById: 'getLayerById'
            }),
            layer: {
                get() {
                    return this.getLayerById(this.layerId);
                }
            },
            currencyOptions() {
                return this.currencyExchangeRates.map(x => x.currency);
            }
        },
        methods: {
            showInput(name) {
                if(!this.financialDefinition[name] || !this.layer.data.type) return false;
                return this.financialDefinition[name].validFor.includes(this.layer.data.type);
            },
            updateSchema(type, id) {
                this.layer.data.layer_schema = this.typeSchemaMapping[type].schema;
            }
        },
        watch: {
            layer: {
                deep: true,
                handler: function(val, oldVal) {
                    this.$store.dispatch('pricing/structure/commitChange', {mutation: 'updateLayer', data: val});
                }
            }
        }
    }
</script>

<style lang="scss">
    .date-control {
        background-color: white !important;
        cursor: pointer !important;
    }
</style>