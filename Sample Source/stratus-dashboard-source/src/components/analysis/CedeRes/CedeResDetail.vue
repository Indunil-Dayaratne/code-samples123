<template>
    <div>
        <b-row class="col-8 mb-2">
            <div v-show="allowFileSelection" class="col-6">
                <multiselect v-model="selectedFileName"
                    :options="availableFileRuns"
                    :preselect-first="true"
                    placeholder="Select file"
                    @select="fileSelectionChanged">
                </multiselect>
            </div>
            <div class="col-6">
                <multiselect v-model="selectedRun"
                    track-by="value"
                    label="text"
                    :options="runOptions"
                    :disabled="selectedFileName === null"
                    placeholder="Select run"
                    :preselect-first="true">
                </multiselect>
            </div>
        </b-row>
        <b-table ref="cedeResultsTable"
            :items="filteredSummaries"
            :fields="fields"
            striped hover small responsive show-empty>
            <template v-slot:cell(AnalysisName)="data">
                <b-link @click="showModal(data.item)">{{ data.value }}</b-link>
            </template>
            <template v-slot:cell(GrossLoss)="data">
                {{getAalSummary(data.item.AALs, 'GrossLoss') | toDecimal}}
            </template>
            <template v-slot:cell(NetOfPreCATLoss)="data">
                {{getAalSummary(data.item.AALs, 'NetOfPreCATLoss') | toDecimal}}
            </template>
            <template v-slot:cell(PostCATNetLoss)="data">
                {{getAalSummary(data.item.AALs, 'PostCATNetLoss') | toDecimal}}
            </template>
            <template v-slot:head(PerspectiveCode)="data">
                <div class="text-center">
                    {{data.label}}
                    <b-select v-model="selectedPerspective" :options="perspectives" 
                        @change="setAllPerspectives" size="sm" v-show="canUpload"/>
                </div>
            </template>
            <template v-slot:cell(PerspectiveCode)="data">
                <b-select v-model="data.item.PerspectiveCode" :options="perspectives" size="sm" :disabled="!canUpload" />
            </template>
            <template v-slot:cell(UserField1)="data">
                <b-input v-model="data.item.UserField1" size="sm" :maxlength="maxfieldLength" :disabled="!canUpload" />
            </template>
            <template v-slot:cell(UserField2)="data">
                <b-input v-model="data.item.UserField2" size="sm" :maxlength="maxfieldLength" :disabled="!canUpload" />
            </template>
        </b-table>
        <b-btn @click="exportToCsv" class="sm" v-show="filteredSummaries.length > 0">
            <fa-icon icon="file-excel" class="mr-2" />
            <span>Csv</span>
            <b-spinner small v-if="exportingToCsv"></b-spinner>
        </b-btn>
        <b-btn variant="info" @click="$bvModal.show('cede-event-catalog-selector')">
            <fa-icon icon="upload" class="mr-2" />
            <span>Upload to Prime</span>
        </b-btn>
        <div id="btn-cede-upload-to-graphene" class="d-inline">
            <b-btn  variant="info" @click="importCedeCheck('Graphene')" :disabled="!groupId">  
                <fa-icon icon="upload" class="mr-2" />
                <span>Upload to Graphene</span>
            </b-btn>
        </div>        
        <b-popover v-if="!groupId" target="btn-cede-upload-to-graphene" triggers="hover" placement="left">Please select an <b>Analysis Group</b></b-popover>
        <b-spinner small v-if="uploading"></b-spinner>
        <b-modal id="cede_res_upload_check"
            title="Upload confirmation check" header-bg-variant="info"
            ref="modal" ok-title="Yes" cancel-title="No"
            ok-variant="success" cancel-variant="danger"
            @ok="importCedes"
            centered>
            <div class="ml-2 mr-2">
                <b-row>
                    Groupings for this CEDE file and run catalog will be locked after upload.
                </b-row>
                <b-row class="mt-3">
                    <ul>
                        <li>File name:     <b>{{selectedFileName}}</b></li>
                        <li>Run catalog:   <b>{{selectedRun ? selectedRun.text : ''}}</b></li>
                    </ul>
                </b-row>
                <b-row class="">
                    <b>Are you sure you want to continue?</b>
                </b-row>
            </div>
        </b-modal>
        <CedeRunModal />
        <EventCatalogSelector modal-id="cede-event-catalog-selector" @ok="importCedeCheck('prime', $event)"/>
    </div>
