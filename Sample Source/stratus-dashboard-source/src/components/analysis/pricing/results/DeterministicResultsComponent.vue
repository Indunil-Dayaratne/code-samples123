<template>
    <b-container fluid>
        <b-row>
            <b-col>
                <h2>Deterministic results</h2>
            </b-col>
        </b-row>
        <b-row>
            <b-col>
                <GrapheneResultsComponent :networkId="networkId" type="DET"/>
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
import {mapState} from 'vuex';
import GrapheneResultsComponent from './GrapheneResultsComponent';
    export default {
        name: 'DeterministicResultsComponent',
        components: {
            GrapheneResultsComponent
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