<template>
    <b-col sm="6" md="4" lg="3" xl="2" class="py-3">
        <b-card :id="id" 
            style="cursor: pointer;"
            :class="{shadow: isHovering}"
            @mouseover="isHovering=true"
            @mouseout="isHovering=false">
            <template v-slot:header>
                <b-container fluid>
                    <b-row>
                        <b-col>
                            {{ layer.data.type }}
                        </b-col>
                        <b-col class="text-right">
                            {{ index + 1 }}
                        </b-col>
                    </b-row>
                </b-container>
            </template>
            <b-card-title>
                {{ layer.data.name }}
            </b-card-title>
            <template v-slot:footer>
                <b-container fluid>
                    <b-row style="height: 1.5em;">
                        <b-col>
                            {{ primaryMetric }}
                        </b-col>
                        <b-col class="text-right">
                            {{ secondaryMetric }}
                        </b-col>
                    </b-row>
                </b-container>
            </template>
        </b-card>
        <LayerPopover :target="id"/>
    </b-col>
</template>

<script>
import { mapState, mapGetters } from 'vuex';
import LayerPopover from './LayerPopover';

    export default {
        name: 'LayerCard',
        props: {
            id: Number,
            index: Number
        },
        components: {
            LayerPopover
        },
        data() {
            return {
                isHovering: false
            }
        },
        computed: {
            ...mapGetters('pricing/structure', [
                'getLayerById',
                'summaryMetrics'
            ]),
            layer() {
                return this.getLayerById(this.id);
            },
            primaryMetric() {
                var type = this.layer.data.type;
                if(!type) return '';
                var metric = this.summaryMetrics.primary[type].metric;
                if(!metric) return '';
                return `${this.summaryMetrics.primary[type].identifierChar}: ${this.summaryMetrics.primary[type].formatter(this.layer.data[metric])}`;
            },
            secondaryMetric() {
                var type = this.layer.data.type;
                if(!type) return '';
                var metric = this.summaryMetrics.secondary[type].metric;
                if(!metric) return '';
                return `${this.summaryMetrics.secondary[type].identifierChar}: ${this.summaryMetrics.secondary[type].formatter(this.layer.data[metric])}`;
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

    .shadow {
        transition: box-shadow 0.2s;
    }
</style>