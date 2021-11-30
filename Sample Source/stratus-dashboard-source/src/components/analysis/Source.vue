<template>
    <b-card no-body>
        <b-card-body>
            <b-container fluid>
                <b-row>
                    <b-col md="auto" class="d-flex justify-content-center">
                        <nav-menu :links="links" />
                    </b-col>
                    <b-col>
                        <router-view></router-view>
                    </b-col>
                </b-row>
            </b-container>
        </b-card-body>
    </b-card>
</template>

<script>
import NavMenu from '../utils/NavMenu'
import { mapState, mapGetters } from 'vuex';

export default {
    components: {
        NavMenu
    },
    data() {
        return {
        }
    },
    computed: {
        ...mapState({
            filesAvailable: (state, get) => get['account/getValue']('files/areAvailable')
        }),
        links() {
            return [
                { name: 'program_source_rdm', title: 'RDM', disabled: !this.filesAvailable('RDM') },
                { name: 'program_source_clf', title: 'CLF', disabled: !this.filesAvailable('CLF') },
                { name: 'program_source_cedeexp', title: 'CEDE Exposure', disabled: !this.filesAvailable('EXP') },
                { name: 'program_source_cederes', title: 'CEDE Results', disabled: !this.filesAvailable('EXP') }
            ]
        }
    }
}
</script>

<style lang="scss" scoped>

</style>