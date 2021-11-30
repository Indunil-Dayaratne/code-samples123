<template>
    <b-container fluid>
        <b-row class="mb-3">
            <b-col>
                <multiselect :options="options"
                    v-model="selectedAnalysis"
                    trackBy="analysisId"
                    label="fileName"
                    :showLabels="false"
                    @input="analysisSelected">
                    <template v-slot:option="scope">
                        <div style="font-size: 1.1rem" class="mb-2">{{scope.option.fileName}}</div>
                        <div style="font-size: 0.8rem; font-style: italic;">{{scope.option.summary}}</div>
                    </template>
                </multiselect>
            </b-col>
        </b-row>
        <b-row>
            <b-col>
                <template v-if="selectedAnalysis !== null && !storeLoading">
                    <slot v-bind:details="details"></slot>
                </template>
                <template v-else-if="storeLoading">
                    <b-spinner class="mr-3" v-if="storeLoading" small label="Loading file"></b-spinner>
                    <h5 style="display: inline">
                        Loading file
                    </h5>
                </template>
                <template v-else>
                    <h5>Please select analysis...</h5>
                </template>
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
    import Multiselect from 'vue-multiselect';
    export default {
        name: 'AnalysisSelectionWrapper',
        props: {
            files: {
                type: Array,
                required: true
            },
            storeActionOnSelect: {
                type: String,
                default: ''
            }
        },
        components: {
            Multiselect
        },
        data() {
            return {
                selectedAnalysis: null,
                storeLoading: false
            }
        },
        watch: {
            options(newValue, oldValue) {
                if(!this.selectedAnalysis) return;
                if(!this.options.find(x => 
                    x.programRef === this.selectedAnalysis.programRef && 
                    x.analysisId === this.selectedAnalysis.analysisId)) {
                        this.selectedAnalysis = null;
                }
            }
        },
        computed: {
            options() {
                return this.files.reduce((acc, file) => {
                    acc.push(...file.analyses.map(x => {
                        return {
                            fileName: file.Name,
                            programRef: x.ProgramRef,
                            analysisId: x.AnalysisId,
                            summary: x.Summary
                        }
                    }));
                    return acc;
                }, []);
            },
            details() {
                return {
                    programRef: !!this.selectedAnalysis ? this.selectedAnalysis.programRef : '',
                    analysisId: !!this.selectedAnalysis ? this.selectedAnalysis.analysisId : ''
                }
            }
        },
        methods: {
            async analysisSelected(value) {
                if(this.storeActionOnSelect === '' || value === null) return;
                this.storeLoading = true;
                await this.$store.dispatch('account/act', { action: this.storeActionOnSelect, data: value });
                this.storeLoading = false;
            }
        }
    }
</script>

<style lang="scss" scoped>

</style>