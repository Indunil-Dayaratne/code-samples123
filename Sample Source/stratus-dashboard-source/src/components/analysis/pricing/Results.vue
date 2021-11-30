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
export default {
    components: {
        NavMenu
    },
    data() {
        return {
            links: [
                { name: 'program_res_stc', title: 'Stochastic', icon: 'chart-bar' },
                { name: 'program_res_det', title: 'Deterministic', icon: 'globe-americas' }
            ]
        }
    },
    beforeRouteLeave (to, from, next) {
        this.$store.commit('pricing/results/updateTabVisible', false);
        next();
    }
}
</script>

<style lang="scss" scoped>

</style>