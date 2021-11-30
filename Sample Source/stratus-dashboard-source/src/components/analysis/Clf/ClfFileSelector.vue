<template>
    <analysis-selection-wrapper :files="files" storeActionOnSelect="files/clf/load" v-slot="file">
        <clf-detail :programRef="file.details.programRef" :analysisId="file.details.analysisId" />
    </analysis-selection-wrapper>
</template>

<script>
    import AnalysisSelectionWrapper from '../files/AnalysisSelectionWrapper'
    import ClfDetail from './ClfDetail';
    import { mapState } from 'vuex';
    export default {
        name: 'ClfFileSelector',
        components: {
            AnalysisSelectionWrapper,
            ClfDetail
        },
        data() {
            return {

            }
        },
        computed: {
            ...mapState({
                files: (state, get) => get['account/get']('files/clfs')
            })
        },
        methods: {

        }
    }
</script>

<style lang="scss" scoped>

</style>