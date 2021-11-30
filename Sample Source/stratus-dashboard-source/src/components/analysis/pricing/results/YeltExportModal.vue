<template>
    <b-modal :id="modalId"
        modal-class="yelt-export-modal"
        header-bg-variant="secondary"
        header-text-variant="dark"
        size="lg"
        ok-variant="success"
        cancel-variant="danger"
        :ok-disabled="!selectedExport"
        scrollable
        @ok="download">
        <template v-slot:modal-title>
            Select YELT to download
        </template>
        <template v-slot:default>
            <div style="height: 98%">
                <export-selection-table v-model="selectedExport" single/>
            </div>
            <div class="ml-3">
                Check tasks after submission. Download link will be available in task message once Graphene analysis is complete.
            </div>
        </template>
    </b-modal>
</template>

<script>
    import ExportSelectionTable from './ExportSelectionTable';
    import api from '../../../../shared/api';
    import { mapState } from 'vuex';

    export default {
        name: 'YeltExportModal',
        components: {
            ExportSelectionTable
        },
        props: {
            modalId: {
                type: String,
                required: true
            }
        },
        data() {
            return {
                selectedExport: null
            }
        },
        computed: {
            ...mapState({
                group: (s, g) => g['account/get']('group'),
                user: state => state.auth.user,
                programRef: (s, g) => g['account/get']('programRef')
            })
        },
        methods: {
            download() {
                //let fileName = `${this.group ? this.group.groupName : '[Invalid Group]'}_${this.selectedExport.name}_${this.selectedExport.perspective}_${this.selectedExport.lossViewName}_${this.selectedExport.currency}_YELT.csv`;
                api.graphene.downloadYelt(this.programRef, null, this.selectedExport, this.user.userName);

            }
        }
    }
</script>

<style lang="scss">
.yelt-export-modal {
    .modal-body {
        overflow: hidden;
    }
}
</style>