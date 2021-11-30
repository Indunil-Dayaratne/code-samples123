<template>
    <multi-column-filter-table
        :value="selected"
        :single="single"
        :options="options"
        :fields="fields" 
        @input="$emit('input', $event)">
        <template v-slot:cell(perspective)="data">
            {{ capitalize(data.value) }}
        </template>
    </multi-column-filter-table>
</template>

<script>
    import { mapState, mapGetters } from 'vuex';
    import { capitalize } from 'lodash';
    //import multiColumnTableFilterMixin from '../../../../shared/mixins/multi-column-table-filter-mixin';
    import MultiColumnFilterTable from '../../../utils/MultiColumnFilterTable'

    const stringSorter = function(a, b) {
        if(a < b) return -1;
        if(a > b) return 1;
        return 0;
    };

    const perspectiveSorter = function(a, b) {
        const order = ['gross', 'ceded', 'net'];
        const aIndex = order.indexOf(a);
        const bIndex = order.indexOf(b);
        if(aIndex < 0 || bIndex < 0) throw `Invalid values provided for perspectives: a = ${a}, b = ${b}`;
        return aIndex - bIndex;
    };

    export default {
        name: 'ExportSelectionTable',
        props: {
            single: {
                type: Boolean,
                default: false
            }
        },
        components: {
            MultiColumnFilterTable
        },
        created() {
            this.options = this.allResults.reduce((acc, x) => {
                    if(!acc.length) acc.push(...x.getAllNetworkExportOptions());
                    return acc;
                }, [])
                    .sort((a, b) => {
                        return stringSorter(a.name, b.name) ||
                            perspectiveSorter(a.perspective, b.perspective) ||
                            -stringSorter(a.lossViewType, b.lossViewType) ||
                            stringSorter(a.lossViewName, b.lossViewName) ||
                            stringSorter(a.currency, b.currency);
                    });
        },
        data() {
            return {
                fields: [
                    { key: 'selected', label: '' },
                    { key: 'name', label: 'Name' },
                    { key: 'perspective', label: 'Perspective' },
                    { key: 'lossViewName', label: 'Loss view' },
                    { key: 'lossViewType', label: 'Type' },
                    { key: 'currency', label: 'Currency' }
                ],
                selected: null
            }
        },
        computed: {
            tableId() {
                return `export-selection-table-${this.createdTime}`;
            },
            ...mapGetters({
                allResults: 'pricing/results/getAllNodeResults'
            })
        },
        methods: {
            capitalize(val) {
                return capitalize(val);
            }
        },
    }
</script>

<style lang="scss">

.exportSelectionTable {
    tr {
        cursor: pointer;
        user-select: none;
    }

    .export-row-selected {
        & > td {
           border-color: #8bd2eb;
           background-color: #c1e7f4; 
        }
    }
}
    
</style>