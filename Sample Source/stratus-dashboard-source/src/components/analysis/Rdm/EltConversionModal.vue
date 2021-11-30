<template>
    <b-modal :id="modalId" title="Select ELT conversion parameters"
        ok-title="Submit" cancel-title="Cancel"
        @ok="onSubmit" @cancel="onCancel" @close="onCancel"
        centered :ok-disabled="eventSet==='' || simulationSet === null" >
        <b-form-group
            id="sim-set-elt-conversion"
            label="Simulation set:"
            label-for="sim-set-elt-select">
            <multiselect id="sim-set-elt-select"
                v-model="simulationSet"
                :options="simulationSets"
                track-by="rowKey"
                label="name"
                placeholder="Select simulation set"
                :allow-empty="false"
                :showLabels="false"
                @select="onSimSetSelection">
                <template slot="option" slot-scope="props">
                    <b-container fluid>
                        <b-row class="mb-2" style="font-size: 1.1rem;">
                            <b-col cols="12">
                                {{props.option.name}}
                            </b-col>
                        </b-row>
                        <b-row class="sim-set-details">
                            <b-col cols="3">Event set name:</b-col>
                            <b-col cols="9" style="text-align: right;">{{props.option.eventSetName}}</b-col>
                            <b-col cols="3">Sims:</b-col>
                            <b-col cols="9" style="text-align: right;">{{props.option.sims}}</b-col>
                            <b-col cols="3">Seed:</b-col>
                            <b-col cols="9" style="text-align: right;">{{props.option.seed}}</b-col>
                            <b-col cols="3">Uploaded by:</b-col>
                            <b-col cols="9" style="text-align: right;">{{props.option.uploadedBy}}</b-col>
                            <b-col cols="3">Uploaded on:</b-col>
                            <b-col cols="9" style="text-align: right;">{{formatDate(props.option.uploadCompleted)}}</b-col>
                        </b-row>
                    </b-container>
                </template>
            </multiselect>
        </b-form-group>
        <b-form-group
            id="event-set-elt-conversion"
            label="Event set:"
            label-for="event-set-elt-select">
            <multiselect id="event-set-elt-select"
                v-model="eventSet"
                :options="eventSets"
                placeholder="Select event set"
                :allow-empty="false">
            </multiselect>
        </b-form-group>
    </b-modal>
</template>

<script>
import Multiselect from 'vue-multiselect';
import {mapState, mapGetters} from 'vuex';
import moment from 'moment';

    export default {
        name: 'EltConversionModal',
        components: {
            Multiselect
        },
        props: {
            modalId: {
                type: String,
                default: 'elt-conversion-modal',
                required: false
            }
        },
        data() {
            return {
                eventSet: "",
                simulationSet: null
            }
        },
        computed: {
            ...mapGetters({
                eventSets: 'elt/eventSets',
                simulationSets: 'elt/simulationSets'
            })
        },
        methods: {
            formatDate(date) {
                return moment(date).format("DD/MM/YY hh:mm");
            },
            clearData() {
                this.eventSet = "";
                this.simulationSet = null
            },
            onSubmit() {
                this.$emit('ok', {
                    eventSet: this.eventSet, 
                    simulationSet: this.simulationSet
                });
                this.clearData();
            },
            onCancel() {
                this.$emit('cancel');
                this.clearData();
            },
            onSimSetSelection(selectedOption, id) {
                if(this.eventSets.includes(selectedOption.eventSetName)) {
                    this.eventSet = selectedOption.eventSetName;
                }
            }
        }
    }
</script>

<style lang="scss" scoped>
    .sim-set-details {
        font-size: 0.8rem;
    }
</style>