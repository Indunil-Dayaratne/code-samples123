<template>
  <div>
    <b-row class="mb-2">
      <b-col class="col-4" v-if="allowFileSelection">
        <multiselect v-model="selectedRdm"
                  track-by="FilePath"
                  label="FileName"      
                  :options="rdmOptions"
                  :showLabels="false"  
                  :preselect-first="true" >
        </multiselect>
      </b-col>
      <b-col class="d-flex flex-row-reverse">
        <b-button @click="$bvModal.show('elt-dependencies')">
          <fa-icon icon="cog" />
        </b-button>
        <elt-dependency-modal />
      </b-col>
    </b-row>
    <b-table ref="taskAssignmentTable"
             striped hover small responsive show-empty            
             primary-key="RowIndex"
             :items="filteredAnalyses"
             :fields="fields"
             :filter="filterObj"
             :filter-function="filterFunction">

      <template v-slot:head(PerspectiveCode)="data">
        <div class="text-center">{{ data.label }}<b-select v-model="selectedPerspective" :options="perspectives" @change="setAllPerspectives" size="sm" v-show="canUnpload" /></div>
      </template>

      <template v-slot:head(GR_GrossLoss)="data">
        <div class="text-center">{{ data.label }}<span class="ml-2 fa fa-question-circle" v-b-tooltip.hover="'Gross Loss'"></span></div>
      </template>

      <template v-slot:head(RL_NetLossPreCat)="data" >
        <div class="text-center">{{ data.label }}<span class="ml-2 fa fa-question-circle" v-b-tooltip.hover="'Net Loss Pre Cat'"></span></div>
      </template>

      <template v-slot:head(RC_NetLossPostCorporateCat)="data">
        <div class="text-center">{{ data.label }}<span class="ml-2 fa fa-question-circle" v-b-tooltip.hover="'Net Loss Post Corporate Cat'"></span></div>
      </template>

      <template v-slot:head(RP_NetLossPostCat)="data">
        <div class="text-center">{{ data.label }}<span class="ml-2 fa fa-question-circle" v-b-tooltip.hover="'Net Loss Post Cat'"></span></div>
      </template>

      <template v-slot:head(RG_ReinsuranceGrossLoss)="data">
        <div class="text-center">{{ data.label }}<span class="ml-2 fa fa-question-circle" v-b-tooltip.hover="'Reinsurance Gross Loss'"></span></div>
      </template>

      <template v-slot:cell(RmsAnalysisID)="data">
        <template v-if="data.item.HasChildren">
          <span>
            <b-btn class="mr-2" @click="toggleRowExpansion(data.item)" size="sm" variant="outline">
              {{data.item.IsExpanded ?'-':'+'}}
            </b-btn>
            {{ data.item.RmsAnalysisID }}
          </span>
        </template>
        <template v-else>       
          <span :style="margin(data.item.RowDepth)">
            {{ data.item.RmsAnalysisID }}
          </span>
        </template>
      </template>

      <template v-slot:cell(PerspectiveCode)="data">
        <b-select v-model="data.item.PerspectiveCode" :options="perspectives" size="sm" :disabled="!canUnpload" />
      </template>

      <template v-slot:cell(Name)="data">
        <b-link @click="showModal(data.item)">{{ data.value }}</b-link>
        <RdmModal :analysis="data.item" :modalId="data.item.RowKey" :perspectives="perspectives" :maxfieldLength="maxfieldLength" :disabled="!canUnpload" />
      </template>

      <template v-slot:cell(UserField1)="data">
        <b-input v-model="data.item.UserField1" size="sm" :maxlength="maxfieldLength" :disabled="!canUnpload" />
      </template>

      <template v-slot:cell(UserField2)="data">
        <b-input v-model="data.item.UserField2" size="sm" :maxlength="maxfieldLength" :disabled="!canUnpload" />
      </template>
    </b-table>
    <b-btn @click="exportToCsv" class="sm" >
      <fa-icon icon="file-excel" class="mr-2" />
      <span>Csv</span>
      <b-spinner small v-if="exportingToCsv"></b-spinner>
    </b-btn>
    <b-btn variant="info" v-show="canUnpload" :disabled="!canUnpload" @click="$bvModal.show('rdm-event-catalog-selector')">
      <fa-icon icon="upload" class="mr-2" />
      <span>Upload to Prime</span>
      <b-spinner small v-if="uploading"></b-spinner>
    </b-btn>
    <div id="btn-elt-upload-to-graphene" class="d-inline">
      <b-btn variant="info" @click="$bvModal.show('elt-conversion-modal')" :disabled="!groupId">
        <fa-icon icon="upload" class="mr-2"/>    
        <span>Upload to Graphene</span>
      </b-btn>
    </div>
    <rdm-upload-check-modal modal-id="rdm-upload-check" @ok="importElts" @cancel="clearImportData"/>
    <elt-conversion-modal modal-id="elt-conversion-modal" @ok="importEltCheck('graphene', $event)" @cancel="clearImportData"/>
    <event-catalog-selector modal-id="rdm-event-catalog-selector" @ok="importEltCheck('prime', $event)" @cancel="clearImportData"/>
  </div>
