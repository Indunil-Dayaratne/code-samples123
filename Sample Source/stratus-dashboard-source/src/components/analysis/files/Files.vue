<template>
    <b-card>
        <b-container fluid>
            <b-row>
                <b-col>
                    <div class="file-section-header">
                        Files
                        <b-button style="float: right;" @click="$bvModal.show(fileModalId)">
                            Load
                        </b-button>
                    </div>
                </b-col>
            </b-row>
            <b-row>
                <b-col>
                    <file-table />
                </b-col>
            </b-row>
            <b-row>
                <b-col>
                    <div class="file-section-header">
                        Existing analyses
                    </div>
                </b-col>
            </b-row>
            <b-row>
                <b-col>
                    <index :type="indexType" :programFilter="programRef"/>
                </b-col>
            </b-row>
        </b-container>
        <file-load-modal :id="fileModalId"></file-load-modal>
    </b-card>
</template>

<script>
import { mapState, mapGetters } from 'vuex';    
import Index from '../../../views/analysis/Index';
import { ACCOUNT_TYPES } from '../../../shared/types';
import FileLoadModal from './FileLoadModal.vue';
import FileTable from './FilesTable.vue';
export default {
    props: {
        programRef: {
            type: String,
            required: true
        },
    },
    components: {
        Index,
        FileLoadModal,
        FileTable
    },
    data() {
        return {
            fileModalId: 'load-files'
        }
    },
    computed: {
        indexType() {
            return ACCOUNT_TYPES.analysis;
        }
    }
}
</script>

<style lang="scss" scoped>
.file-section-header {
    padding-bottom: 0.5rem;
    border-bottom: 2px lightblue solid;
    margin-bottom: 01rem;
    font-size: 1.5rem;
}
</style>