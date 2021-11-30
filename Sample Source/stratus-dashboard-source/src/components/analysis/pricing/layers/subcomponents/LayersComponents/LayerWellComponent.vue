<template>
    <b-container fluid>
        <b-row>
            <b-col>
                <b-card class="card-well">
                    <b-row>
                        <LayerCard v-for="(item, index) in layers" :key="item.id" :id="item.id" :index="index"
                            @mouseenter="setPopoverTarget(item.id)"
                            @mouseleave="removePopoverTarget()"/>
                    </b-row>
                </b-card>
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
import { mapState, mapGetters } from 'vuex';
import LayerCard from './LayerCard';

    export default {
        props: {
            programRef: String,
            analysisId: [String, Number]
        },
        components: {
            LayerCard
        },
        data() {
            return {
                popoverTarget: ''
            }
        },
        computed: {
            ...mapGetters({
                layers: 'pricing/structure/getVisibleLayers'
            })
        },
        methods: {
            setPopoverTarget(id){
                this.popoverTarget = id;
            },
            removePopoverTarget() {
                this.popoverTarget = '';
            }
        }
    }
</script>

<style lang="scss">
    .card-well {
        min-height: 185px;
    }
</style>