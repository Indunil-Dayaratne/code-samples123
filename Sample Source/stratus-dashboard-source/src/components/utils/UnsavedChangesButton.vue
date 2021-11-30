<template>
    <b-button variant="outline-warning"
    @click="saveNetwork"
    :disabled="!unsavedChanges || inProgress"
    :show="unsavedChanges || inProgress"
    class="m-2 unsavedChangesButton">
        Save Changes
        <b-spinner small variant="warning" v-if="inProgress"></b-spinner>
    </b-button>
</template>

<script>
import {mapState, mapGetters} from 'vuex';
    export default {
        data: function() {
            return {
                inProgress: false
            }
        },
        computed: {
            ...mapGetters('pricing', {
                unsavedChanges: 'unsavedChanges'
            })
        },
        methods: {
            async saveNetwork() {
                try {
                    this.inProgress = true;
                    await this.$store.dispatch('pricing/saveNetwork');
                    this.inProgress = false;
                } catch (err) {
                    this.inProgress = false;
                    console.error(err);
                }
                
            }
        }
    }
</script>

<style lang="scss" scoped>
.unsavedChangesButton {
    transition: inherit;
    transition: all 0.2s;
    opacity: 0;
    cursor: default;

    &[show] {
        opacity: 1;
        cursor: pointer;
    }
}
</style>