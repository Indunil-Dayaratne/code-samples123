<template>
    <b-card :header="header" header-bg-variant="primary" v-if="clfs.length > 0">
      <b-table striped hover small responsive show-empty
              :items="clfs"
              :fields="clfFields">

        <template v-slot:cell(actions)="row">
          <b-btn size="sm" @click="row.toggleDetails" variant="outline">
            {{ row.detailsShowing ? '-' : '+' }}
          </b-btn>
        </template>

        <template v-slot:head(Perspective)="data">
          <div class="text-center">{{ data.label }}
            <b-select v-model="selectedPerspective" :options="perspectives" @change="setAllPerspectives" size="sm" v-show="canUpload" />
          </div>
        </template>

        <template v-slot:cell(Perspective)="data">         
          <b-select v-model="data.item.SelectedValuesStd.Perspective" :options="perspectives" size="sm" @change="setPerspectives(data.item, data.value)" :disabled="!canUpload" />
        </template>

        <template v-slot:cell(CompanyLoss)="data">
          <span>{{ data.value | toNumber }} </span>
        </template>

        <template v-slot:cell(ConditionLoss)="data">
          <span>{{ data.value | toNumber }} </span>
        </template>

        <template v-slot:cell(ContractLoss)="data">
          <span>{{ data.value | toNumber }} </span>
        </template>

        <template v-slot:cell(UserField1)="data">
          <b-input v-model="data.item.SelectedValuesStd.UserField1" size="sm" :maxlength="maxfieldLength"  @change="setUserField1(data.item)" :disabled="!canUpload" />
        </template>

        <template v-slot:cell(UserField2)="data">
              <b-input v-model="data.item.SelectedValuesStd.UserField2" size="sm" :maxlength="maxfieldLength"  @change="setUserField2(data.item)" :disabled="!canUpload" />
        </template>

        <template v-slot:row-details="row">
          <b-col>
            <b-table striped hover small responsive show-empty
                    :items="row.item.Models"
                    :fields="modelFields">

              <template v-slot:cell(CompanyLoss)="data">
                <span>{{ data.value | toNumber }} </span>
              </template>

              <template v-slot:cell(ConditionLoss)="data">
                <span>{{ data.value | toNumber }} </span>
              </template>

              <template v-slot:cell(ContractLoss)="data">
                <span>{{ data.value | toNumber }} </span>
              </template>

              <template v-slot:cell(MatchesCurrentVersion)="data">
                <b-checkbox v-model="data.value" size="sm" disabled />
              </template>

              <template v-slot:cell(LossCatalogue)="data">
                <b-link @click="showModal(data.item)">{{ data.value }}</b-link>
                <ClfModal :clfDetail="data.item" 
                  :modalId="data.item.RowKey" 
                  :perspectives="perspectives"                   
                  :disabled="!canUpload" />
              </template>

            </b-table>
          </b-col>
        </template>
      </b-table>
      <b-btn variant="info" @click="$bvModal.show(eventSelectorId)">
        <fa-icon icon="upload" class="mr-2"/>    
        <span>Upload to Prime</span>
      </b-btn>
      <div :id="`btn-clf-upload-to-graphene_${runType}`" class="d-inline">
        <b-btn variant="info" @click="runUploadCheck('Graphene')" :disabled="!groupId">
          <fa-icon icon="upload" class="mr-2"/>    
          <span>Upload to Graphene</span>
        </b-btn>
      </div>
      <b-popover v-if="!groupId" :target="`btn-clf-upload-to-graphene_${runType}`" triggers="hover" placement="left">Please select an <b>Analysis Group</b></b-popover>      
      <b-spinner small v-if="uploading"></b-spinner>
      <b-modal :id="`clf_upload_check_${runType}`"
          title="Upload confirmation check" header-bg-variant="info"
          ref="modal" ok-title="Yes" cancel-title="No"
          ok-variant="success" cancel-variant="danger"
          @ok="uploadClfs"
          centered>
          <div class="ml-2 mr-2">
            <b-row>
              Groupings across EVI files for {{header}} will be locked after upload.
            </b-row>
            <b-row class="mt-2">
              <b>Are you sure you want to continue?</b>
            </b-row>
          </div>
        </b-modal>
        <event-catalog-selector :modal-id="eventSelectorId" @ok="runUploadCheck('prime', $event)"/>
    </b-card>
