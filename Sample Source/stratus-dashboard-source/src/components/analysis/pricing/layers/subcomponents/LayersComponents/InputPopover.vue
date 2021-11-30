<template>
    <b-popover :target="String(target)"
        placement="right"
        fallback-placement="flip"
        triggers="click"
        :show.sync="popoverShow"
        custom-class="structure-popover">
        <template v-slot:title >
            <div class="popover-title">
                {{input.data.name}}
                <b-button @click="onClose" class="close popoverClose">&times;</b-button>
            </div>
        </template>
        <b-container fluid
            class="brit-popover-body">
            <b-row>
                <b-col>
                    <b-form-group label="Name:"
                        :label-for="`name-input-${target}`">
                        <b-form-input :id="`name-input-${target}`"
                            v-model="input.data.name">
                        </b-form-input>
                    </b-form-group>
                </b-col>
            </b-row>
            <b-row>
                <b-col>
                    <b-form-group label="Currency:"
                        :label-for="`curr-input-${target}`">
                        <b-form-input :id="`curr-input-${target}`"
                            v-model="input.data.currency"
                            :disabled="true">
                        </b-form-input>
                    </b-form-group>
                </b-col>
            </b-row>
            <b-row>
                <b-col>
                    <b-form-group label="Description:"
                        :label-for="`desc-input-${target}`">
                        <b-form-textarea :id="`desc-input-${target}`"
                            v-model="input.data.description"
                            placeholder="Add description..."
                            rows="3"
                            no-resize>
                        </b-form-textarea>
                    </b-form-group>
                </b-col>
            </b-row>
            <b-row class="mb-3">
                <b-col>
                    <template v-if="!deleteCheck">
                        <b-button block variant="danger" @click="startDeleteCheck()">Delete input</b-button>
                    </template>
                    <template v-else>
                        <div class="confirm-delete-box mt-2">
                            <div class="mb-2" style="font-size: 1rem;">Are you sure?</div>
                            <b-button block variant="danger" @click="deleteInput()">
                                Yes
                            </b-button>
                            <b-button block variant="success" @click="cancelDeleteCheck()">
                                No
                            </b-button>
                        </div>
                    </template>
                </b-col>
            </b-row>
        </b-container>
    </b-popover>
</template>

<script>
import { mapGetters } from 'vuex';
    export default {
        name: 'InputPopover',
        props: {
            target: Number
        },
        data() {
            return {
                popoverShow: false,
                deleteCheck: false
            }
        },
        computed: {
            ...mapGetters('pricing/structure', {
                getInputById: 'getInputById'
            }),
            input: {
                get() {
                    return this.getInputById(this.target);
                }
            },
        },
        watch: {
            input: {
                deep: true,
                handler: function(val, oldVal) {
                    this.$store.dispatch('pricing/structure/commitChange', {mutation: 'updateInput', data: val})
                }
            }
        },
        methods: {
            deleteInput() {
                this.$store.dispatch('pricing/structure/deleteNode', {mutation: 'deleteInput', data: this.target});
            },
            onClose() {
                this.popoverShow = false;
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
    .confirm-delete-box {
        padding: 0.5rem;
        border: 1px solid lightgrey;
        border-radius: 0.2rem;
    }
</style>