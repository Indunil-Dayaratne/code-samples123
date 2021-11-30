<template>
    <b-container fluid>
        <b-row>
            <b-col class="mb-2">
                <span class="back-btn" @click="deactivateRelationship">
                    <fa-icon icon="arrow-left" size="lg" />
                </span>
                <span class="filter-header">
                    Filter
                </span>
            </b-col>
        </b-row>
        <b-row>
            <b-col>
                <LossFilterTable />
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
import LossFilterTable from './LossFilterTableComponent';
    export default {
        name: 'LossFilterComponent',
        components: {
            LossFilterTable
        },
        data() {
            return {
                
            }
        },
        computed: {

        },
        methods: {
            deactivateRelationship() {
                this.$store.commit('pricing/structure/deactivateRelationship');
            }
        }
    }
</script>

<style lang="scss" scoped>
    .back-btn {
        cursor: pointer;
        padding: 5px;
        border-radius: 0.25em;

        &:hover {
            background-color: rgba(211,211, 211, 0.4)
        }
    }

    .filter-header {
        font-size: 20px;
        margin-top: -7px;
        padding-left: 10px;
    }
</style>