<template>
  <b-container fluid>
    <b-row v-if="canModifyPerils" class="mb-3">
      <b-col class="d-flex justify-content-end">
        <b-button @click="saveMappings" variant="primary" >
          Save mappings
          <b-spinner v-if="savingMappings" small></b-spinner>
          <fa-icon v-if="saveMappingsSuccess" icon="check" class="ml-2"/>
          <fa-icon v-if="saveMappingsFailure" icon="times" class="ml-2"/>
        </b-button>
      </b-col>
    </b-row>
    <b-row>
      <b-col>
        <div>  
          <b-table small show-empty
                  :items="perils"
                  :fields="fields">

            <template v-slot:cell(ExposureSetName)="data">
              <span v-if="data.index === 0 || data.item.ExposureSetName !== perils[data.index-1].ExposureSetName">{{ data.value }} </span>
            </template>

            <template v-slot:cell(RpxDetails)="data">
              <template  v-if="data.item.PerilSetCode === 0">
                <b-link @click="showModal(data.item)">{{ data.item.RpxDetails ?  "View Rpx" : "Select Rpx"}}</b-link>
                <RpxDetails 
                  :clfDetail="data.item" 
                  :modalId="data.item.ExposureSetSID.toString()" 
                  :id="data.item.ExposureSetSID.toString()" 
                  :canModify="canModifyPerils"/>
              </template>
                  
            </template>

            <template v-slot:cell(NumberOfLocations)="data">
              <span>{{ data.value | toNumber }} </span>
            </template>

            <template v-slot:cell(PercentageTiv)="data">
              <span>{{ data.value * 100 | toNumber }} </span>
            </template>

            <template v-slot:cell(TotalReplacementValue)="data">
              <span>{{ (data.value / 1000000) | toNumber}} </span>
            </template>

            <template v-slot:cell(IsRemoved)="data">
              <b-checkbox v-if="data.item.PerilSetCode !== 0" v-model="data.item.IsRemoved" size="sm" @input="setMappedPerils(data.item)" :disabled="!canModifyPerils"/>
            </template>

            <template v-slot:cell(MappedPerils)="data">
              <multiselect v-if="data.item.PerilSetCode !== 0" v-model="data.item.MappedPerils"
                          placeholder="Select Perils"
                          group-values="perils" 
                          group-label="perilGroup" 
                          :group-select="true"
                          label="PerilDescription"
                          track-by="PerilSetCode"
                          :options="perilOptions"
                          :multiple="true"
                          :disabled="!canModifyPerils || data.item.IsRemoved">
              </multiselect>
            </template>
          </b-table>
          <b-row class="ml-2" v-if="canModifyPerils">
            <template v-if="allLobsMappingSaved">
              <b-button variant="info" @click="runInProgresscheck('PERIL')">
                <fa-icon icon="cogs" class="mr-2"/>
                <span>Map Perils</span>
                <b-spinner small v-if="running"></b-spinner>
              </b-button>
            </template>
            <template v-else>
              <span id="disabled-perilbtn-wrapper" class="d-inline-block" tabindex="0">
                <b-button disabled variant="info" @click="runInProgresscheck('PERIL')" style="pointer-events: none;">
                  <fa-icon icon="cogs" class="mr-2"/>
                  <span>Map Perils</span>
                  <b-spinner small v-if="running"></b-spinner>
                </b-button>
                <b-tooltip target="disabled-perilbtn-wrapper" placement="right">Ensure all lines of business are mapped</b-tooltip>
              </span>
            </template>
            
          </b-row>
          <b-row v-if="!canModifyPerils">
            <b-col md="1" class="mb-2">
              <multiselect v-model="selectedCurrency" 
                            placeholder="Select" 
                            track-by="CurrencyCode"
                            label="CurrencyCode"
                            :searchable="true" 
                            :showLabels="false"           
                            :options="currencies" >
              </multiselect>
            </b-col>
            <b-col md="2" class="mb-2">
              <multiselect v-model="selectedCatalogType"                      
                            track-by="value"
                            label="text"
                            :showLabels="false"       
                            :options="runCatalogTypes">
              </multiselect>
            </b-col>
            <b-col md="4" class="mb-2">
              <b-button variant="info" :disabled="!canRunAnalysis" @click="runInProgresscheck('LOSS')">
                <fa-icon icon="cogs" class="mr-2"/>
                <span>Run Loss Analysis</span>
              </b-button>
              <b-button variant="info" :disabled="!canRunGeo" @click="runPerilCheck('GEO')">
                  <fa-icon icon="globe-americas" class="mr-2"/>
                  <span>Run Geospatial Analysis</span>              
              </b-button>
              <b-spinner small v-if="running"></b-spinner>
            </b-col>
          </b-row>
          <b-modal id="map_perils_check"
            title="User check" header-bg-variant="info"
            ref="modal" ok-title="Continue" cancel-title="Cancel"
            ok-variant="success" cancel-variant="danger"
            @ok="runPerilCheck('PERIL')"
            centered>
            <div class="ml-2 mr-2">
              <b-row>
                There is at least one CEDE import or Mapping perils in progress. Ensure that the import for the current file or mapping of perils is complete before continuing
              </b-row>
            </div>
          </b-modal>
          <b-modal id="in_progress_check"
            title="Run confirmation check" header-bg-variant="info"
            ref="modal" ok-title="Continue" cancel-title="Cancel"
            ok-variant="success" cancel-variant="danger"
            @ok="runPerilCheck('LOSS')"
            centered>
            <div class="ml-2 mr-2">
              <b-row>
                There are CEDE runs in progress. Ensure the following are true before continuing:
              </b-row>
              <b-row>
                <ol>
                  <li>
                    The initial CEDE import has completed for this file
                  </li>
                  <li>
                    The run type '{{!!selectedCatalogType ? selectedCatalogType.text : '[No type selected]'}}' is not in progress
                  </li>
                </ol>
              </b-row>
            </div>
          </b-modal>
          <b-modal id="user_check"
            title="User confirmation" header-bg-variant="info"
            ref="modal" ok-title="Yes" cancel-title="No"
            ok-variant="success" cancel-variant="danger"
            @ok="runTimingCheck(clickedAnalysisType)"
            @cancel="cancelCheck"
            centered>
            <div>
              Mapping perils will lock peril manipulation for this CEDE file.
            </div>
            <div>
              All analyses run on this file will have the current perils selected.
            </div>
            <div class="mt-4">
              Do you want to continue?
            </div>
          </b-modal>
          <b-modal id="geo_final_check"
            title="Run confirmation check" header-bg-variant="info"
            ref="modal" ok-title="Yes" cancel-title="No"
            ok-variant="success" cancel-variant="danger"
            @ok="runAnalysis(clickedAnalysisType)"
            @cancel="cancelCheck"
            centered>
            <div class="ml-2 mr-2">
              <b-row>
                Geospatial runs are scheduled to reduce traffic on the server during the day.
              </b-row>
              <b-row class="mt-4">
                This run will be scheduled for:
              </b-row>
              <b-row class="text-center mt-2">
                <b-col>{{getRunTime().local()}}</b-col>
              </b-row>
              <b-row class="mt-2">
                Are you sure you want to continue?
              </b-row>
            </div>
          </b-modal>
        </div>
      </b-col>
    </b-row>
  </b-container>
  
