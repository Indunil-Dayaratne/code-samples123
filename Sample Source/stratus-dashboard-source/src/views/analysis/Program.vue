<template>
    <b-card no-body>
        <b-card-body>
            <b-container fluid>
                <b-row>
                    <b-col>
                        <nav-menu :links="links" horizontal class="mb-2"/>
                    </b-col>
                    <b-col md="2">
                        <yoa-selector labelCols="3" />
                    </b-col>
                </b-row>
                <b-row>
                    <b-col>
                        <router-view></router-view>
                    </b-col>
                </b-row>
            </b-container>
        </b-card-body>
    </b-card>
</template>

<script>
import { mapState } from 'vuex';
import NavMenu from '../../components/utils/NavMenu';
import YoaSelector from '../../components/analysis/YoaSelector';
export default {
    props: {
        programRef: {
            type: String,
            required: true
        }
    },
    components: {
        NavMenu,
        YoaSelector
    },
    data() {
        return {

        }
    },
    computed: {
        links() {
            return [
                { name: 'program_details', title: this.programRef, spinner: this.showAnalysisSpinner },
                { name: 'program_files', title: 'Files' },
                { name: 'program_tasks', title: 'Tasks' },
                { path: `/program/${this.$route.params.programRef}/source`, title: 'Source', disabled: !this.filesAvailable() },
                { path: `/program/${this.$route.params.programRef}/pricing`, title: 'Pricing', spinner: this.showPricingSpinner },
                { path: `/program/${this.$route.params.programRef}/results`, title: 'Results', spinner: this.showResultsSpinner, disabled: !this.networkLoaded }
            ]
        },
        ...mapState({
            showAnalysisSpinner: state => state.account.showSpinner,
            filesAvailable: (state, get) => get['account/get']('files/areAvailable'),
            networkLoaded: (state, get) => get['pricing/networkLoaded'],
            showPricingSpinner: state => state.pricing.isLoading,
            showResultsSpinner: (state, getters) => getters['pricing/results/isLoading']
        })
    },
    methods: {
    }
}
</script>

<style lang="scss" scoped>

</style>