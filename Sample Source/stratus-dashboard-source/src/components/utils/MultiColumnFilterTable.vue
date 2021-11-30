<template>
    <b-container fluid >
        <b-row>
            <b-col class="">
                <b-form-group description="Search multiple columns at once with spaces in the search text"
                    style="width: 100%;">
                    <b-input-group>
                        <b-input :placeholder="`Filter options`" v-model="filter"/>
                        <b-input-group-append>
                            <b-button @click="clearFilter">Clear</b-button>
                        </b-input-group-append>
                    </b-input-group>
                </b-form-group>
            </b-col>
        </b-row>
        <b-row  v-if="!single">
            <b-col class="mb-2">
                <b-button @click="selectAll">Select visible</b-button>
                <b-button @click="clearSelections">Clear visible</b-button>
            </b-col>
        </b-row>
        <b-row>
            <b-col>
                <b-table :ref="ref"
                    class="exportSelectionTable"
                    :items="localOptions"
                    :fields="innerFields"
                    :filter="filter"
                    :filter-function="multiColumnSpaceFilter"
                    striped hover
                    sticky-header="60vh"
                    @row-clicked="rowClicked"
                    :tbody-tr-class="isRowSelectedClass">
                    <template v-slot:cell(selected)="row">
                        <template v-if="row.item.selected">
                            <fa-icon icon="check-square" solid></fa-icon>
                            <span class="sr-only">Selected</span>
                        </template>
                        <template v-else>
                            <fa-icon style="opacity: 0;" icon="check-square" solid></fa-icon>
                            <span class="sr-only">Not Selected</span>
                        </template>
                    </template>
                    <template v-for="(index, name) in $scopedSlots" v-slot:[name]="data">
                        <slot :name="name" v-bind="data"></slot>
                    </template>
                </b-table>
            </b-col>
        </b-row>
    </b-container>
</template>

<script>
    export default {
        props: {
            value: {
                type: Object | Array,
                required: true
            },
            single: {
                type: Boolean,
                default: false
            },
            options: {
                type: Array
            },
            fields: {
                type: Array
            }
        },
        data() {
            return {
                localOptions: this.getLocalOptions(this.options, this.value),
                filter: null,
                ref: 'multiColumnFilterTable'
            }
        },
        watch: {
        },
        computed: {
            innerFields() {
                return [
                    {
                        key: 'selected',
                        label: ''
                    },
                    ...this.fields
                ]
            },
            selectedCount() {
                return this.localOptions.filter(x => x.selected).length;
            },
            selectMode() {
                return this.single ? 'single' : 'range'
            },
            selected() {
                return this.single ? this.localOptions.find(x => x.selected) : this.localOptions.filter(x => x.selected);
            }
        },
        methods: {
            refCheck(){
                if(!this.ref) throw "To use the multi-column-table-mixin you must set the ref property in data to a value and assign this as a ref to the relevant table.";
            },
            clearFilter() {
                this.filter = null;
            },
            selectAll() {
                this.refCheck();
                const filterKeys = this.filter ? this.$refs[this.ref].filteredItems.map(x => x.key) : [];
                for (let i = 0; i < this.localOptions.length; i++) {
                    const element = this.localOptions[i];
                    if(filterKeys.includes(element.key)) element.selected = true;
                    else if (filterKeys.length === 0) element.selected = true;
                }   
                this.$emit('input', this.selected);   
            },
            clearSelections() {
                this.refCheck();
                const filterKeys = this.filter ? this.$refs[this.ref].filteredItems.map(x => x.key) : [];
                for (let i = 0; i < this.localOptions.length; i++) {
                    const element = this.localOptions[i];
                    if(filterKeys.includes(element.key)) element.selected = false;
                    else if (filterKeys.length === 0) element.selected = false;
                }
                this.$emit('input', this.selected);
            },
            rowClicked(item, index) {
                this.localOptions.forEach(element => { 
                    if(element.key === item.key) element.selected = !element.selected 
                    else if(this.single) element.selected = false;
                });
                this.$emit('input', this.selected);
            },
            isRowSelectedClass(item, type) {
                if(!item || type !== 'row') return;
                return item.selected ? 'export-row-selected' : '';
            },
            multiColumnSpaceFilter(item, filter) {
                var filters = filter.split(" ");
                return filters.reduce((acc, fil) => {
                    if(!acc) return acc;
                    const keys = this.fields.map(k => k.key);
                    for (let i = 0; i < keys.length; i++) {
                        const key = keys[i];
                        if(!!String(item[key]).match(new RegExp(fil, 'i'))) return acc;
                    }
                    acc = false;
                    return acc;
                }, true);
            },
            getLocalOptions(options, initialValue) {
                return options.map(x => {
                    const newOp = { ...x };
                    newOp.key = this.getKey(newOp);
                    newOp.selected = false;
                    if(initialValue && newOp.key == this.getKey(initialValue)) newOp.selected = true;
                    return newOp;
                })
            },
            getKey(val) {
                if(val.key) return val.key;
                return JSON.stringify(val, Object.keys(val).sort());
            }
        }
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