</template>

<script>
  import Multiselect from 'vue-multiselect';
  import RpxDetails from './RPXDetails';
  import { mapState, mapGetters } from 'vuex';
  import axios from 'axios';
  import api from '../../../shared/api';

  export default {
    props: ['programRef', 'analysisId', 'items', 'selectedExposureDatabaseSID', 'selectedCede'],
    components: {
      Multiselect, 
      RpxDetails
    },
    data() {
      return {
        perilData: null,
        running: false,
        selectedCurrency: null,
        selectedCatalogType: null,
        request: null,
        clickedAnalysisType: '',
        fields: [
          { key: 'ExposureSetName', label: 'Exposure Set', tdClass: 'table-peril-ellipsis' },
          { key: 'RpxDetails', label: "RPX", tdClass: 'peril-10'},
          { key: 'PerilDescription', label: 'Peril', tdClass:'peril-15' },
          { key: 'NumberOfLocations', label: 'No. of Locations', tdClass: 'text-right peril-10', thClass: 'text-right'},
          { key: 'PercentageTiv', label: '% TIV', tdClass: 'text-right peril-10', thClass: 'text-right'},
          { key: 'TotalReplacementValue', label: 'TIV ($m)', tdClass: 'text-right peril-10', thClass: 'text-right'},
          { key: 'IsRemoved', label: 'Remove', tdClass: 'text-right peril-10', thClass: 'text-right'},
          { key: 'MappedPerils', label: 'Mapped Perils' }
        ],
        perilOptions: [
          {
            perilGroup: 'Earthquake',
            perils: [
              { PerilSetCode: 4, PerilDescription: "Earthquake Shake" },
              { PerilSetCode: 8, PerilDescription: "Fire Following" },
              { PerilSetCode: 128, PerilDescription: "Sprinkler Leakage" },
              { PerilSetCode: 8192, PerilDescription: "Tsunami" },
              { PerilSetCode: 131072, PerilDescription: "Landslide" },
              { PerilSetCode: 4194304, PerilDescription: "Liquefaction" }
            ]
          },
          {
            perilGroup: 'Tropical Cyclone',
            perils: [
              { PerilSetCode: 1, PerilDescription: "Wind" },
              { PerilSetCode: 256, PerilDescription: "Storm Surge" },
              { PerilSetCode: 4096, PerilDescription: "Precipitation Flood" }
            ]
          },
          {
            perilGroup: 'Severe Storm',
            perils: [
              { PerilSetCode: 2, PerilDescription: "Severe Thunderstorm" },
              { PerilSetCode: 64, PerilDescription: "Winter Storm" }
            ]
          },
          {
            perilGroup: 'Other',
            perils: [
              { PerilSetCode: 16, PerilDescription: "Coastal Flood" },
              { PerilSetCode: 32, PerilDescription: "Terrorism" },
              { PerilSetCode: 512, PerilDescription: "Wildfire/Bushfire" },
              { PerilSetCode: 2048, PerilDescription: "Inland Flood" }
            ]
          }           
        ],
        savingMappings: false,
        saveMappingsSuccess: false,
        saveMappingsFailure: false
      };
    },
    created() {
      this.perilData = JSON.parse(JSON.stringify(this.items));
    },
    methods: {
      runInProgresscheck(runType) {
        if(runType === 'PERIL') {
          if(this.cedeImportInProgress || this.mapPerilsInProgress) {
            this.$root.$emit('bv::show::modal', 'map_perils_check');
            return;
          } else {
            this.runPerilCheck('PERIL');
          }
        } else if (runType === 'LOSS') {
          if(this.cedeRunInProgress) {
            this.$root.$emit('bv::show::modal', 'in_progress_check');
            return;
          } else {
            this.runPerilCheck('LOSS');
          }
        }
      },
      runPerilCheck(runType){
        if(this.canModifyPerils){
          this.clickedAnalysisType = runType;
          this.$root.$emit('bv::show::modal', 'user_check');
          return;
        }
        this.runTimingCheck(runType);
      },
      cancelCheck(){
        this.clickedAnalysisType = '';
      },
      runTimingCheck(runType){
        // if(runType==='GEO') {
        //   this.$root.$emit('bv::show::modal', 'geo_final_check');
        //   return;
        // }
        this.clickedAnalysisType = '';
        this.runAnalysis(runType);
      },
      runAnalysis(runType) {        

        if(runType !== 'PERIL' && !this.selectedCurrency) {          
          this.showError("Please select a currency"); 
          return;
        }

        this.setRequest(runType);
        this.running = true;
        var self = this;    

        setTimeout(function(){                
          axios.post(config.runCedeAnalysisLogicAppEndpoint, self.request);
          self.running = false;
          self.clickedAnalysisType = '';
        }, 1000);  
      },
      setRequest(runType) {

        this.selectedCede.MapPerils = false;

        if (runType === 'PERIL') {
          this.selectedCede.MapPerils = true;
        }
        else if(runType === 'LOSS'){
          this.selectedCede.RunCatalogTypes.push(this.selectedCatalogType.code);
        } else {
          this.selectedCede.RunTypes.push(runType);
        }

        this.request = {
          programRef: this.programRef,
          analysisId: this.analysisId,
          user: this.user.userName,
          runType: runType,
          exposureDatabaseSID: this.selectedExposureDatabaseSID,
          exposureDatabaseName: this.perils.filter(x => x.PerilSetCode === 0)[0].ExposureDatabaseName,
          currencyCode: this.selectedCurrency ? this.selectedCurrency.CurrencyCode : '',
          runCatalogType: this.selectedCatalogType.value,
          delayUntil: this.getRunTime(),
          cede: this.selectedCede,
          rpxs: this.rpxs,
          exposuresets: this.perils.filter(x => x.PerilSetCode === 0).map(function(peril) {
            return {
              IsRpxSelected: peril.IsRpxSelected,
              RpxDetails: peril.RpxDetails,
              ExposureSetName: peril.ExposureSetName,
              ExposureSetSID: peril.ExposureSetSID,
              ExposureViewSID: peril.ExposureViewSID,
              PartitionKey: peril.PartitionKey,
              RowKey: peril.RowKey
            }
          })
        }
                
        this.request.exposuresets.forEach(set => {            
            set.IsRpxSelected = set.RpxDetails ? true : false;
            set.Perils = this.perils.filter(x => x.ExposureSetSID ===  set.ExposureSetSID);    
        });
      },
      getRunTime(){
        if(this.$moment.utc().hour() < config.runDelayUntilHour) return this.$moment.utc().hour(config.runDelayUntilHour).minute(0).second(0);
        return this.$moment.utc().add(5, 'm');
      },
      setMappedPerils(item) {          
          if(item.IsRemoved) {
             item.MappedPerils = []
          }
      },
      showModal(exposureSet) {
          this.$bvModal.show(exposureSet.ExposureSetSID.toString());
      },
      showError(error) {
        this.$bvToast.toast(error, {
            title: 'ERROR: Cannot Run Analysis',
            toaster: 'b-toaster-top-center',
            autoHideDelay: 3000,
            variant: "danger"
        });
      },
      async saveMappings() {
        try {
          this.savingMappings = true;
          await api.savePerils(this.perils);
          this.savingMappings = false;
          this.saveMappingsSuccess = true;
          setTimeout(() => this.saveMappingsSuccess = false, 2000);
        } catch (err) {
          this.savingMappings = false;
          this.saveMappingsSuccess = false;
          this.saveMappingsFailure = true;
          setTimeout(() => this.saveMappingsFailure = false, 2000);
        }
      }     
    },
    computed: {
      ...mapState( {
        analysisGetter: (state, get) => get['account/index/getAnalysis'],
        rpxs: (state, get) => get['account/get']('files/cedeExp/dataItem')('rpxs'),
        runCatalogTypes: (state, get) => get['account/get']('files/cedeExp/dataItem')('runCatalogTypes'),
        allLobsMappingSaved: (state, get) => get['account/get']('files/cedeExp/allLobsMappingSaved'),
        user: state => state.auth.user
      }),
      ...mapGetters('tasks', [
        'cedeImportInProgress',
        'cedeRunInProgress',
        'mapPerilsInProgress'
      ]),
      analysis() {
        return this.analysisGetter(this.programRef, this.analysisId);
      },
      currencies() {
        return this.analysis ? this.analysis.CurrencyExchangeRates : [];
      },
      perils() {
        var p = this.perilData.filter(x => x.ExposureDatabaseSID === this.selectedExposureDatabaseSID);
        if(!p.length) return [];
        if (p[0].SelectedCurrencyCode) {         
          this.selectedCurrency = this.currencies.filter(x => x.CurrencyCode === p[0].SelectedCurrencyCode)[0];   
        }

        if (!this.selectedCatalogType) {      
          this.selectedCatalogType = this.runCatalogTypes[0];
        }
        
        return p;
      },
      rpxOptions() {
         var sets = [...new Set(this.rpxs.map(function (item) {
          return  { 
            filePath: item.FilePath, 
            label: item.Program + " - " + item.FilePath, 
            programName: item.Program, 
            source: item.Source, 
            isNew: false  
            };
        }))];    

        return [...new Set(sets.map(o => JSON.stringify(o)))].map(s => JSON.parse(s));     
      },      
      canModifyPerils() {
        return this.selectedCede ? !this.selectedCede.IsPerilsMapped : false;
      },
      canRunAnalysis() {        
        return this.selectedCede ? !this.selectedCede.RunCatalogTypes.includes(this.selectedCatalogType ? this.selectedCatalogType.code : "") : true;
      },
      canRunGeo() {        
        return this.selectedCede ? !this.selectedCede.RunTypes.includes("GEO") : true;
      }
    }
  }
</script>



<style lang="scss" scoped>
  .table td.table-peril-ellipsis {
    width: 15em;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap
  }

  .peril-10 {
    width: 10em;
  }

  .peril-15 {
    width: 15em;
  }

  
</style>
