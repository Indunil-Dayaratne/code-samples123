<template>
    <b-card>
        <b-table :items="adjustedFiles"
        :fields="fields"
        striped bordered show-empty>
            <template v-slot:row-details="row">
                <b-card>
                    <b-row>
                        <b-col>
                            <h5>File info</h5>
                        </b-col>
                    </b-row>
                    <b-row class="mb-3">
                        <b-col>
                            <b-input-group prepend="Location">
                                <b-input :value="row.item.Directory" disabled></b-input>
                            </b-input-group>
                        </b-col>
                        <b-col v-if="row.item.Type === 'EXP'" md="auto">
                            <b-button @click="$bvModal.show(modalId(row.item))">
                                New analysis
                            </b-button>
                        </b-col>
                    </b-row>
                    <b-row>
                        <b-col>
                            <b-table :items="row.item.analyses"
                                :fields="analysisTableFields"
                                small>
                                <template v-slot:cell(DatabaseName)="analysis">
                                    {{ getDatabaseName(analysis.item, row.item.submissions) }}
                                </template>
                                <template v-slot:cell(AnalysisId)="analysis">
                                    {{analysis.value}}
                                    <b-button v-if="showReloadButton(analysis.item)" variant="danger" size="sm" style="float: right;"
                                        @click="reloadFile(row.item, analysis.item)">
                                        Reload
                                    </b-button>
                                </template>
                            </b-table>
                        </b-col>
                    </b-row>
                    <b-row v-if="showRelatedFilesTable(row.item)">
                        <b-col>
                            <b-table :items="row.item.related"
                                :fields="relatedFilesFields"
                                small>
                                <template v-slot:cell(Size)="size">
                                    {{formatSize(size.value)}}
                                </template>
                            </b-table>
                        </b-col>
                    </b-row>
                </b-card>
                <new-file-analysis-modal v-if="row.item.Type === 'EXP'" :modalId="modalId(row.item)" :file="row.item" :existingAnalysis="row.item.analyses[0]" />
            </template>
        </b-table>
    </b-card>
</template>

<script>
    import { mapState, mapGetters } from 'vuex';
    import api from '../../../shared/api';
    import NewFileAnalysisModal from './NewFileAnalysisModal';
    import numeral from 'numeral';
    export default {
        name: 'FileTable',
        components: {
            NewFileAnalysisModal
        },
        data() {
            return {
                fields: [
                    { key: 'Name' },
                    { key: 'Type' },
                    { key: 'ImportedAt', label: 'Import Time'}
                ],
                analysisTableFields: [
                    { key: 'Summary' },
                    { key: 'DatabaseName', label: 'Database' },
                    { key: 'AnalysisId', label: 'ID' }
                ],
                relatedFilesFields: [
                    { key: 'Name' },
                    { key: 'Description' },
                    { key: 'Size' }
                ]
            }
        },
        computed: {
            ...mapState({
                files: (state, get) => get['account/get']('files/files'),
                isFailedAnalysis: (state, get) => get['tasks/analysisHasFailedTasks'],
                tasksInProgress: (state, get) => get['tasks/analysisHasTasksInProgress'],
                user: state => state.auth.user.userName
            }),
            adjustedFiles() {
                return this.files 
                    ? this.files.map(x => {
                        return {
                            ...x,
                            _showDetails: true
                        }
                    })
                    : [];
            }
        },
        methods: {
            showReloadButton(analysis) {
                return this.isFailedAnalysis(analysis.ProgramRef, analysis.AnalysisId)
            },
            reloadFile(file, analysis) {
                api.reloadFile(file, file.YOA, analysis.ProgramRef, analysis.AccountName, analysis.DefaultCurrency, analysis.Summary, true, this.user, analysis.AnalysisId);
                this.$router.push(`/program/${analysis.ProgramRef}/tasks`);
            },
            modalId(file) {
                return `${file.Name}_${file.Type}`;
            },
            formatSize(size) {
                return numeral(size).format('0.0 b');
            },
            showRelatedFilesTable(file) {
                return file.related && file.related.length > 0;
            },
            getDatabaseName(analysis, submissions) {
                const relevantSubmissions = submissions.filter(x => x.PartitionKey._ === analysis.ProgramRef + "-" + analysis.AnalysisId);
                if(relevantSubmissions.length !== 1) return "";
                return relevantSubmissions[0].DatabaseName ? relevantSubmissions[0].DatabaseName._ : "";
            }
        }
    }
</script>

<style lang="scss" scoped>

</style>