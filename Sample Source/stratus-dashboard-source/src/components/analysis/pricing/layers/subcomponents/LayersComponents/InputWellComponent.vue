<template>
    <b-container fluid>
        <b-row>
            <b-col>
                <b-card class="card-well">
                    <b-row>
                        <InputCard v-for="(item, index) in inputs" :key="item.id" :id="item.id" :index="index"
                            @mouseenter="setPopoverTarget(item.id)"
                            @mouseleave="removePopoverTarget()"/>
                    </b-row>
                </b-card>
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
import { mapState } from 'vuex';
import InputCard from './InputCard';

    export default {
        props: {
            programRef: String,
            analysisId: [String, Number]
        },
        components: {
            InputCard
        },
        data() {
            return {
                popoverTarget: ''
            }
        },
        computed: {
            ...mapState({
                inputs: state => state.pricing.structure.inputs
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

<style lang="scss" scoped>
    .card-well {
        min-height: 185px;
    }
</style>