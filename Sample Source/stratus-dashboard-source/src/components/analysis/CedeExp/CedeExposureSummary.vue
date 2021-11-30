<template>
  <div v-if="exposureData.length > 0">
    <b-row v-show="allowFileSelection" class="col-lg-5 col-sm-12 mb-2">
      <multiselect v-model="selectedCede"
              track-by="FilePath"
              label="FileName"      
              :options="exposureCedes"
              :showLabels="false"  
              :preselect-first="true" >
      </multiselect>
    </b-row>
    <b-card header="EXPOSURE SETS" header-bg-variant="info">    
      <perils :programRef="programRef"
              :analysisId="analysisId"
              :items="perils" 
              :selectedExposureDatabaseSID="selectedExposureDatabaseSID"
              :selectedCede="selectedCede"/>
    </b-card>
    <b-card header-tag="header" header-bg-variant="info">
      <template v-slot:header>
        <div  class="mb-0 text-left">
          DATA QUALITY
          <b-select class="float-right col-sm-2" v-model="selectedPerilSetCode" :options="perilOptions"></b-select>
          <b-select class="float-right col-sm-4" v-model="selectedExposureSetSID" :options="exposureSets"></b-select>
        </div>
      </template>
      
      <b-row>
        <b-col md="6" lg="4" class="border border-secondary">
          <summaryChart :items="geoLevels" 
                        title="Geocode Match" 
                        :selectedExposureDatabaseSID="selectedExposureDatabaseSID"
                        :selectedExposureSetSID="selectedExposureSetSID"
                        :selectedPerilSetCode="selectedPerilSetCode"/>
        </b-col>

        <b-col md="6" lg="4" class="border border-secondary">
          <summaryChart :items="constructions" 
                        title="Construction" 
                        :selectedExposureDatabaseSID="selectedExposureDatabaseSID"
                        :selectedExposureSetSID="selectedExposureSetSID"
                        :selectedPerilSetCode="selectedPerilSetCode"/>
        </b-col>

        <b-col md="6" lg="4" class="border border-secondary">
          <summaryChart :items="occupancies" 
                        title="Occupancy"
                        :selectedExposureDatabaseSID="selectedExposureDatabaseSID"
                        :selectedExposureSetSID="selectedExposureSetSID"
                        :selectedPerilSetCode="selectedPerilSetCode"/>
        </b-col>

        <b-col md="6" lg="4" class="border border-secondary">
          <summaryChart :items="stories" 
                        title="No. of Stories"
                        :selectedExposureDatabaseSID="selectedExposureDatabaseSID"
                        :selectedExposureSetSID="selectedExposureSetSID"
                        :selectedPerilSetCode="selectedPerilSetCode"/>
        </b-col>

        <b-col md="6" lg="4" class="border border-secondary">
          <summaryChart :items="yearBuilts" 
                        title="Year Built"
                        :selectedExposureDatabaseSID="selectedExposureDatabaseSID"
                        :selectedExposureSetSID="selectedExposureSetSID"
                        :selectedPerilSetCode="selectedPerilSetCode"/>
        </b-col>
      </b-row>
    </b-card>

    <b-card header="HAZARD" header-bg-variant="info">
      <b-card-group deck>
        <b-card header="WS Tiers">
          <wsTiers :items="wsTiers" 
                   :selectedExposureDatabaseSID="selectedExposureDatabaseSID" 
                   :selectedExposureSetSID="selectedExposureSetSID"/>
        </b-card>
        <b-card header="Californian DOI Zones">
          <californiaDOIZone :items="carlifoniaEQZones" 
                             :selectedExposureDatabaseSID="selectedExposureDatabaseSID"
                             :selectedExposureSetSID="selectedExposureSetSID"/>
        </b-card>
      </b-card-group>

      <b-card header="Distance to Coast" class="mt-2">
        <distanceToCoast :items="distanceToCoast" 
                         :selectedExposureDatabaseSID="selectedExposureDatabaseSID" 
                         :selectedExposureSetSID="selectedExposureSetSID"/>
      </b-card>
    </b-card>
  </div>