</template>

<script>
    import azure from 'azure-storage';
    import axios from 'axios';
    import Multiselect from 'vue-multiselect';
    import CedeRunModal from './CedeRunModal';
    import { mapState, mapGetters } from 'vuex';
    import EventCatalogSelector from '../../utils/EventCatalogSelectionModal';

    export default {
        name: "CedeResDetail",
        components: {
            Multiselect,
            CedeRunModal,
            EventCatalogSelector
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
                selectedFileName: null,
                selectedRun: null,
                //runOptions: [],
                maxfieldLength: 15,
                perspectives: [
                    { value: '', text: 'Please select' },
                    { value: 'GrossLoss', text: 'Gross' },
                    { value: 'NetOfPreCATLoss', text: 'Net pre-CAT' },
                    { value: 'PostCATNetLoss', text: 'Net post-CAT' }
                ],
                fields: [
                    { key: "ResultSID", label: "#" },
                    { key: "AnalysisName", label: "Name" },
                    { key: "LineOfBusiness", label: "LoB" },
                    { key: "CurrencyCode", label: "Currency"},
                    { key: "ExposureSetName", label: "Exposure Set"},
                    { key: "GrossLoss", label: "Gross loss" },
                    { key: "NetOfPreCATLoss", label: "Net pre-CAT loss" },
                    { key: "PostCATNetLoss", label: "Net post-CAT loss"},
                    { key: 'PerspectiveCode', label: "Perspective" },
                    { key: 'UserField1', label: "Field 1" },
                    { key: 'UserField2', label: "Field 2" }
                ],
                //cedeSubmission: {},
                uploading: false,
                selectedPerspective: '',
                exportingToCsv: false,
                uploadSystem: null,
                eventCatalogIds: []
            }
        },
        watch: {
            availableFileRuns: function(val) {
                if(!this.selectedFileName && val.length) this.selectedFileName = val[0];
                if(this.selectedFileName && !val.length) this.selectedFileName = null; 
            }
        },
        computed: {
            ...mapState({
                availableFileRuns: (state, get) => get['account/get']('files/cedeRes/item')('fileRunCombinations').files,
                getRunTypes: (state, get) => get['account/get']('files/cedeRes/getRunTypes'),
                summaries: (state, get) => get['account/get']('files/cedeRes/filteredSummaries'),
                runCatalogTypes: (s, get) => get['account/get']('files/cedeExp/dataItem')('runCatalogTypes'),
                user: s => s.auth.user,
                groupId: (s, get) => get['account/get']('groupId'),
                cedeSubmissionsFn: (state, get) => get['account/get']('files/cedeExpSubmissions'),
                yoa: (s, get) => get['account/get']('files/yoa')
            }),
            cedeSubmissions(){
                return this.cedeSubmissionsFn(this.programRef, this.analysisId)
            },
            filteredSummaries(){
                if (!this.selectedRun) return [];
                return this.summaries(this.selectedFileName, String(this.selectedRun.value));
            },
            canUpload(){
                return true;
                //if (!this.selectedRun) return false;
                //return !this.cedeSubmission.LossUploaded || 
                //    (this.cedeSubmission.LossUploaded && !this.cedeSubmission.LossUploaded.includes(this.selectedRun.code));
            },
            runOptions() {
                return this.runCatalogTypes.filter(x=>{
                    return this.getRunTypes(this.selectedFileName).includes(String(x.value));
                });
            },
            cedeSubmission() {
                const subs = this.cedeSubmissions.filter(x=>x.FileName===this.selectedFileName); 
                return subs.length ? subs[0] : {};
            }
        },
        methods: {
            fileSelectionChanged(selectedOption) {
                // this.runOptions = this.runCatalogTypes.filter(x=>{
                //     return this.getRunTypes(selectedOption).includes(String(x.value));
                // });
                // this.cedeSubmission = this.cedeSubmissions.filter(x=>x.FileName===selectedOption)[0];
            },
            setAllPerspectives(code){
                this.filteredSummaries.forEach(x => {
                    x.PerspectiveCode = code;
                });
            },
            async showModal(item){
                await this.$store.dispatch('account/mutate', { mutation: 'files/cedeRes/setModalRun', data: item }); 
                this.$root.$emit('bv::show::modal', 'CedeRunModal')
            },
            importCedeCheck(uploadSystem, eventCatalogIds) {
                this.uploadSystem = uploadSystem;
                this.eventCatalogIds = eventCatalogIds;
                this.$root.$emit('bv::show::modal', 'cede_res_upload_check');
            },
            importCedes() {
                var selectedAnalyses = this.filteredSummaries.filter(x => x.PerspectiveCode);

                if(!selectedAnalyses.length) {
                    this.showError("Please select a perspective for at least one CEDE Analysis"); 
                    return;
                }
                
                if (!this.cedeSubmission.LossUploaded.includes(this.selectedRun.code)) {
                    this.cedeSubmission.LossUploaded.push(this.selectedRun.code)
                }
                let modelAnalysisIds = this.cedeSubmission.ModelAnalysisIds.filter(x => x.RunCatalogType === this.selectedRun.code);
                var request = {
                    programRef: this.programRef,
                    analysisId: this.analysisId,
                    user: this.user.userName,
                    uploadSystem: this.uploadSystem,
                    groupId: this.groupId,
                    yoa: Number(this.yoa),
                    runCatalogType: this.selectedRun.code,
                    eventCatalogIds: this.eventCatalogIds,
                    cedeFile: {
                        PartitionKey: this.cedeSubmission.PartitionKey,
                        RowKey: this.cedeSubmission.RowKey,
                        FileName: this.cedeSubmission.FileName,
                        DatabaseName: this.cedeSubmission.DatabaseName,
                        LossUploaded: this.cedeSubmission.LossUploaded,
                        ModelAnalysisIds: modelAnalysisIds.length ? modelAnalysisIds[0].ModelAnalysisIds : []   
                    },
                    cedeRunSummaries: selectedAnalyses.map(x => {
                        return {
                            PartitionKey: x.PartitionKey,
                            RowKey: x.RowKey,
                            ActivitySID: x.ActivitySID,
                            Currency: x.CurrencyCode,
                            ExposureSetName: x.ExposureSetName,
                            PerspectiveCode: x.PerspectiveCode,
                            UserField1: x.UserField1,
                            UserField2: x.UserField2,
                            LineOfBusiness: x.LineOfBusiness
                        }
                    })
                };
                
                var self = this;
                this.uploading = true;
                
                setTimeout(function(){         
                    axios.post(config.uploadCedeYeltLogicAppEndpoint, request);
                    self.uploading = false;
                }, 1000);                 
            },
            exportToCsv() {
                this.exportingToCsv = true;
                var self = this;
                
                setTimeout(function(){          
                    let data = self.summaries().map(({AALs, RunCatalogType,...item}) => {
                            return {
                                ...item,
                                RunCatalogType: self.runCatalogTypes.filter(x=>String(x.value) === RunCatalogType)[0].text,
                                GrossLoss: self.getAalSummary(AALs, 'GrossLoss'),
                                NetOfPreCATLoss: self.getAalSummary(AALs, 'NetOfPreCATLoss'),
                                PostCATNetLoss: self.getAalSummary(AALs, 'PostCATNetLoss')
                            }
                        }
                    );
                    
                    var csv = self.$papa.unparse(data);
                    self.$papa.download(csv, self.programRef + "_CedeRunDetails");

                    self.exportingToCsv = false;
                }, 500); 
            },
            showError(error) {
                this.$bvToast.toast(error, {
                    title: 'ERROR: Cannot Upload CEDE YELTs',
                    toaster: 'b-toaster-top-center',
                    autoHideDelay: 3000,
                    variant: "danger"
                });
            },
            sum(total, curr){
                return total + curr;
            },
            getAalSummary(aals, perspective) {
                return aals.map(x => x[perspective] || 0).reduce(this.sum, 0);
            }
        }
    }
</script>

<style lang="scss" scoped>
</style>