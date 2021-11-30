<template>
  <b-tabs tabs v-model="tabIndex" class="analysis-tabs" @input="onTabChange">
    <b-tab title-link-class="analysis-tab-link">
      <template slot="title">
        {{programRef}} 
        <b-spinner v-if="showAnalysisSpinner" small></b-spinner>
      </template>
      <AnalysisDetail :programRef="programRef" :id="id" />
    </b-tab>
    <b-tab title-link-class="analysis-tab-link">
      <template v-slot:title>
        Tasks 
        <b-spinner v-if="showTaskSpinner" small></b-spinner>
      </template>
      <Backlog :taskRef="taskRef" />
    </b-tab>  
    <b-tab title="Source" title-link-class="analysis-tab-link"> 
      <b-card no-body>
        <b-tabs pills card vertical v-model="sourceTabIndex"> 
          <b-tab title="RDM" v-if="displayRdm" title-link-class="analysis-tab-link sub-level-tab-link">
              <RdmDetails :programRef="programRef" :analysisId="id" />
          </b-tab>
          <b-tab title="CLF" v-if="displayClf" title-link-class="analysis-tab-link sub-level-tab-link">
            <ClfDetails :programRef="programRef" :analysisId="id" />
            </b-tab>
          <b-tab title="CEDE Exposure" v-if="displayCedeExposure" title-link-class="analysis-tab-link sub-level-tab-link">
            <CedeExpDetail :programRef="programRef" :analysisId="id"/>
            </b-tab>
          <b-tab title="CEDE Results" v-if="displayCedeResults" title-link-class="analysis-tab-link sub-level-tab-link">
            <CedeResDetail :programRef="programRef" :analysisId="id"/>
          </b-tab>
        </b-tabs>
      </b-card>
    </b-tab> 
    <b-tab title="Pricing" v-if="!!groupId" title-link-class="analysis-tab-link"> 
      <b-card no-body>
        <b-tabs pills card vertical class="sub-tabs"> 
          <b-tab title-link-class="analysis-tab-link sub-level-tab-link">
            <template v-slot:title>
              <fa-icon icon="list-alt" v-b-tooltip.hover="`Pricing Analyses`" class="nav-icon h5"></fa-icon>
            </template>
            <NetworkSelectionComponent />
          </b-tab>
          <b-tab title-link-class="analysis-tab-link sub-level-tab-link">
            <template v-slot:title> 
              <fa-icon icon="money-bill-alt" v-b-tooltip.hover="'Loss Sets'" class="nav-icon h5"/>
            </template>
            <LossSetPageComponent :programRef="programRef" :analysisId="id" />
          </b-tab>
          <b-tab v-if="selectedNetworkId !== null" title-link-class="analysis-tab-link sub-level-tab-link">
            <template v-slot:title> 
              <fa-icon icon="layer-group" v-b-tooltip.hover="'Layers'" class="nav-icon h5"/>
            </template>
            <LayersPageComponent :programRef="programRef" :analysisId="id" />
          </b-tab>
          <b-tab v-if="selectedNetworkId !== null" title-link-class="analysis-tab-link sub-level-tab-link">
            <template v-slot:title> 
              <fa-icon icon="eye" v-b-tooltip.hover="'Loss Views'" class="nav-icon h5"/>
            </template>
            <LossViewPageComponent />
          </b-tab>
          <b-tab title-link-class="analysis-tab-link sub-level-tab-link">
            <template v-slot:title>
              <fa-icon icon="exchange-alt" v-b-tooltip.hover="'Exchange rates'" class="nav-icon h5" />
            </template>
            <ExchangeRateUploadComponent />
          </b-tab>
        </b-tabs>
      </b-card>
    </b-tab> 
     <b-tab title="Results" v-if="selectedNetworkId !== null" title-link-class="analysis-tab-link"> 
      <b-card no-body>
        <b-tabs pills card vertical class="sub-tabs"> 
          <b-tab title-link-class="analysis-tab-link sub-level-tab-link">
            <template v-slot:title> 
              <fa-icon icon="chart-bar" v-b-tooltip.hover="'Stochastic'" class="nav-icon h5"/>
            </template>
            <StochasticResultsComponent />
          </b-tab>
          <b-tab title-link-class="analysis-tab-link sub-level-tab-link">
            <template v-slot:title> 
              <fa-icon icon="globe-americas" v-b-tooltip.hover="'Deterministic'" class="nav-icon h5"/>
            </template>
            <DeterministicResultsComponent />  
          </b-tab>         
        </b-tabs>
      </b-card>
    </b-tab> 
  </b-tabs>   
