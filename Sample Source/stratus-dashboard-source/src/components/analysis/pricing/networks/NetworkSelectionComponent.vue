<template>
    <b-container fluid>
        <b-row>
            <b-col>
                <h3 class="pt-1">
                    Select structure
                </h3>
            </b-col>
            <b-col class="mb-2" style="display: flex; justify-content: flex-end">
                <b-button variant="success"
                    @click="openCreateNetworkModal"
                    class="m-1">
                    Add
                </b-button>
            </b-col>
        </b-row>
        <b-row>
            <b-col>
                <b-table id="available_networks"
                    ref="availableNetworksTable"
                    :fields="networkTableFields"
                    :items="networks"
                    striped 
                    :busy.sync="tableIsBusy"
                    :tbody-tr-class="isSelectedNetwork">
                    <template v-slot:cell(name)="data">
                        <template v-if="useRoute">
                            <b-link :to="{ query: { networkId: data.item.networkId } }">
                                {{ data.value }}
                            </b-link>
                        </template>
                        <template v-else >
                        <span class="label-link" @click="loadNetwork(data.item.networkId)">
                            {{data.value}}
                        </span>
                    </template>
                        
                    </template>
                    <template v-slot:cell(createdOn)="data">
                        {{data.value | moment(dateFormat)}}
                    </template>
                    <template v-slot:cell(modifiedOn)="data">
                        {{data.value | moment(dateFormat)}}
                    </template>
                    <template v-slot:cell(edit)="data">
                        <div class="d-flex justify-content-end">
                            <b-button variant="info"
                                size="sm" class="edit-network-btn"
                                :disabled="tableBusy"
                                :show="!tableBusy"
                                @click="openEditNetworkModal(data.item)">
                                Edit
                            </b-button>
                        </div>
                    </template>
                </b-table>
            </b-col>
        </b-row>
        <b-modal id="create_network" ref="create_network"
            :title="modelTitle" header-bg-variant="info"
            ok-title="Submit" cancel-title="Cancel"
            ok-variant="success" cancel-variant="danger"
            @ok="handleModalOk"
            @cancel="onCreateNetworkCancel"
            @close="onCreateNetworkCancel"
            @shown="onCreateNetworkShow"
            centered>
            <b-form-group label="Structure name">
                <b-input id="create_network_name"
                    ref="networkName"
                    v-model="modalNetworkName"
                    placeholder="Enter structure name" 
                    :state="$v.modalNetworkName.$dirty ? !$v.modalNetworkName.$error : null" />
                <b-form-invalid-feedback id="create_network_name_feedback">
                    Please enter a name for the structure
                </b-form-invalid-feedback>
            </b-form-group>
            <b-form-group label="Year of account">
                <b-input id="create_network_yoa"
                    ref="networkYOA"
                    v-model="modalNetworkYoa"
                    type="number" >
                </b-input>
            </b-form-group>
            <b-form-group v-if="!editState" label="Create from">
                <multiselect v-model="modalNetworkCopyFrom"
                    track-by="networkId"
                    label="name"
                    :options="modalNetworkCopyFromOptions"
                    :allow-empty="false"/>
            </b-form-group>
            <b-form-group label="Notes">
                <b-textarea id="create_network_notes"
                    v-model="modalNetworkNotes"
                    placeholder="Add notes..."
                    rows="8">
                </b-textarea>
            </b-form-group>
        </b-modal>
    </b-container>
</template>

<script>
import {mapState, mapGetters} from 'vuex';
import { validationMixin } from 'vuelidate';
import { required } from "vuelidate/lib/validators";
import Multiselect from 'vue-multiselect';

