<template>
  <div>
    <b-card header="SUMMARY" header-bg-variant="primary" no-body>    
      <b-col class="mt-3">
        <b-form-group label="Account Name:" label-for="txtAccountName" label-size="sm" label-cols="2">
          <b-input id="txtAccountName" v-model="accountName" size="sm" disabled class="col-3" />
        </b-form-group>

        <b-form-group label="Program Ref:" label-for="txtProgramRef" label-size="sm" label-cols="2">
          <b-input id="txtProgramRef" v-model="programRef" size="sm" disabled class="col-3" />
        </b-form-group>

        <b-form-group label="Summary:" label-for="txtSummary" label-size="sm" label-cols="2">
          <b-input id="txtSummary" v-model="summary" size="sm" disabled class="col-3" />
        </b-form-group>

        <b-form-group label="Requested By:" label-for="txtRequestedBy" label-size="sm" label-cols="2">
          <b-input id="txtRequestedBy" v-model="requestedBy" size="sm" disabled class="col-3" />
        </b-form-group>

        <b-form-group label="Requested On:" label-for="txtRequestedOn" label-size="sm" label-cols="2">
          <b-input id="txtRequestedOn" v-model="requestedOn" size="sm" disabled class="col-3" />
        </b-form-group>

        <b-form-group label="Data File Location:" label-for="txtDataFileLocation" label-size="sm" label-cols="2">
          <b-textarea id="txtDataFileLocation" v-model="dataFileLocations" size="sm" disabled rows="5"/>
        </b-form-group>
      </b-col>
      </b-card>
      <b-card header="GROUPING" header-bg-variant="primary" no-body v-if="!isProgram">
        <b-col>
          <b-row class="mt-3 mb-3">
            <b-col  md="4" class="small-multiselect">
              <multiselect v-model="selectedGroup" 
                placeholder="Select analyses group" 
                track-by="groupId"
                label="groupName"      
                :options="groups"
                :disabled="disableGroup"
                @select="onGroupSelect">
              </multiselect>
            </b-col>
            <b-col md="4" v-if="!groupId"> 
              <b-btn  @click="runGroupingCheck('UPDATE')"><fa-icon icon="search" class="mr-2"/>Add Analysis to Existing Group</b-btn>              
              <b-btn  @click="runGroupingCheck('CREATE')"><fa-icon icon="search" class="mr-2"/>Create New Group</b-btn>
            </b-col>   
          </b-row>
        </b-col>
        <b-col v-if="groupAnalyses.length > 0">
          <b-table striped 
              hover 
              small 
              bordered 
              show-empty 
              :fields="analysiFields" 
              :items="groupAnalyses" 
              :current-page="currentPage" 
              :per-page="perPage">
            <template v-slot:cell(programRef)="data">
              <b-link :to="{ name:'AnalysisDetails', params: { programRef: data.value, id:data.item.analysisId } }" target="_blank">{{ data.value }}</b-link>
            </template>
          </b-table>
        <nav>
          <b-pagination :total-rows="groupTotalRows" :per-page="perPage" v-model="groupCurrentPage" prev-text="Prev" next-text="Next" hide-goto-end-buttons />
        </nav>
        </b-col>
      </b-card>
      <b-card header="SUBMISSION FILES" header-bg-variant="primary" no-body v-if="!isProgram">
        <b-col class="mt-3">
          <b-table striped hover small bordered show-empty :fields="dataSourcFields" :items="submissionFiles" :current-page="currentPage" :per-page="perPage">
          </b-table>
          <nav>
            <b-pagination :total-rows="totalRows" :per-page="perPage" v-model="currentPage" prev-text="Prev" next-text="Next" hide-goto-end-buttons />
          </nav>
        </b-col>
      </b-card>
      <b-card header="YEAR OF ACCOUNT" header-bg-variant="primary" no-body v-if="isProgram">
        <b-col class="mt-3" >
          <yoa-selector prefix="Select " label-cols="2" select-cols="3" label-size="sm" />
        </b-col>
      </b-card>
      <b-modal id="grouping_check" ref="grouping_check"
        title="User confirmation" header-bg-variant="info"
        ok-title="Yes" cancel-title="No"
        ok-variant="success" cancel-variant="danger"
        @ok="updateCreateGroup"
        @cancel="cancelCheck"
        @shown="onModalShow"
        centered>
        <b-input ref="newGroupName"
          v-model='newGroupName' 
          v-if="clickedButton == 'CREATE'" 
          placeholder="Enter group name" 
          :state="$v.newGroupName.$dirty ? !$v.newGroupName.$error : null"
          class="mb-4" />
        <div>
          Adding this analysis to a group will lock the grouping for this analysis.
        </div>
        <div class="mt-4">
          Do you want to continue?
        </div>
    </b-modal>
  </div>
</template>

