<template>
    <b-container fluid>
        <b-row>
            <b-col>
                <b-card class="card-well">
                    <b-row>
                        <SubjectLossCard v-for="(item, index) in subjectLossNodes" :key="item.id" :id="item.id" :index="index"
                            @mouseenter="setPopoverTarget(item.id)"
                            @mouseleave="removePopoverTarget()"/>
                    </b-row>
                </b-card>
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
import { mapGetters } from 'vuex';
import SubjectLossCard from './SubjectLossCard';

    export default {
        props: {
            programRef: String,
            analysisId: [String, Number]
        },
        components: {
            SubjectLossCard
        },
        data() {
            return {
                popoverTarget: ''
            }
        },
        computed: {
            ...mapGetters({
                subjectLossNodes: 'pricing/structure/subjectLosses'
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