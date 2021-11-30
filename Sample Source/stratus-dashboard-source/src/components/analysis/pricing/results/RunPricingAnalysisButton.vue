<template>
    <b-container fluid>
        <b-row>
            <b-col :class="['d-flex', flexClass, 'mb-1']">
                <b-button variant="primary"
                    :disabled="disableButton"
                    @click="handleButtonClick">
                    {{buttonText}}
                    <b-spinner v-if="networkProperties.isRunning" small></b-spinner>
                </b-button>
            </b-col>
        </b-row>
        <b-row>
            <b-col :class="['d-flex', flexClass, 'mb-1']">
                <div class="sub-text">
                    {{subText}}
                </div>
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
import {mapState, mapGetters} from 'vuex';
    export default {
        name: 'RunPricingAnalysisButton',
        props: {
            flexClass: {
                type: String,
                required: false,
                default: 'justify-content-start'
            }
        },
        data() {
            return {
                interval: null,
                poll: 3000
            }
        },
        computed: {
            ...mapState({
                isVisible: state => state.pricing.results.visible,
				unsavedChanges: state => state.pricing.structure.unsavedChanges
            }),
            ...mapGetters('pricing', {
                baseNetworkProperties: 'getSelectedNetworkProperties'
            }),
            networkProperties() {
                return this.baseNetworkProperties || {
                    calculationUpToDate: true,
                    isRunning: false
                }
            },
			disableButton() {
				return this.unsavedChanges || this.networkProperties.calculationUpToDate || this.networkProperties.isRunning;
			},
            buttonText() {
				if(this.unsavedChanges) {
					return 'Unsaved Changes';
				}
                if(!this.networkProperties.calculationUpToDate && !this.networkProperties.isRunning) {
                    return 'Run analysis';
                }
                if(this.networkProperties.isRunning) {
                    return 'In progress';
                }
                if(this.networkProperties.calculationUpToDate) {
                    return 'Calculation up to date';
                }
            },
            subText() {
                if(!this.networkProperties.calculationUpToDate) {
                    if(!this.networkProperties.isRunning) return 'Results may not be valid for current definition of the structure. Please re-run.';
                    else return 'Structure has been saved since current run was submitted. Re-run may be required once current run finishes.'
                }
                return '';
            }
        },
        methods: {
            async handleButtonClick() {
                await this.$store.dispatch('pricing/results/runPricingAnalysis');
            }
        },
        beforeDestroy () {
            if(!!this.interval) clearInterval(this.interval);
        },
        mounted () {
            this.interval = setInterval(() => {
                if(this.isVisible) {
                    this.$store.dispatch('pricing/refreshLoadedNetwork');
                }
            }, this.poll);
        },
    }
</script>

<style lang="scss" scoped>
.sub-text {
    color: grey;
    font-style: italic;
    font-size: 0.9em;
}
</style>