<script>
  import azure from 'azure-storage';
  import Multiselect from 'vue-multiselect';
  import { mapState, mapGetters } from 'vuex';
  import { validationMixin } from 'vuelidate'
  import { required } from "vuelidate/lib/validators";
  import { ACCOUNT_TYPES } from '../../shared/types';
  import YoaSelector from './YoaSelector';

  export default {
    name: 'Detail',
    mixins: [validationMixin],
    props: {
      programRef: {
        type: String,
        required: true
      },
      id: {
        type: String,
        required: false
      },
      type: {
        type: Object,
        default: () => ACCOUNT_TYPES.analysis
      }
    },
    components: {
      Multiselect,
      YoaSelector
    },
    validations: {
      newGroupName: { required }      
    },
    data() {
      return {
        dateFormat: config.dateFormat,
        dataSourcFields: [
          { key: 'FileName', label: 'File Name' },
          { key: 'DatabaseName', label: 'Database Name' },
          { key: 'DataType', label: 'Data Type' },
          { key: 'SourceType', label: 'Source Type' }
        ],
        analysiFields: [
          { key: 'programRef', label: 'Program Ref' },
          { key: 'accountName', label: 'Account Name' },
          { key: 'summary', label: 'Summary' },
          { key: 'requestedOn', label: 'Requested On' },
          { key: 'requestedBy', label: 'Requested By'}
        ],
        perPage: 20,
        currentPage: 1,
        clickedButton: '',
        newGroupName: '',
        selectedGroup: null,
        groupCurrentPage: 1
      }
    },
    computed: {
      ...mapState( {
        accountName: (state, get) => get['account/get']('accountName'),
        summary: (state, get) => get['account/get']('summary'),
        requestedOn: (state, get) => get['account/get']('requestedOn'),
        dataFileLocation: (state, get) => get['account/get']('dataFileLocation'),
        requestedBy: (state, get) => get['account/get']('requestedBy'),
        submissionFiles: (state, get) => get['account/get']('files/runSubmissions'),
        groupId: (state, get) => get['account/get']('groupId'),
        group: (state, get) => get['account/get']('group'),
        groupAnalyses: (state, get) => get['account/get']('groupAnalyses'),
        groups: (state, get) => get['account/get']('groups'),  
        folders: (state, get) => get['account/get']('files/folders') 
      }),
      dataFileLocations() {
        switch (this.type.name) {
          case ACCOUNT_TYPES.analysis.name:
            return this.dataFileLocation;

          case ACCOUNT_TYPES.program.name:
            return this.folders.join('\n');
        
          default:
            return "";
        }
      },
      disableGroup() {
        return this.groupId ? true : false;          
      },
      formatedDate() {
        this.$moment(this.requestedOn).format(config.dateFormat);
      },
      totalRows() {
        this.submissionFiles.length;          
      },
      groupTotalRows() {
        this.groupAnalyses.length;          
      },
      isProgram() {
        return this.type.name === ACCOUNT_TYPES.program.name;
      }
    },
    methods: {
      cancelCheck() {
       this.clickedButton = ''
      },
      updateCreateGroup(bvModalEvt) {

        if (this.clickedButton === "CREATE") {
          bvModalEvt.preventDefault();
          this.$v.$touch();
          if (this.$v.$invalid) {
              return;
          }

          this.createGroup(); 

          this.$nextTick(() => {
            this.$refs.grouping_check.hide();
          });
        }
        else {
          this.updateGroup();
        }
      },
      updateGroup() {
        this.selectedGroup.analyses.push(`${this.programRef}-${this.id}`)
        this.$store.dispatch('account/act', { action: 'createOrUpdateGroup', data: { group: this.selectedGroup }} );
      },
      createGroup() {
        this.selectedGroup = {
          groupName: this.newGroupName, 
          analyses: [`${this.programRef}-${this.id}`], 
          networkIds: []  
        }
        this.$store.dispatch('account/act', { action: 'createOrUpdateGroup', data: { group: this.selectedGroup }} );
      },
      runGroupingCheck(btnName){        
        this.clickedButton = btnName;
        this.$root.$emit('bv::show::modal', 'grouping_check');
      },
      onGroupSelect(selectedGroup) {       
        this.$store.dispatch('account/act', { action: 'getAnalysisGroups', data: { partitionKey:  selectedGroup.partitionKey, rowKey: selectedGroup.rowKey }});
      },
      onModalShow() {            
        if (this.$refs.newGroupName) {
          this.$v.$touch(); 
          this.$refs.newGroupName.focus();
        }
      },
      onYoaChange(value) {
        this.$store.dispatch('account/mutate', {
          mutation: 'files/setYoa',
          data: value
        });
      }
    },
    created() {      
      //this.$store.dispatch('account/load', { programRef: this.programRef, analysisId: this.id, type: this.type } );
    },
    watch: {         
      group: {
        deep: true,
        handler: function(val, oldVal) {
            this.selectedGroup = this.group
        }
      }
    }
  }
</script>
