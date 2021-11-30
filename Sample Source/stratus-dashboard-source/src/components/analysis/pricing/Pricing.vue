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
import NavMenu from '../../utils/NavMenu';
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
        links() {
            return [
                { name: 'program_pricing_networks', title: 'Pricing Analyses', icon: 'list-alt' },
                { name: 'program_pricing_losses', title: 'Loss Sets', icon: 'money-bill-alt' },
                { name: 'program_pricing_layers', title: 'Layers', icon: 'layer-group', disabled: !this.networkLoaded},
                { name: 'program_pricing_views', title: 'Loss Views', icon: 'eye', disabled: !this.networkLoaded },
                { name: 'program_pricing_fx', title: 'Exchange rates', icon: 'exchange-alt'}
            ]
        },
        ...mapState({
            networkLoaded: (state, get) => get['pricing/networkLoaded']
        })
    }
}
</script>

<style lang="scss">

</style>