<template>
    <analysis-selection-wrapper :files="files" storeActionOnSelect="files/rdm/load" v-slot="file">
        <rdm-detail :programRef="file.details.programRef" :analysisId="file.details.analysisId" :allowFileSelection="false" />
    </analysis-selection-wrapper>
</template>

<script>
    import AnalysisSelectionWrapper from '../files/AnalysisSelectionWrapper'
    import RdmDetail from './RdmDetail';
    import { mapState } from 'vuex';
    export default {
        name: 'RdmFileSelector',
        components: {
            AnalysisSelectionWrapper,
            RdmDetail
        },
        data() {
            return {

            }
        },
        computed: {
            ...mapState({
                files: (state, get) => get['account/get']('files/rdms')
            })
        },
        methods: {

        }
    }
</script>

<style lang="scss" scoped>

</style>