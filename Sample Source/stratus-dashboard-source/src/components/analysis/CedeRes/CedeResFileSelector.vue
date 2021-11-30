<template>
    <analysis-selection-wrapper :files="files" storeActionOnSelect="files/cedeRes/load" v-slot="file">
        <cede-result-detail :programRef="file.details.programRef" :analysisId="file.details.analysisId" :allowFileSelection="false"/>
    </analysis-selection-wrapper>
</template>

<script>
    import AnalysisSelectionWrapper from '../files/AnalysisSelectionWrapper'
    import CedeResultDetail from './CedeResDetail';
    import { mapState } from 'vuex';
    export default {
        name: 'CedeResultFileSelector',
        components: {
            AnalysisSelectionWrapper,
            CedeResultDetail
        },
        data() {
            return {

            }
        },
        computed: {
            ...mapState({
                files: (state, get) => get['account/get']('files/cedeExp')
            })
        },
        methods: {

        }
    }
</script>

<style lang="scss" scoped>

</style>