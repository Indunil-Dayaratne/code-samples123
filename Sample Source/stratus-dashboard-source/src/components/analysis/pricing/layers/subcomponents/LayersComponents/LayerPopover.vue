<template>
    <b-popover :target="String(target)"
        placement="right"
        fallback-placement="flip"
        triggers="click"
        :show.sync="popoverShow"
        custom-class="structure-popover">
        <template v-slot:title>
            <div class="popover-title">
                {{layer.data.name}}
                <b-button @click="onClose" class="close popoverClose">&times;</b-button>
            </div>
        </template>
        <b-container fluid
            class="brit-popover-body">
            <b-row>
                <b-col>
                    <b-form-group label="Name:"
                        :label-for="`name-layer-${target}`">
                        <b-form-input :id="`name-layer-${target}`"
                            v-model="layer.data.name">
                        </b-form-input>
                    </b-form-group>
                </b-col>
            </b-row>
        </b-container>
        <div>
            <b-tabs pills style="height: 400px;">
                <b-tab title="Description">
                    <b-form-group label="Description:"
                        :label-for="`desc-layer-${target}`">
                        <b-form-textarea :id="`desc-layer-${target}`"
                            v-model="layer.data.description"
                            placeholder="Add description..."
                            rows="3"
                            no-resize>
                        </b-form-textarea>
                    </b-form-group>
                    <b-button block variant="primary" @click="copyLayer()">Copy layer</b-button>
                    <template v-if="!deleteCheck">
                        <b-button block variant="danger" @click="startDeleteCheck()">Delete layer</b-button>
                    </template>
                    <template v-else>
                        <div class="confirm-delete-box mt-2">
                            <div class="mb-2" style="font-size: 1rem;">Are you sure?</div>
                            <b-button block variant="danger" @click="deleteLayer()">
                                Yes
                            </b-button>
                            <b-button block variant="success" @click="cancelDeleteCheck()">
                                No
                            </b-button>
                        </div>
                    </template>
                </b-tab>
                <b-tab title="Financials">
                    <LayerFinancialComponent :layerId="target"/>
                </b-tab>
                <b-tab title="Relationships">
                    <template v-if="!relationshipIsActive">
                        <LayerRelationshipComponent :layerId="target"/>
                    </template>
                    <template v-else>
                        <LossFilterComponent />
                    </template>
                </b-tab>
            </b-tabs>
        </div>
    </b-popover>
</template>

<script>
import LayerFinancialComponent from '../PopoverComponents/LayerFinancialComponent';
import LayerRelationshipComponent from '../PopoverComponents/LayerRelationshipComponent';
import LossFilterComponent from '../PopoverComponents/LossFilterComponent';
import { mapState, mapGetters } from 'vuex';
    export default {
        name: 'layerPopover',
        props: {
            target: Number
        },
        components: {
            LayerFinancialComponent,
            LayerRelationshipComponent,
            LossFilterComponent
        },
        data() {
            return {
                popoverShow: false,
                deleteCheck: false
            }
        },
        computed: {
            ...mapGetters('pricing/structure', {
                getLayerById: 'getLayerById',
                relationshipIsActive: 'relationshipIsActive'
            }),
            layer: {
                get() {
                    return this.getLayerById(this.target);
                }
            },
        },
        watch: {
            layer: {
                deep: true,
                handler: function(val, oldVal) {
                    this.$store.dispatch('pricing/structure/commitChange', {mutation: 'updateLayer', data: val})
                }
            }
        },
        methods: {
            onClose() {
                this.popoverShow = false;
                this.$store.commit('pricing/structure/deactivateRelationship');
            },
            deleteLayer() {
                this.$store.dispatch('pricing/structure/deleteNode', {mutation: 'deleteLayer', data: this.target})
            },
            copyLayer() {
                this.$store.dispatch('pricing/structure/commitChange', {mutation: 'copyNode', data: this.target})
            },
            startDeleteCheck() {
                this.deleteCheck = true;
            },
            cancelDeleteCheck() {
                this.deleteCheck = false;
            }
        }
    }
</script>

<style lang="scss">
    .structure-popover {
        white-space: normal;
    }

    .confirm-delete-box {
        padding: 0.5rem;
        border: 1px solid lightgrey;
        border-radius: 0.2rem;
    }
</style>