</template>

<script>
import axios from 'axios';
import ClfModal from './ClfModal';
import { mapState, mapGetters } from 'vuex';
import EventCatalogSelector from '../../utils/EventCatalogSelectionModal';

export default {
    name: 'ClfAnalysis',
    components: {
      ClfModal,
      EventCatalogSelector
    },
    props: ['programRef', 'analysisId', 'runType', 'items'],
    data() {
        return {
            clfFields: [
                { key: 'actions', label: '' },
                { key: 'FileName', label: 'Name' },
                { key: 'EviProgramName', label: 'Program', tdClass:'text-right'},
                { key: 'LineOfBusiness', label: 'LoB', tdClass: 'text-right'},
                { key: 'ResultsCurrency', label: "Results Currency", tdClass:'text-right'},
                { key: 'CompanyLoss', label: 'Company - Company Loss', thClass: 'text-right', tdClass: 'text-right' },
                { key: 'ConditionLoss', label: 'Condition - Contract Loss 100%', thClass: 'text-right', tdClass: 'text-right' },
                { key: 'ContractLoss', label: 'Contract 100% - Contract Loss 100%', thClass: 'text-right', tdClass: 'text-right' },
                { key: 'Perspective', label: 'Perspective', thClass: 'text-center' },
                { key: 'UserField1', label: 'Field 1', thClass: 'text-center' },
                { key: 'UserField2', label: 'Field 2', thClass: 'text-center' }    
            ],
            modelFields: [
                { key: 'Model', label: 'Model' },
                { key: 'LossCatalogue', label: 'Loss Catalogue'},
                { key: 'CompanyLoss', label: 'Company - Company Loss', thClass: 'text-right', tdClass: 'text-right' },
                { key: 'ConditionLoss', label: 'Condition - Contract Loss 100%', thClass: 'text-right', tdClass: 'text-right' },
                { key: 'ContractLoss', label: 'Contract 100% - Contract Loss 100%', thClass: 'text-right', tdClass: 'text-right' },
                { key: 'MatchesCurrentVersion', label: 'Matches Current Version', thClass: 'text-right', tdClass: 'text-center' },          
            ],
            perspectives: [
                { value: '', text: 'Please select' },
                { value: 'CompanyLoss', text: 'Company - Company Loss' }
            ],
            totalRows: 0,
            perPage: 20,
            currentPage: 1,
            uploading: false,
            maxfieldLength: 15,
            uploadSystem: null,
            selectedPerspective: '',
            eventCatalogIds: []
        }        
    },
    computed: {
      canUpload() {
        return true;// !(this.clfFiles.filter(x => x.LossUploaded ? x.LossUploaded.includes(this.runType) : false).length)
      },
      ...mapState({
        user: s => s.auth.user,
        groupId: (state, get) => get['account/get']('groupId'),
        clfFilesFn: (state, get) => get['account/get']('files/clfSubmissions'),
        yoa: (state, get) => get['account/get']('files/yoa')
      }),
      clfFiles() {
        return this.clfFilesFn(this.programRef, this.analysisId);
      },
      ...mapState('cedeExposure', [
        'runCatalogTypes'
      ]),
       header() {
           return this.runCatalogTypes.filter(x => x.code === this.runType)[0].text;
       },
       clfs() {
          let clfs = [ ...this.items.reduce(
                      (map, item) => {
                          const { FileName: file, LineOfBusiness: lob, CompanyLoss, ConditionLoss, ContractLoss } = item;
                          const key = file + '_' + lob;
                          const prev = map.get(key);

                          if (prev) {
                              prev.CompanyLoss += CompanyLoss;
                              prev.ConditionLoss += ConditionLoss;
                              prev.ContractLoss += ContractLoss;             
                          } else {
                              let parts = item.FileName.split("_");
                              item.Suffix = parts[parts.length - 1];
                              item.Models =  this.items
                                .filter(x => x.FileName === file && x.LineOfBusiness === lob)
                                .sort((a, b) => a.Model - b.Model);
                              map.set(key, Object.assign({}, item))
                          }
                          return map
                        },
                        new Map()
                        ).values()
                  ];
                 
          clfs.sort((a, b) => {
            if(a.FileName < b.FileName) { return -1 };
            if(a.FileName > b.FileName) { return 1 };
            if(a.LineOfBusiness < b.LineOfBusiness) { return -1 };
            if(a.LineOfBusiness > b.LineOfBusiness) { return 1 };
            return 0
          } );            
          return clfs;                  
       },
       eventSelectorId() {
         return `clf-event-selector-${this.runType}`
       }
    },
    methods: {
      showModal(clfDetail) {
          this.$bvModal.show(clfDetail.RowKey);
      },
      runUploadCheck(uploadSystem, eventCatalogIds) {
          this.uploadSystem = uploadSystem;
          this.eventCatalogIds = eventCatalogIds;
          this.$root.$emit('bv::show::modal', `clf_upload_check_${this.runType}`);
      },
      uploadClfs() {
          var self = this;
          var selectedClfs = null;
          var perspective, userField1, userField2;

          selectedClfs = this.clfs.filter( x=> x.SelectedValuesStd.Perspective)
          if(!selectedClfs.length) {
            this.showError("Please select a perspective for at least one Clf"); 
            return;
          }

          var reqClfs = selectedClfs.map(function(clf) {
            return {
              companyName: clf.Company,
              contractName: clf.Program,
              resultSetName: clf.ResultSetName,
              activitySID: clf.ActivitySID,
              perspective: clf.SelectedValuesStd.Perspective,
              userField1: clf.SelectedValuesStd.UserField1,
              userField2: clf.SelectedValuesStd.UserField2,
              fileName: clf.FileName,       
              runCatalogType: self.runType,
              currencyCode: clf.ResultsCurrency,
              lineOfBusiness: clf.LineOfBusiness,           
              models: clf.Models.map(function(m) {
                return {
                  PartitionKey: m.PartitionKey,
                  RowKey: m.RowKey,
                  selectedValuesStd: clf.SelectedValuesStd
                }
              }),
              clfFile: self.clfFiles.filter(x => x.FileName === clf.FileName).map(function(file) {
                return {
                  PartitionKey: file.PartitionKey,
                  RowKey: file.RowKey,
                  LossUploaded: [... new Set([...file.LossUploaded, self.runType])],
                  ModelAnalysisIds: file.ModelAnalysisIds.filter(x => x.RunCatalogType === self.runType).length 
                    ? file.ModelAnalysisIds.filter(x => x.RunCatalogType === self.runType)[0].ModelAnalysisIds
                    : []
                }               
              })[0]
            }
          });
          
          this.clfFiles.forEach(file => {
            if (!file.LossUploaded.includes(this.runType)) {
              file.LossUploaded.push(this.runType);
            }
          });

          var request = {
            programRef: this.programRef,
            analysisId: this.analysisId,
            user: this.user.userName,
            uploadSystem: this.uploadSystem,
            groupId: this.groupId,
            yoa: Number(this.yoa),
            eventCatalogIds: this.eventCatalogIds,
            clfs: reqClfs
          };

          self.uploading = true;
          setTimeout(function(){
            axios.post(config.uploadClfYeltLogicAppEndpoint, request);
            self.uploading = false;
          }, 1000);   
      },
      setPerspectives(clf, perspective) {
          var self = this; 
          clf.Models.forEach(function (model) {
            model.SelectedValuesStd.Perspective = clf.SelectedValuesStd.Perspective;
          });  
      },
      setAllPerspectives(perspective){
        this.clfs.forEach(c => {
          c.Models.forEach(m => {
            m.SelectedValuesStd.Perspective = perspective;
          });
        });
      },
      setUserField1(clf) {
        var self = this;     
        clf.Models.forEach(function (model) {
          model.SelectedValuesStd.UserField1 = clf.SelectedValuesStd.UserField1;
        });  
      },
      setUserField2(clf) {
        var self = this; 
        clf.Models.forEach(function (model) {   
          model.SelectedValuesStd.UserField2 = clf.SelectedValuesStd.UserField2;
        });  
      },
      showError(error) {
        this.$bvToast.toast(error, {
            title: 'ERROR: Cannot Upload Clfs',
            toaster: 'b-toaster-top-center',
            autoHideDelay: 3000,
            variant: "danger"
        });
      }
    }
}
</script>