let modalNetworkCopyFromDefault = {networkId: 0, name: 'New'};

    export default {
        props: {
            useRoute: {
                type: Boolean,
                default: false
            },
        },
        mixins: [validationMixin],
        validations: {
            modalNetworkName: { required }      
        },
        components: {
            Multiselect
        },
        data() {
            return {
                modalNetworkName: '',
                modalNetworkNotes: '',
                modalNetworkYoa: new Date().getYear() + 1900,
                modalNetworkCopyFrom: modalNetworkCopyFromDefault,
                networkTableFields: [
                    {
                        key: 'name',
                        label: 'Name'
                    },
                    {
                        key: 'yoa',
                        label: 'YOA'
                    },
                    {
                        key: 'createdBy',
                        label: 'Created By'
                    },
                    {
                        key: 'createdOn',
                        label: 'Created On'
                    },
                    {
                        key: 'modifiedBy',
                        label: 'Modified By'
                    },
                    {
                        key: 'modifiedOn',
                        label: 'Modified On'
                    },
                    {
                        key: 'edit',
                        label: ''
                    }
                ],
                tableBusy: false,
                editState: false,
                editNetwork: null
            }
        },
        computed: {
            ...mapState({
                networks: state => state.pricing.networks,
                selectedNetworkId: state => state.pricing.selectedNetworkId,
                networkIsLoading: state => state.pricing.isLoading
            }),
            ...mapGetters('pricing', {
                selectedNetwork: 'getSelectedNetworkProperties',
                getRevision: 'getRevisionForNetwork'
            }),
            dateFormat() {
                return 'DD-MM-YYYY HH:mm';
            },
            modalNetworkCopyFromOptions() {
                return [modalNetworkCopyFromDefault, ...this.networks];
            },
            modelTitle() {
                return this.editState ? 'Edit structure notes' : 'Create structure';
            },
            tableIsBusy() {
                return this.tableBusy || this.networkIsLoading;
            }
        },
        methods: {
            openEditNetworkModal(network) {
                this.editState = true;
                this.editNetwork = network;
                this.modalNetworkName = network.name;
                this.modalNetworkYoa = network.yoa;
                this.modalNetworkNotes = network.notes;
                this.openCreateNetworkModal();
            },
            openCreateNetworkModal() {
                this.$root.$emit('bv::show::modal', 'create_network');
            },
            onCreateNetworkCancel() {
                this.resetModalContent();
            },
            onCreateNetworkShow() {
                this.$v.modalNetworkName.$touch();
                this.$refs.networkName.focus();
            },
            handleModalOk() {
                if(this.editState) {
                    if(this.editNetwork.networkId < 0) {
                        this.$store.commit('pricing/updateNetworkNotes', {
                            networkId: this.editNetwork.networkId,
                            notes: this.modalNetworkNotes
                        });
                    } else {
                        this.$store.dispatch('pricing/saveNetworkHeader', {
                            ...this.editNetwork,
                            name: this.modalNetworkName,
                            yoa: this.modalNetworkYoa,
                            notes: this.modalNetworkNotes
                        });
                    }
                } else {
                    this.$store.dispatch('pricing/createNetwork', {
                        name: this.modalNetworkName,
                        yoa: this.modalNetworkYoa,
                        notes: this.modalNetworkNotes,
                        copyFromNetwork: this.modalNetworkCopyFrom
                    });
                }
                
                this.resetModalContent();
            },
            loadNetwork(id) {
                if(id === this.selectedNetworkId) return;
                this.tableBusy = true;
                this.$store.dispatch('pricing/getNetwork', {
                    networkId: id,
                    revision: this.getRevision(id)
                }).then(() => {
                        this.tableBusy = false;
                    }).catch(error => {
                        console.error(error);
                        this.tableBusy = false;
                    });
            },
            isSelectedNetwork(item, type) {
                if(!item) return;
                if(item.networkId === this.selectedNetworkId) return 'table-primary';
            },
            resetModalContent() {
                this.modalNetworkName = '';
                this.modalNetworkNotes = '';
                this.modalNetworkCopyFrom = modalNetworkCopyFromDefault;
                this.editState = false;
                this.editNetwork = null;
            }
        }
    }
</script>

<style lang="scss" scoped>
    .label-link {
        color: #20a8d8;
        text-decoration: none;
        background-color: transparent;

        &:hover {
            color: #167495;
            text-decoration: underline;
            cursor: pointer;
        }
    }

    .edit-network-btn {
        opacity: 0;
        transform: translateX(8px);
        transition: all 0.2s;
    }

    tr:hover .edit-network-btn {
        opacity: 1;
        transform: translateX(0);
    }
</style>