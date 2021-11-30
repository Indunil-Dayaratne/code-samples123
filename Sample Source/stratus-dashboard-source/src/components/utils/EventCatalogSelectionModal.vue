<template>
    <b-modal :id="modalId" centered 
        header-bg-variant="secondary"
        header-text-variant="dark"
        size="lg"
        ok-variant="success"
        :ok-disabled="!outputReady"
        cancel-variant="danger"
        @ok="$emit('ok', output.data)"
        @cancel="clearDown()"
        @close="clearDown()">
        <template v-slot:modal-title>
            <b-spinner v-if="output.isLoading" />
            {{`Select event catalog${isMultiple ? 's' : ''}:`}}
        </template>
        <template v-slot:default>
            <prime-event-catalog-selector :id="modalId" :by-splits="bySplits" v-model="output"/>
        </template>
    </b-modal>
</template>

<script>
    import Multiselect from 'vue-multiselect';
    import PrimeEventCatalogSelector from './PrimeEventCatalogSelector';
    import axios from 'axios'
    export default {
        name: 'EventCatalogSelector',
        components: {
            Multiselect,
            PrimeEventCatalogSelector
        },
        props: {
            modalId: {
                type: String,
                required: true
            },
            bySplits: {
                type: Array,
                default: function() {
                    return [];
                }
            }
        },
        data() {
            return {
                outputTemplate: {
                    isLoading: false,
                    data: null
                },
                output: {
                    isLoading: false,
                    data: null
                },
            }
        },
        computed: {
            isMultiple() {
                return this.bySplits.length > 1; 
            },
            outputReady() {
                return !!this.output.data
            },
        },
        methods: {
            clearDown() {
                this.output = Object.assign({}, this.outputTemplate);
                this.$emit('cancel');
            }
        }
    }
</script>

<style lang="scss" scoped>
.option-description {
    font-size: 1.25rem;
}

.option-id {
    font-size: 0.85rem;

}
</style>