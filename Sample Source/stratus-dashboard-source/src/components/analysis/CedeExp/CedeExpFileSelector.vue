<template>
    <analysis-selection-wrapper :files="files" storeActionOnSelect="files/cedeExp/load" v-slot="file">
        <cede-exposure-detail :programRef="file.details.programRef" :analysisId="file.details.analysisId" :allowFileSelection="false"/>
    </analysis-selection-wrapper>
</template>

<script>
    import AnalysisSelectionWrapper from '../files/AnalysisSelectionWrapper'
    import CedeExposureDetail from './CedeExposureDetail';
    import { mapState } from 'vuex';
    export default {
        name: 'CedeFileSelector',
        components: {
            AnalysisSelectionWrapper,
            CedeExposureDetail
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