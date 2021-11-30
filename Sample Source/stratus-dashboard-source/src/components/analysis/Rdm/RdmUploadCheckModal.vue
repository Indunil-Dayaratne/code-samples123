<template>
    <b-modal :id="modalId"
          title="Upload confirmation check" header-bg-variant="info"
          ref="modal" ok-title="Yes" cancel-title="No"
          ok-variant="success" cancel-variant="danger"
          @ok="$emit('ok')" @cancel="$emit('cancel')" @close="$emit('cancel')"
          centered>
        <div class="ml-2 mr-2">
            <b-row>
              Groupings within the selected RDM be locked after upload. If you need to upload again, you will need to restart the analysis.
            </b-row>
            <b-row class="mt-2">
              <b>Are you sure you want to continue?</b>
            </b-row>
        </div>
    </b-modal>
</template>

<script>
    export default {
        name: "RdmUploadCheckModal",
        props: {
            modalId: {
                type: String,
                default: "rdm_upload_check",
                required: false
            }
        }
    }
</script>

<style lang="scss" scoped>

</style>