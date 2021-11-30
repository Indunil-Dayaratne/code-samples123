<template>
    <b-container fluid>
        <b-row>
            <b-col>
                <h3 class="pt-1">Loss Views</h3>
            </b-col>
            <b-col class="d-flex justify-content-end">
                <UnsavedChangesButton />
            </b-col>
        </b-row>
        <b-row>
            <b-col>
                <template v-if="!activeLossView">
                    <LossViewTable />
                </template>
                <template v-else>
                    <LossViewDetails />
                </template>
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
import {mapState, mapGetters} from 'vuex';
import LossViewTable from './components/LossViewTableComponent';
import LossViewDetails from './components/LossViewDetailsComponent';
import UnsavedChangesButton from '../../../utils/UnsavedChangesButton';
    export default {
        name: 'LossViewPageComponent',
        components: {
            LossViewTable,
            LossViewDetails,
            UnsavedChangesButton
        },
        computed: {
            ...mapState({
                activeLossView: state => state.pricing.views.activeView
            })
        }
    }
</script>

<style lang="scss" scoped>

</style>