</template>

<script>
import LayersPageComponent from '@/components/analysis/pricing/layers/LayersPageComponent';
import LossViewPageComponent from '@/components/analysis/pricing/loss views/LossViewPageComponent';
import NetworkSelectionComponent from '@/components/analysis/pricing/networks/NetworkSelectionComponent';
import LossSetPageComponent from "@/components/analysis/pricing/lossSets/LossSetPageComponent"
import StochasticResultsComponent from '@/components/analysis/pricing/results/StochasticResultsComponent';
import DeterministicResultsComponent from '@/components/analysis/pricing/results/DeterministicResultsComponent';
import ExchangeRateUploadComponent from '@/components/analysis/pricing/rates/ExchangeRateUploadComponent';
import {mapState, mapGetters} from 'vuex';

  export default {
    name: "Analysis",
    props: ['programRef', 'id'],
    components: {
      AnalysisDetail: () => import('@/components/analysis/Detail'),
      Backlog: () =>  import('@/views/tasks/Backlog'),
      RdmDetails: () => import('@/components/analysis/Rdm/RdmDetail'),
      ClfDetails: () => import('@/components/analysis/Clf/ClfDetail'),
      CedeExpDetail: () => import('@/components/analysis/CedeExp/CedeExposureDetail'),
      CedeResDetail: () => import('@/components/analysis/CedeRes/CedeResDetail'),
      LayersPageComponent,
      LossViewPageComponent,
      NetworkSelectionComponent,
      LossSetPageComponent,
      StochasticResultsComponent,
      DeterministicResultsComponent,
      ExchangeRateUploadComponent
    },
    data() {
      return {
        displayRdm: true,
        displayClf: true,
        displayCedeExposure: true,
        displayCedeResults: true,
        tabIndex: 0,
        sourceTabIndex: 0,
        tabs: ['AnalysisDetails', 'Tasks', 'Source', 'Pricing', 'Results'],
        sourceTabs: ['RdmDetails', 'ClfDetails', 'CedeExposure', 'CedeResults']
      };
    },
    methods: {    
      hideTab(tabName) {
        switch (tabName) {
          case "RDM":
            this.displayRdm = false;
            break;
          case "CLF":
            this.displayClf = false;
            break;
          case "CEDE-EXP":
            this.displayCedeExposure = false;
            break;
          case "CEDE-RES":
            this.displayCedeResults = false;
            break;
        }
      },
      displayTab( { tab, display } ) {
        switch (tab) {
          case "RDM":
            this.displayRdm = display;
            break;
          case "CLF":
            this.displayClf = display;
            break;
          case "CEDE-EXP":
            this.displayCedeExposure = display;
            break;
          case "CEDE-RES":
            this.displayCedeResults = display;
            break;
        }
      },
      onTabChange(tabIndex) {
        this.tabIndex = tabIndex;
        this.$store.commit('pricing/results/updateTabVisible', this.tabIndex === 4);
        if(tabIndex === 1) {
          this.$bus.emit('resume-tasks-reload');
        } else {
          this.$bus.emit('pause-tasks-reload');
        }
      }
    },
    created() {
      this.$bus.on('hide-tab', this.hideTab);
      this.$bus.on('display-tab', this.displayTab);
      if (this.$route.query.tab) {
        this.tabIndex = 2;
        this.sourceTabIndex = this.sourceTabs.findIndex(tab => tab === this.$route.query.tab);   
      }   
    },
    beforeDestroy() {
      this.$bus.off('hide-tab', this.hideTab);
      clearInterval(this.polling);
    },
    computed: {
      taskRef() {
        return this.programRef + "-" + this.id;
      },
      ...mapState({
        showTaskSpinner: state => state.tasks.showSpinner,
        selectedNetworkId: state => state.pricing.selectedNetworkId,
        showAnalysisSpinner: state => state.account.showSpinner,
        groupId: (state, get) => get['account/get']('groupId')
      })
    }
  }
</script>

<style>
  .analysis-tab-link {
    padding: 0.25rem 0.5rem;
  }

  .sub-level-tab-link {
    background-color: transparent !important;
    color:  #aabbcc !important;
  }

  .sub-level-tab-link.active {
    background-color: transparent !important;
    color:  #20a8d8 !important;
  }

  /* .tabs.sub-tabs .card-header {
    background-color: rgb(47, 53, 58);
  } */
</style>
