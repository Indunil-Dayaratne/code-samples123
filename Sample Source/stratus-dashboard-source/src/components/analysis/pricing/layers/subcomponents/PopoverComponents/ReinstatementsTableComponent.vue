<template>
    <div>
        <b-row>
            <b-col>
                <b class="float-left pt-2">Reinstatements</b>
                <b-button variant="success"
                    size="sm"
                    @click="addReinstatement"
                    class="float-right m-1">
                    Add
                </b-button>
                <b-button variant="danger"
                    size="sm"
                    v-show="anySelected()"
                    @click="removeReinstatement"
                    class="float-right m-1">
                    Remove
                </b-button>
            </b-col>
        </b-row>
        <b-table :items="layer.data.reinstatements"
            :fields="fields"
            striped small >
            <template v-slot:cell(index)="data">
                <div class="pt-1 text-center">
                    {{ data.index + 1}}
                </div>
            </template>
            <template v-slot:cell(raw_premium_value)="data">
                <b-form-input :id="`rein-num-${data.item.Id}-${layerId}`"
                    type="number"
                    v-model="data.item.raw_premium_value"
                    size="sm"
                    min=1>
                </b-form-input>
            </template>
            <template v-slot:cell(raw_brokerage)="data">
                <b-input-group size="sm">
                    <b-form-input :id="`rein-cost-${data.item.id}-${layerId}`"
                        type="number"
                        v-model="data.item.raw_brokerage"
                        class="last-col-input"
                        min=0>
                    </b-form-input>
                    <b-input-group-append is-text>
                        <b-form-checkbox :id="`rein-select-${data.item.id}-${layerId}`"
                            v-model="data.item._selectedToRemove"
                            class="mr-n2 my-n1">
                            <span class="sr-only">Select reinstatement</span>
                        </b-form-checkbox>
                    </b-input-group-append>
                </b-input-group>
            </template>
        </b-table>
    </div>
</template>

<script>
import { mapGetters } from 'vuex';

    export default {
        props: {
            layerId: Number
        },
        data() {
            return {
                fields: [
                    {
                        key: 'index',
                        label: 'Order'
                    },
                    {
                        key: 'raw_premium_value',
                        label: 'Premium %'
                    },
                    {
                        key:'raw_brokerage',
                        label:'Brokerage %'
                    }
                ]
            }
        },
        computed: {
            ...mapGetters('pricing/structure', {
                getLayerById: 'getLayerById'
            }),
            layer: {
                get() {
                    return this.getLayerById(this.layerId);
                }
            }
        },
        watch: {
            layer: {
                deep: true,
                handler: function(val, oldVal) {
                    this.$store.dispatch('pricing/structure/commitChange', {mutation: 'updateLayer', data: val});
                }
            }
        },
        methods: {
            addReinstatement() {
                this.$store.dispatch('pricing/structure/commitChange', {mutation: 'addReinstatement', data: this.layerId});
            },
            removeReinstatement() {
                if(!this.anySelected) return;
                var data = {
                    layerId: this.layerId,
                    reinstatementIds: this.layer.data.reinstatements.filter(x => x._selectedToRemove).map(x => x.id)
                };
                this.$store.dispatch('pricing/structure/commitChange', {mutation: 'deleteReinstatement', data: data});
            },
            anySelected() {
                return this.layer.data.reinstatements.map(x => x._selectedToRemove).some(x => x);
            }
        }
    }
</script>

<style lang="scss" scoped>
</style>