</template>

<script>
  import azure from 'azure-storage';
  import axios from 'axios';
  import RdmModal from './RdmModal';
  import EltDependencyModal from './EltDependencyModal';
  import RdmUploadCheckModal from './RdmUploadCheckModal';
  import EltConversionModal from './EltConversionModal';
  import EventCatalogSelector from '../../utils/EventCatalogSelectionModal';
  import Multiselect from 'vue-multiselect';
  import { mapState, mapGetters } from 'vuex';
  import stratusApi from '../../../shared/api';

  export default {
    name: "RdmDetails",
     components: {
      RdmModal,
      Multiselect,
      EltDependencyModal,
      RdmUploadCheckModal,
      EltConversionModal,
      EventCatalogSelector
    },
    //props: ['programRef', 'analysisId'],
    props: {
      programRef: {
        type: String,
        required: true
      },
      analysisId: {
        type: String,
        required: true
      },
      allowFileSelection: {
        type: Boolean,
        default: true
      }
    },
    data() {
      return {
        selectedRdm: null,
        totalRows: 0,
        perPage: 20,
        currentPage: 1,
        selectedPerspective: '',
        perspectives: [
          { value: '', text: 'Please select' },
          { value: 'GR', text: 'GR' },
          { value: 'RL', text: 'RL' },
          { value: 'RC', text: 'RC' },
          { value: 'RP', text: 'RP' },
          { value: 'RG', text: 'RG' }
        ],
        maxfieldLength: 15,
        uploading: false,
        exportingToCsv: false,
        filterObj:{expandedRowIndices: {}},
        fields: [
          { key: 'RmsAnalysisID', label: "#", tdClass: 'ra-id', thClass: 'text-center'},
          { key: 'Name', label: "Name" },
          { key: 'Description', label: "Description" },
          { key: 'Peril', label: "Peril" },
          { key: 'Currency', label: "Currency" },
          { key: 'GR_GrossLoss', label: "GR", tdClass: 'text-right'},
          { key: 'RL_NetLossPreCat', label: "RL", tdClass: 'text-right'},
          { key: 'RC_NetLossPostCorporateCat', label: "RC", tdClass: 'text-right'},
          { key: 'RP_NetLossPostCat', label: "RP", tdClass: 'text-right'},
          { key: 'RG_ReinsuranceGrossLoss', label: "RG", tdClass: 'text-right'},
          { key: 'PerspectiveCode', label: "Perspective" },
          { key: 'UserField1', label: "Field 1" },
          { key: 'UserField2', label: "Field 2" }
        ],
        eltConversionParams: {},
        importType: "",
        eventCatalogIds: []
      };
    },
    mounted() {
      //this.$store.dispatch('account/act', {action: 'files/rdm/load'});   
    },
    computed: {
      filteredAnalyses() {
        if (!this.selectedRdm) {
          if(!this.rdms || !this.rdms.length) return [];
          this.selectedRdm = this.rdms[0];
        }
        if(!this.analyses || !Array.isArray(this.analyses)) return [];
        return this.analyses.filter(x => x.RdmName == this.selectedRdm.FileName).sort((a, b) => stratusApi.rdmSorter(a.SortOrder, b.SortOrder));
      },
      ...mapState({
        user: s => s.auth.user,
        groupId: (state, get) => get['account/get']('groupId'),
        analyses: (state, get) => get['account/get']('files/rdm/analyses'),
        rdmsFn: (state, get) => get['account/get']('files/rdmSubmissions'),
        yoa: (state, get) => get['account/get']('files/yoa')
      }),
      rdms() {
        return this.rdmsFn(this.programRef, this.analysisId);
      },
      rdmOptions() {
        return !!this.rdms ? this.rdms : [];
      },
      canUnpload() {
        return true; //this.selectedRdm ? !this.selectedRdm.LossUploaded.includes("RDM") : true;
      },
      anyAnalysesSelected() {
        return this.filteredAnalyses.filter(x => x.PerspectiveCode).length > 0;
      }
    },
    methods: {
      showModal(analysis) {
        this.$bvModal.show(analysis.RowKey);
      },
      setAllPerspectives(code) {
        this.filteredAnalyses.forEach(function (analysis) {
          analysis.PerspectiveCode = code;
        });    
      },
      importEltCheck(type, params) {
        this.importType = type;
        switch (type) {
          case 'prime':
            this.eventCatalogIds = params;
            break;

          case 'graphene':
            this.eltConversionParams = params;
            break;

          default:
            throw `Unknown import type RDM: ${type}`;
        }
        
        this.$root.$emit('bv::show::modal', "rdm-upload-check")
      },
      clearImportData() {
        this.importType = "";
        this.eltConversionParams = null;
        this.eventCatalogIds = null;
      },
      importElts() {
        
        var selectedAnalyses = this.filteredAnalyses.filter(x => x.PerspectiveCode);

        if(!selectedAnalyses.length) {
          this.showError("Please select a perspective for at least one RDM Analysis"); 
          return;
        }
  
        var request = {
          programRef: this.programRef,
          analysisId: this.analysisId,
          fileName: this.selectedRdm.FileName,   
          user: this.user.userName,
          eventCatalogIds: this.eventCatalogIds,
          analyses: selectedAnalyses,
          databaseName: this.selectedRdm.DatabaseName,
          rdmPartitionKey: this.selectedRdm.PartitionKey,
          rdmRowKey: this.selectedRdm.RowKey,
          yoa: Number(this.yoa)
        };

        if (this.importType === 'graphene') {
          request.eventSetName = this.eltConversionParams.eventSet;
          request.simSetName = this.eltConversionParams.simulationSet.partitionKey;
          request.simsetId = this.eltConversionParams.simulationSet.rowKey;
          request.groupId = this.groupId;
        }
        
        var self = this;
        this.uploading = true;
        this.selectedRdm.LossUploaded.push("RDM");
        
        setTimeout(function(){
          switch (self.importType) {
            case 'prime':
              axios.post(config.importEltLogicAppEndpoint, request);
              break;

            case 'graphene':
              axios.post(config.convertEltLogicAppEndpoint, request);
              break;
          
            default:
              console.error(`Unknown importType: ${self.importType}. No further action taken.`);
              break;
          }         
          
          self.uploading = false;
        }, 1000);                 
      },
      filterFunction(row, filter) {
         if(row.GroupID === 0)
           return true;

        let shouldExpand = true;
        let currentRow = row;

        while (shouldExpand && currentRow.ParentRow) {
          shouldExpand = shouldExpand && filter.expandedRowIndices[currentRow.ParentRow.RowIndex] === true;   
          currentRow = currentRow.ParentRow;
        }

        return shouldExpand;      
      },
      toggleRowExpansion(row)
      {
        if(row.HasChildren)
        {
          row.IsExpanded = ! row.IsExpanded;
          this.$set(this.filterObj.expandedRowIndices, row.RowIndex, row.IsExpanded);
        }      
      },
      margin(rowDepth) {
        return "margin-left:" + ((rowDepth * 1.5) + 1.5 ) + "em";
      },
      exportToCsv() {
        this.exportingToCsv = true;
        var self = this;
        
        setTimeout(function(){          

          let data = self.analyses.map(
            ({
                RateSchemes, 
                Treaties,  
                PartitionKey,
                RowKey,
                RowIndex,
                RowDepth,
                SortOrder,
                ParentRow,
                IsExpanded,
                HasChildren,
                IsSelected,
                ...item}
            ) => {
                return item;
              }
          );
          
          var csv = self.$papa.unparse(data);
          self.$papa.download(csv, self.programRef + "_RdmDetails");

          self.exportingToCsv = false;
         }, 500); 
      },
      showError(error) {
        this.$bvToast.toast(error, {
            title: 'ERROR: Cannot Upload ELTs',
            toaster: 'b-toaster-top-center',
            autoHideDelay: 3000,
            variant: "danger"
        });
      }
    }
  }
</script>

<style>
  .ra-id {
    min-width: 5em;
  }
</style>