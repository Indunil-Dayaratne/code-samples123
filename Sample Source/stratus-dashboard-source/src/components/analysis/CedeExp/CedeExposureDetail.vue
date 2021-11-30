<template>
    <b-container fluid>
        <b-row>
            <h3 class="mb-3">Exposure</h3>
        </b-row>
        <b-row>
            <b-tabs class="analysis-tabs w-100" content-class="height-auto">
                <b-tab title="Summary" >
                    <CedeExposureSummary :programRef="programRef" :analysisId="analysisId" :allowFileSelection="allowFileSelection"/>
                </b-tab>
                <b-tab title="Class mapping" >
                    <CedeClassMappings :programRef="programRef" :analysisId="analysisId"/>
                </b-tab>
            </b-tabs>
        </b-row>
    </b-container>
</template>

<script>
    import CedeExposureSummary from './CedeExposureSummary';
    import CedeClassMappings from './CedeClassMappings';
    export default {
        name: 'CedeExpDetail',
        props: {
            programRef: {
                type: String,
                required: true,
            },
            analysisId: {
                type: String,
                required: true,
            },
            allowFileSelection: {
                type: Boolean,
                default: true
            }
        },
        components: {
            CedeExposureSummary,
            CedeClassMappings
        },
    }
</script>

<style lang="scss">
.cede-exp-tab-header {
    padding: 0.5rem;
}

.height-auto {
    height: auto
}
</style>