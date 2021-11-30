<template>
  <div>
    <b-container fluid>
      <b-row class="mb-3">
        <b-col md="3">
          <multiselect v-model="selectedRunType"
              track-by="value"
              label="text"
              :options="runCatalogTypes"
              :show-labels="false"
              placeholder="Select run type"
              :allow-empty="false">
          </multiselect>
        </b-col>
        <b-btn variant="info"  @click="runCheck" class="sm m-1" :disabled="!canRunAnalysis">       
            <fa-icon icon="cogs" class="mr-2"/>
            <span>Run Analysis</span>
            <b-spinner small v-if="runningAnalysis"></b-spinner>
        </b-btn>
        <b-btn @click="exportToCsv" class="sm m-1" >
            <fa-icon icon="file-excel" class="mr-2" />
            <span>Csv</span>
            <b-spinner small v-if="exportingCsv"></b-spinner>
        </b-btn>
      </b-row>
    </b-container>    
    <template v-for="item in runCatalogTypes">
      <ClfAnalysis v-bind:key="item.value" :programRef='programRef' :analysisId='analysisId' :runType="item.code" :items="getItems(item.code)"/>
    </template>
    <b-modal id="clf_check"
      title="Run confirmation check" header-bg-variant="info"
      ref="modal" ok-title="Continue" cancel-title="Cancel"
      ok-variant="success" cancel-variant="danger"
      @ok="runAnalysis"
      centered>
      <div class="ml-2 mr-2">
        <b-row>
          There are Catradar runs in progress. Ensure the following are true before continuing:
        </b-row>
        <b-row>
          <ol>
            <li>
              The initial CLF import has completed
            </li>
            <li>
              The run type '{{!!selectedRunType ? selectedRunType.text : '[No type selected]'}}' is not in progress
            </li>
          </ol>
        </b-row>
      </div>
    </b-modal>
  </div>
</template>

<script>
  import axios from 'axios';
  import azure from 'azure-storage';
  import ClfAnalysis from './ClfAnalysis';
  import { mapState, mapGetters } from 'vuex';
  import Multiselect from 'vue-multiselect';

  export default {
    name: 'ClfDetails',
    components: {
      ClfAnalysis,
      Multiselect
    },
    props: ['programRef', 'analysisId'],
    data() {
      return {
        exportingCsv: false,
        runningAnalysis: false,
        selectedRunType: null,
        // Known issue here where, once analysis is run the button will correctly be disabled. However
        // if the user changes analysis, then comes back to the original analysis, they will be able 
        // to run the analysis again
        // WB - 11/10/2019
        requestedAnalyses: []
      }
    },
    computed: {
      ...mapGetters('submissionData', {
        clfs: 'clfs'
      }),
      ...mapState({
        clfsFn: (state, get) => get['account/get']('files/clfSubmissions'),
        clfData: (state, get) => get['account/get']('files/clf/analyses')
      }),
      clfs() {
        return this.clfsFn(this.programRef, this.analysisId);
      },
      ...mapGetters('tasks', [
        'clfRunInProgress'
      ]),
      ...mapState('cedeExposure', [
        'runCatalogTypes'
      ]),
      canRunAnalysis() {
        return (this.selectedRunType && this.clfData.filter(x => x.RunType === this.selectedRunType.code).length < 1) ||
            (this.requestedAnalyses.length && this.selectedRunType && !(this.requestedAnalyses && this.requestedAnalyses.includes(this.selectedRunType.code)));
      },
      canUploadWsst() {
        return this.clfs[0] ? !this.clfs[0].LossUploaded.includes("WSST") :  true;       
      },
      canUploadStd() {
        return this.clfs[0] ? !this.clfs[0].LossUploaded.includes("STD"): true;  
      }
    },
    methods: {
      getItems(runType) {
        return this.clfData.filter(x => x.RunType === runType);
      },
      exportToCsv() {
        this.exportingCsv = true;
        var self = this;

        setTimeout(function(){          
            
          let data = self.clfData.map(
            ({
               AALs,
               ClfPath,
               Models,
               SelectedValuesStd,
                ...item
              }
            ) => {
              const val = item;
                return {
                  ...item,
                  SelectedValuesStd: JSON.stringify(SelectedValuesStd)
                };
              }
          );
          
          var csv = self.$papa.unparse(data);
          self.$papa.download(csv, self.programRef + "_Clfs");

          self.exportingCsv = false;
         }, 500);
      },
      runCheck() {
        if(this.clfRunInProgress) {
          this.$root.$emit('bv::show::modal', 'clf_check');
        } else {
          this.runAnalysis();
        } 
      },
      runAnalysis() {

        var self = this;
        self.runningAnalysis = true;

        setTimeout(function(){         
          var companyName = self.clfData[0].Company;

          var contracts = [];
          let result = self.clfData.reduce((result, current) => {
	          if(!result[current.Program]){
              contracts.push({ 
                ContractName: current.Program,
                CompanySID: current.CompanySID,
                ProgramSID: current.ProgramSID,
                ClfPath: current.ClfPath,
                ProgramName: current.EviProgramName,
                ResultsCurrency: current.ResultsCurrency
              });
              result[current.Program] = { ContractName: current.Program, CompanySID: current.CompanySID, ProgramSID: current.ProgramSID, ClfPath: current.ClfPath };
	          }
	          
	          return result;
          }, {});

          var runStandard = (self.selectedRunType.value >= 3);
          var withDemandSurge = (self.selectedRunType.value === 1) || (self.selectedRunType.value === 3);
          
          axios.post(config.runClfAnalysisLogicAppEndpoint, {
             programRef: self.programRef,
             analysisId: self.analysisId,
             companyName: companyName,
             contracts: contracts,
             runType: self.selectedRunType.code,
             runStandard: runStandard,
             withDemandSurge: withDemandSurge
           }
          );

          self.requestedAnalyses.push(self.selectedRunType.code);
          self.runningAnalysis = false;
        }, 1000);   
      },
    }
  }
</script>