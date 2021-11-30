<template>
    <b-modal :id="modalId"
        modal-class="prime-export-modal"
        content-class="visible-overflow"
        header-bg-variant="secondary"
        header-text-variant="dark"
        size="xl"
        ok-variant="success"
        cancel-variant="danger"
        :ok-disabled="!selectedExports || !mappedLossViews.data"
        scrollable
        @ok="exportToPrime">
        <template v-slot:modal-title>
            Select YELT to download
        </template>
        <template v-slot:default>
            <b-container fluid>
                <b-row>
                    <b-col>
                        <div style="">
                            <h5 class="mb-3">Select exports:</h5>
                            <export-selection-table v-model="selectedExports"/>
                        </div>
                    </b-col>
                    <b-col>
                        <h5 class="mb-3">Map loss views to Prime event catalogs:</h5>
                        <div class="catalog-selector-container">
                            <template v-if="lossViewsToMap.length > 0">
                                <div style="width: 100%;">
                                    <prime-event-catalog-selector :id="modalId" :by-splits="lossViewsToMap" v-model="mappedLossViews" single/>
                                </div>
                            </template>
                            <template v-else>
                                <div class="catalog-selector-placeholder-text">
                                    Select exports
                                </div>
                            </template>
                        </div>
                    </b-col>
                </b-row>
            </b-container>
        </template>
    </b-modal>
</template>

<script>
    import ExportSelectionTable from './ExportSelectionTable';
    import PrimeEventCatalogSelector from '../../../utils/PrimeEventCatalogSelector';
    import api from '../../../../shared/api';
    import { mapState } from 'vuex';

    export default {
        name: 'PrimeExportModal',
        components: {
            ExportSelectionTable,
            PrimeEventCatalogSelector
        },
        props: {
            modalId: {
                type: String,
                required: true
            }
        },
        data() {
            return {
                selectedExports: null,
                mappedLossViews: {
                    isLoading: false,
                    data: null
                }
            }
        },
        computed: {
            ...mapState({
                group: (s, g) => g['account/get']('group'),
                programRef: (s, g) => g['account/get']('programRef'),
                analysisId: (s, g) => g['account/get']('analysisId'),
                user: s => s.auth.user.userName,
                networkId: s => s.pricing.selectedNetworkId
            }),
            lossViewsToMap() {
                return this.selectedExports ? [...new Set(this.selectedExports.map(x => x.lossViewName))] : [];
            }
        },
        methods: {
            async exportToPrime() {
                try {
                    let response = await api.graphene.getNetwork({networkId: this.networkId});
                    if(response.status !== 200) { console.error(`Unknown network - ID: ${this.networkId}`); return; }
                    let structure = response.data;

                    this.selectedExports.forEach(op => {
                        api.graphene.exportToPrime({
                            programRef: this.programRef,
                            analysisId: this.analysisId,
                            networkId: structure.networkId,
                            revision: structure.revision,
                            nodeId: op.nodeId,
                            user: this.user,
                            eventCatalogIds: [this.mappedLossViews.data[op.lossViewName]],
                            currency: op.currency,
                            lossViewIdentifier: op.lossViewIdentifier,
                            metadataNodeId: op.baseNodeId
                        });
                    });
                    
                } catch (err) {
                    console.error(err);
                }
            }
        }
    }
</script>

<style lang="scss">
.prime-export-modal {
    .modal-body {
        overflow: visible;
    }
}

.visible-overflow {
    overflow: visible !important;
}

.catalog-selector-container {
    height: 95%;
    display: flex;
    align-items: center;
    justify-content: center;
}

.catalog-selector-placeholder-text {
    font-size: 23px;
    color: grey;
    user-select: none;
}
</style>