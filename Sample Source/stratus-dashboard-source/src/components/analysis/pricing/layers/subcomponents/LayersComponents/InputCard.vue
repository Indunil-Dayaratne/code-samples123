<template>
    <b-col sm="4" md="3" lg="2" class="py-3">
        <b-card :id="id" 
            style="cursor: pointer;"
            :class="{shadow: isHovering}"
            @mouseover="isHovering=true"
            @mouseout="isHovering=false">
            <template v-slot:header>
                <b-container fluid>
                    <b-row>
                        <b-col class="text-right">
                            {{ index + 1 }}
                        </b-col>
                    </b-row>
                </b-container>
            </template>
            <b-card-title>
                {{ input.data.name }}
            </b-card-title>
            <template v-slot:footer>
                <b-container fluid>
                    <b-row style="height: 1.5em;"></b-row>
                </b-container>
            </template>
        </b-card>
        <InputPopover :target="id"/>
    </b-col>
</template>

<script>
import { mapState, mapGetters } from 'vuex';
import InputPopover from './InputPopover';

    export default {
        props: {
            id: Number,
            index: Number
        },
        components: {
            InputPopover
        },
        data() {
            return {
                isHovering: false
            }
        },
        computed: {
            ...mapGetters('pricing/structure', [
                'getInputByIndex',
                'getInputById'
            ]),
            input() {
                return this.getInputById(this.id);
            }
        },
        watch:{
        },
        methods: {
        }
    }
</script>

<style lang="scss" scoped>
    .card {
        margin-bottom: 0;
    }

    .card-header, .card-footer {
        padding: 0.5em;
    }
</style>