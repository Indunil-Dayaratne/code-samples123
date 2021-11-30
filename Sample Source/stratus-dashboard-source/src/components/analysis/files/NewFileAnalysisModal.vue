<template>
    <b-modal :id="modalId"
        title="Run new file analysis"
        @ok="runNewFileAnalysis"
        :ok-disabled="!allowSubmission"
        ok-title="Run">
        <b-input v-model="summary" placeholder="Input new analysis summary"></b-input>
    </b-modal>
</template>

<script>
import api from '../../../shared/api';
import { mapState } from 'vuex';
    export default {
        props: {
            modalId: {
                type: String,
                required: true
            },
            file: {
                type: Object,
                required: true
            },
            existingAnalysis: {
                type: Object,
                required: true
            }
        },
        data() {
            return {
                summary: ''
            }
        },
        computed: {
            ...mapState({
                user: state => state.auth.user.userName
            }),
            allowSubmission() {
                return this.summary !== '' && this.summary !== null && this.summary !== undefined;
            }
        },
        methods: {
            runNewFileAnalysis() {
                api.reloadFile(this.file, this.file.YOA, this.existingAnalysis.ProgramRef, this.existingAnalysis.AccountName, this.existingAnalysis.DefaultCurrency, this.summary, true, this.user);
                this.summary = '';
            }
        }
    }
</script>

<style lang="scss" scoped>

</style>