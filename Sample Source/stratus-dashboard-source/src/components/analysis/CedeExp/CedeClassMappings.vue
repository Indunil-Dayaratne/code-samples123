<template>
    <div class="col-md-12">
        <b-container fluid>
            <b-row>
                <b-card header="Manage user line of business mappings" header-bg-variant="info"> 
                    <b-row align-h="center">
                        <b-col md="6" sm="12" v-if="!anyPerilsMapped">
                            <b-form-group label="Set all mappings:">
                                <b-row class="mb-2">
                                    <b-col>
                                        <multiselect v-model="selectedOverrideOption"
                                            :options="britLobOptions"/>
                                    </b-col>
                                </b-row>
                                <b-row>
                                    <b-col class="d-flex justify-content-end">
                                        <b-button variant="primary" @click="mapAll(selectedOverrideOption)">
                                            Map all
                                        </b-button>
                                    </b-col>
                                </b-row>
                            </b-form-group>
                        </b-col>
                    </b-row>   
                    <b-row align-h="center">
                        <b-col md="6" sm="12">
                            <b-table fixed :fields="mainFields"
                                :items="preMappedUserLobsWithVariant"
                                hover>
                                <template v-slot:cell(userLob)="row">
                                    <OpenCloseCaret :isOpen="row.detailsShowing" inline @click.native="row.toggleDetails"/>
                                    {{row.value}}
                                </template>

                                <template v-slot:cell(britLob)="row">
                                    <multiselect :id="`map_ms_${row.item.userLob}`"
                                        :value="row.item.britLob"
                                        :options="britLobOptions"
                                        placeholder="Map line of business"
                                        @input="checkMapping(row.item.userLob, $event)"
                                        :disabled="anyPerilsMapped"/>
                                </template>

                                <template v-slot:row-details="row">
                                    <b-container fluid>
                                        <b-row class="mb-2">
                                            <b-col>
                                                <b>
                                                    User line of business found in:
                                                </b>
                                            </b-col>
                                        </b-row>
                                        <b-row>
                                            <b-col>
                                                <b-table :items="row.item.exposureSets"
                                                    :fields="detailFields"
                                                    outlined>
                                                </b-table>
                                            </b-col>
                                        </b-row>
                                    </b-container>
                                </template>
                            </b-table>
                        </b-col>
                    </b-row>
                    <b-row align-h="end">
                        <b-col class="d-flex justify-content-end">
                            <b-button class="mr-2"
                                @click="undoAllMappings"
                                variant="secondary"
                                :disabled="anyPerilsMapped">
                                Undo changes
                            </b-button>
                            <b-button :disabled="!readyForUpload || anyPerilsMapped"
                                @click="uploadMapping"
                                variant="primary">
                                Upload
                                <b-spinner small v-if="showUploadSpinner"></b-spinner>
                            </b-button>
                        </b-col>
                    </b-row>
                </b-card>
            </b-row>
            <div class="alert-holder">
                <b-alert variant="warning" :show="showAllAlert" 
                    dismissible fade
                    @dismissed="showAllAlert=false">
                    <p>
                        <b>Warning!</b>
                    </p>
                    <p>
                        Cannot mix 'All' with a specific class.
                    </p>
                    <p>
                        {{actionText}}
                    </p>
                </b-alert>
            </div>
        </b-container>
    </div>
</template>

<script>
    import Multiselect from 'vue-multiselect';
    import {mapState, mapGetters} from 'vuex';
    import OpenCloseCaret from '../../utils/OpenCloseCaret';

    export default {
        name: 'CedeClassMappings',
        props: ['programRef', 'analysisId'],
        components: {
            Multiselect,
            OpenCloseCaret
        },
        data() {
            return {
                selectedOverrideOption: '',
                mainFields: [{
                    key: 'userLob',
                    label: 'User LoB'
                }, {
                    key: 'britLob',
                    label: 'Brit LoB'
                }],
                detailFields: [{
                    key: 'ExposureSetName',
                    label: 'Exposure Set Name'
                }, {
                    key: 'FileName',
                    label: 'File Name'
                }],
                showAllAlert: false,
                actionText: '',
                showUploadSpinner: false
            }
        },
        computed: {
            ...mapState({
                britLobOptions: (state, get) => get['account/get']('files/cedeExp/dataItem')('britLobOptions'),
                savedMappings: (state, get) => get['account/get']('files/cedeExp/dataItem')('savedLobMappings'),
                preMappedUserLobs: (state, get) => get['account/get']('files/cedeExp/getMappedLobs'),
                anyPerilsMappedFn: (state, get) => get['account/get']('files/cedePerilsMapped')
            }),
            anyPerilsMapped() {
                return this.anyPerilsMappedFn(this.programRef, this.analysisId);
            },
            preMappedUserLobsWithVariant: {
                get: function() {
                    return this.preMappedUserLobs.map(x => {
                        return {
                            ...x,
                            _rowVariant: !x.savedMapping || (x.savedMapping && x.savedMapping != x.britLob) 
                                ? 'warning' 
                                : null
                        }
                    });
                }
            },
            readyForUpload() {
                return this.preMappedUserLobsWithVariant.every(x => !!x.britLob);
            }
        },
        methods: {
            async undoAllMappings() {
                await this.$store.dispatch('account/mutate', {
                    mutation: 'files/cedeExp/mapLinesOfBusiness', 
                    data: this.preMappedUserLobsWithVariant
                        .map(x => {
                            return {
                                userLob: x.userLob,
                                britLob: x.savedMapping || ''
                            }
                        })
                });
            },
            async mapAll(option) {
                await this.$store.dispatch('account/mutate', {
                    mutation: 'files/cedeExp/mapLinesOfBusiness', 
                    data: this.preMappedUserLobsWithVariant
                        .map(x => {
                            return {
                                userLob: x.userLob,
                                britLob: option
                            }
                        })
                });
            },
            async unmapOption(option) {
                await this.$store.dispatch('account/mutate', {
                    mutation: 'files/cedeExp/mapLinesOfBusiness', 
                    data: this.preMappedUserLobsWithVariant
                        .filter(x => x.britLob === option)
                        .map(x => {
                        return {
                            userLob: x.userLob,
                            britLob: option
                        }
                    })
                });
            },
            async checkMapping(userLob, option, id) {
                await this.$store.dispatch('account/mutate', { mutation: 'files/cedeExp/mapLinesOfBusiness', data: [{userLob: userLob, britLob: option}] });
                if(option === 'All') {
                    if(!this.preMappedUserLobsWithVariant.every(x => x.britLob === 'All')) {
                        this.actionText = 'All classes set to \'All\'';
                        this.showAllAlert = true;
                        this.mapAll(option);
                    }
                } else {
                    if(this.preMappedUserLobsWithVariant.some(x => x.britLob === 'All')) {
                        this.actionText = 'Lines of business previously mapped to \'All\' have been unmapped.';
                        this.showAllAlert = true;
                        this.unmapOption('All');
                    }
                }
            },
            async uploadMapping() {
                this.showUploadSpinner = true;
                await this.$store.dispatch('account/act', { 
                    action: 'files/cedeExp/uploadLobMapping',
                     data: {
                        mappings: this.preMappedUserLobsWithVariant,
                        programRef: this.programRef,
                        analysisId: this.analysisId
                    }
                });
                this.lobs = null;
                this.showUploadSpinner = false;
            }
        },
    }
</script>

<style lang="scss" scoped>
.alert-holder {
    position: fixed;
    bottom: 0;
    left: 50%;
    transform: translate(-50%, 0);
    width: 30vw;
}
</style>