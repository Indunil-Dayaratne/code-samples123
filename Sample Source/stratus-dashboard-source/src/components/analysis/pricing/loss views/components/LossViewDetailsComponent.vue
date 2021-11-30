<template>
    <b-container fluid>
        <b-row>
            <b-col class="mb-2 d-flex align-items-center">
                <span class="back-btn" @click="deactivateView">
                    <fa-icon icon="arrow-left" size="lg" />
                </span>
                <span class="detail-header">
                    Detail
                </span>
            </b-col>
        </b-row>
        <b-row>
            <b-col>
                <b-form-group :id="`label-group_${view.id}`"
                    label="Name:"
                    :label-for="`label-input_${view.id}`">
                    <b-input :id="`label-input_${view.id}`"
                        v-model.lazy="view.label">
                    </b-input>
                </b-form-group>
                
            </b-col>
        </b-row>
        <b-row>
            <b-col >
                <template v-if="!view.type">
                    <b-form-group :id="`type-group_${view.id}`"
                        label="Type:"
                        :label-for="`type-select_${view.id}`">
                        <multiselect :id="`type-select_${view.id}`"
                            v-model="view.type"
                            :options="typeOptions"
                            :show-labels="false"
                            :searchable="false"
                            placeholder="Select loss view type" >
                        </multiselect>
                    </b-form-group>
                </template>
                <template v-else>
                     <b-form-group :id="`type-group_${view.id}`"
                        label="Type:"
                        :label-for="`type-input_${view.id}`">
                        <b-input :id="`type-input_${view.id}`"
                            v-model="view.type"
                            :disabled="true">
                        </b-input>
                    </b-form-group>
                </template>
                
            </b-col>
        </b-row>
        <b-row>
            <b-col>
                <b-form-group :id="`sims-group_${view.id}`"
                    label="Simulations:"
                    :label-for="`sims-input_${view.id}`">
                    <div :id="`sims-input_${view.id}`"
                        class="form-control disabled">
                        {{view.simulations | toNumber}}
                    </div>
                </b-form-group>
            </b-col>
        </b-row>
        <b-row>
            <b-col>
                <b-form-group :id="`desc-group_${view.id}`"
                    label="Description:"
                    :label-for="`desc-input_${view.id}`">
                    <b-form-textarea :id="`desc-input_${view.id}`"
                        v-model.lazy="view.description"
                        rows="6"
                        placeholder="Enter description...">
                    </b-form-textarea>
                </b-form-group>
            </b-col>
        </b-row>
        <b-row>
            <b-col>
                <LossViewMappingTable />
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
import {mapState, mapGetters} from 'vuex';
import LossViewMappingTable from './LossViewMappingTableComponent';
import Multiselect from 'vue-multiselect';
    export default {
        name: 'LossViewDetails',
        components: {
            LossViewMappingTable,
            Multiselect
        },
        computed: {
            ...mapState({
                activeView: state => state.pricing.views.activeView,
                typeOptions: state => state.pricing.views.viewTypes
            }),
            ...mapGetters('pricing/views', [
                'getViewById'
            ]),
            view() {
                return this.getViewById(this.activeView);
            },
            cachedView() {
                return Object.assign({}, this.getViewById(this.activeView));
            }
        },
        methods: {
            deactivateView() {
                this.$store.commit('pricing/views/deactivateView');
            }
        },
        watch: {
            view: {
                deep: true,
                handler: function(val, oldVal) {
                    this.$store.dispatch('pricing/views/commitChange', {mutation: 'updateView', data: val});
                }
            }
        }
    }
</script>

<style lang="scss" scoped>
.back-btn {
    cursor: pointer;
    margin-top: -5px;
    padding: 5px;
    border-radius: 0.25em;
    display: inline-block;
    color: #20a8d8;
    
    &:hover {
        background-color: rgba(211,211, 211, 0.4)
    }
}

.detail-header {
    font-size: 20px;
    //padding-top: 8px;
    padding-left: 10px;
    margin-bottom: 5px;
    display: inline-block;
}

.form-control.disabled {
    background-color: #e4e7ea;
    opacity: 1;
}
</style>