<template>
    <div>
        <b-container fluid>
            <b-row>
                <b-col>
                    <h3 class="pt-1 ml-2">
                        Structure
                    </h3>
                </b-col>
                <b-col class="d-flex justify-content-end">
                    <UnsavedChangesButton />
                </b-col>
            </b-row>
            <b-row align-h="between" class="mb-2">
                <b-col cols="4">
                    <h4 class="ml-2">Inputs</h4>
                </b-col>
                <b-col class="d-flex justify-content-end">
                    <b-button variant="success"
                        @click="addComponent('Input')"
                        class="mr-2">
                        Add
                    </b-button>
                </b-col>
            </b-row>
            <b-row>
                <b-col>
                    <InputWellComponent />
                </b-col>
            </b-row>
            <b-row align-h="between" class="mb-2">
                <b-col cols="4">
                    <h4 class="ml-2">Subject Loss</h4>
                </b-col>
                <b-col class="d-flex justify-content-end">
                    <b-button variant="success"
                        @click="addComponent('SubjectLoss')"
                        class="mr-2">
                        Add
                    </b-button>
                </b-col>
            </b-row>
            <b-row>
                <b-col>
                    <SubjectLossWellComponent />
                </b-col>
            </b-row>
            <b-row align-h="between" class="mb-2">
                <b-col cols="4">
                    <h4 class="ml-2">Layers</h4>
                </b-col>
                <b-col style="text-align: right;">
                    <b-button variant="success"
                        @click="addComponent('Layer')"
                        class="mr-2">
                        Add
                    </b-button>
                </b-col>
            </b-row>
            <b-row>
                <b-col>
                    <LayerWellComponent />
                </b-col>
            </b-row>
        </b-container>
    </div>
</template>

<script>
import InputWellComponent from './subcomponents/LayersComponents/InputWellComponent';
import LayerWellComponent from './subcomponents/LayersComponents/LayerWellComponent';
import SubjectLossWellComponent from './subcomponents/LayersComponents/SubjectLossWellComponent'
import UnsavedChangesButton from '../../../utils/UnsavedChangesButton';

    export default {
        props: ['programRef', 'analysisId'],
        components: {
            InputWellComponent,
            LayerWellComponent,
            SubjectLossWellComponent,
            UnsavedChangesButton
        },
        data(){
            return {

            }
        },
        methods: {
            addComponent(componentName) {
                this.$store.dispatch('pricing/structure/commitChange', {mutation: `add${componentName}`});
            },
            addInput(){
                this.$store.dispatch('pricing/structure/commitChange', {mutation: 'addInput'});
            },
            addLayer() {
                this.$store.dispatch('pricing/structure/commitChange', {mutation: 'addLayer'});
            }
        }
    }
</script>

<style lang="scss">
    .card-well {
        min-height: 400px;
    }
</style>