</template>

<script>
  import PieChart from '@/shared/charts/PieChart';
  import azure from 'azure-storage';
  import summaryChart from "./SummaryChart";
  import wsTiers from "./WsTiers";
  import distanceToCoast from "./DistanceToCoast";
  import californiaDOIZone from "./CarlifoniaEQZone";
  import perils from "./Perils";
  import { mapState, mapGetters } from 'vuex';
  import Multiselect from 'vue-multiselect';

  export default {
    components: {
      PieChart,
      summaryChart,
      wsTiers,
      distanceToCoast,
      californiaDOIZone,
      perils,
      Multiselect
    },
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
    }, //['programRef', 'analysisId'],
    data() {
      return {
        selectedCede: null,
        selectedExposureSetSID: 0,
        selectedPerilSetCode: 0      
      }
    },
    created() {     
         
    },
    computed: {
      ...mapState( {
        exposureData: (state, get) => get['account/get']('files/cedeExp/dataItem')('exposureSummary'),
        geoLevels: (state, get) => get['account/get']('files/cedeExp/dataItem')('geoLevels'),
        constructions: (state, get) => get['account/get']('files/cedeExp/dataItem')('constructions'),
        occupancies: (state, get) => get['account/get']('files/cedeExp/dataItem')('occupancies'),
        perils: (state, get) => get['account/get']('files/cedeExp/dataItem')('perils'),
        stories: (state, get) => get['account/get']('files/cedeExp/dataItem')('stories'),
        subAreas: (state, get) => get['account/get']('files/cedeExp/dataItem')('subAreas'),
        wsTiers: (state, get) => get['account/get']('files/cedeExp/dataItem')('wsTiers'),
        yearBuilts: (state, get) => get['account/get']('files/cedeExp/dataItem')('yearBuilts'),
        carlifoniaEQZones: (state, get) => get['account/get']('files/cedeExp/dataItem')('carlifoniaEQZones'),
        distanceToCoast: (state, get) => get['account/get']('files/cedeExp/dataItem')('distanceToCoast'),
        exposureCedesFn: (state, get) => get['account/get']('files/cedeExpSubmissions')
      }),
      exposureCedes() {
        return this.exposureCedesFn(this.programRef, this.analysisId);
      },
      selectedExposureDatabaseSID() {
        if (!this.selectedCede) {
          if(!this.exposureCedes.length) return 0;
          this.selectedCede = this.exposureCedes[0];
        }
          let filtered = this.exposureData.filter(x => x.ExposureDatabaseName === this.selectedCede.DatabaseName);
          if(!filtered.length) return 0;
          return filtered[0].ExposureDatabaseSID;
      },
      exposureSets() {

        var filtered = this.exposureData.filter(x => x.ExposureDatabaseSID === this.selectedExposureDatabaseSID);

         var sets = [...new Set(filtered.map(function (item) {
          return { value: item.ExposureSetSID, text: item.ExposureSetName };
        }))];          

        var uniqueSets = [...new Set(sets.map(o => JSON.stringify(o)))].map(s => JSON.parse(s));
        var result = [{ value: 0, text: 'All' }, ...uniqueSets];
        this.selectedExposureSetSID = result[0].value;
        return result;
      },      
      perilOptions() {
        var filtered = this.perils.filter(x => (this.selectedExposureSetSID == 0 || x.ExposureSetSID === this.selectedExposureSetSID)
          && x.ExposureDatabaseSID === this.selectedExposureDatabaseSID);
        
         var sets = [...new Set(filtered.map(function (item) {
          return { value: item.PerilSetCode, text: item.PerilDescription };
        }))];          

        var uniqueSets = [...new Set(sets.map(o => JSON.stringify(o)))].map(s => JSON.parse(s));
        if(!uniqueSets.length) return [];
        this.selectedPerilSetCode = uniqueSets[0].value;
        return uniqueSets;
      }
    }
  }
</script>
