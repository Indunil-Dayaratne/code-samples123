<template>
    <div>
        <template v-for="(input) in Object.keys(indexMappings).sort()">
            <div :key="input" class="mb-3">
                <div v-if="descriptionsProvided" class="mb-2">
                    {{input}}:
                </div>
                <multiselect :id="`${id}_${input}_multi`"
                    v-model="selectedEventCatalogs[indexMappings[input]]"
                    label="description"
                    track-by="id"
                    :showLabels="false"
                    :options="preparedOptions" 
                    :multiple="!single"
                    :closeOnSelect="single"
                    @input="$emit('input', output)">
                    <template v-slot:singleLabel="props">
                        <span>{{props.option.description}}</span>
                    </template>
                    <template v-slot:option="props">
                        <div style="font-size: 1.1rem" class="mb-2">{{props.option.description}}</div>
                        <div style="font-size: 0.8rem; font-style: italic;">{{props.option.id}}</div>
                    </template>
                </multiselect>
            </div>
        </template>
    </div>
</template>

<script>
    import Multiselect from 'vue-multiselect';
    import axios from 'axios'
    export default {
        name: 'PrimeEventCatalogSelector',
        components: {
            Multiselect
        },
        props: {
            id: {
                type: String,
                required: true
            },
            bySplits: {
                type: Array,
                default: function() {
                    return [];
                },
                validator: function(arr) {
                    return arr.map(val => typeof val === 'string').every(x => x);
                }
            },
            value: Object,
            single: {
                type: Boolean,
                default: false
            }
        },
        created() {
            this.prepareData();
            this.loadOptions();
        },
        watch: {
            bySplits(newValue, oldValue) {
                this.prepareData();
            },
            isLoading(newV, oldV) {
                this.emit();
            }
        },
        data() {
            return {
                baseKey: 'v1',
                selectedEventCatalogs: [],
                indexMappings: {},
                isLoading: false,
                errorLoadingOptions: false,
                eventCatalogOptions:[],
                validStatusStr: 'processing_succeeded'
            }
        },
        computed: {
            isMultiple() {
                return this.bySplits.length > 1; 
            },
            descriptionsProvided() {
                return this.bySplits.length > 0; 
            },
            output() {
                const output = {
                    isLoading: this.isLoading,
                    data: null
                };

                if(this.selectedEventCatalogs.every(x => x && ((!this.single && x.length > 0) || this.single))) {
                    output.data = this.descriptionsProvided 
                    ? Object.keys(this.indexMappings).reduce((acc, key) => {
                        acc[key] = !this.single ? this.selectedEventCatalogs[this.indexMappings[key]].map(x => x.id) : this.selectedEventCatalogs[this.indexMappings[key]].id;
                        return acc;
                    }, {}) 
                    : this.selectedEventCatalogs[0].map(x => x.id);
                }
                
                return output;
            },
            outputReady() {
                return this.selectedEventCatalogs.every(x => !!x && x.length > 0);
            },
            preparedOptions() {
                return this.eventCatalogOptions.filter(x => x.status === this.validStatusStr && x.description !== null)
                    .sort((a, b) => (a.description > b.description) - (a.description < b.description));
            }
        },
        methods: {
            prepareData(){
                const source = this.bySplits.length > 0 ? this.bySplits : [this.baseKey];
                const newArr = [];
                const newMapping = source.reduce((acc, x, idx) => {
                    acc[x] = idx;
                    newArr.push(null);
                    return acc;
                }, {});
                Object.keys(newMapping).forEach(key => {
                    if(key in this.indexMappings) {
                        newArr[newMapping[key]] = this.selectedEventCatalogs[this.indexMappings[key]]
                    } 
                });
                this.indexMappings = newMapping;
                this.selectedEventCatalogs = newArr;
            },
            async loadOptions(){
                this.isLoading = true;
                this.errorLoadingOptions = false;
                try {
                    const options = {
                        headers: {
                            Authorization: `Basic ${config.primeToken}`
                        }
                    };
                    const response = await axios.get(config.primeCatalogUrl, options);
                    this.eventCatalogOptions = response.data.items;
                } catch (err) {
                    console.error(`Error retrieving event catalogs from Prime:`, err);
                    //console.log(err.response.data);
                    this.errorLoadingOptions = true;
                }
                
                this.isLoading = false;
            },
            emit() {
                this.$emit('input', this.output);
            }
        }
    }
</script>

<style lang="scss" scoped>

</style>