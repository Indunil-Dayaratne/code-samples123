<template>
    <b-container fluid>
        <b-row>
            <b-col>
                <h3 class="pt-1">
                    Loss Sets
                </h3>
            </b-col>
        </b-row>        
        <b-row>
            <b-col>
                <template v-if="!activeLossSet">
                    <LossSetTable />
                </template>
                <template v-else>
                    <LossSetDetails />
                </template>
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
import {mapState, mapGetters} from 'vuex';
import LossSetTable from './components/LossSetTableComponent';
import LossSetDetails from './components/LossSetDetailsComponent';

    export default {
        name: 'LossSetPageComponent',
        components: {
            LossSetTable,
            LossSetDetails            
        },
        computed: {
            ...mapState({
                activeLossSet: state => state.pricing.lossSets.activeLossSet
            })
        }        
    }

</script>