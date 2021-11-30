<template>
    <b-container fluid>
        <b-row>
            <b-col>
                <h2>Stochastic results</h2>
            </b-col>
            <b-col class="d-flex justify-content-end">
                <RunPricingAnalysisButton flexClass="justify-content-end"/>
            </b-col>
        </b-row>
        <b-row>
            <b-col>
                <GrapheneResultsComponent :networkId="networkId" />
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
import {mapState} from 'vuex';
import GrapheneResultsComponent from './GrapheneResultsComponent';
import RunPricingAnalysisButton from './RunPricingAnalysisButton';
    export default {
        name: 'StochasticResultsComponent',
        components: {
            GrapheneResultsComponent,
            RunPricingAnalysisButton
        },
        computed: {
            ...mapState('pricing',{
                networkId: 'selectedNetworkId'
            })
        }
    }
</script>

<style lang="scss" scoped>

</style>