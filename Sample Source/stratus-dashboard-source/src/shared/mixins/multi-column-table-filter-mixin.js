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
    },
    data() {
        return {
            filter: null,
            fields: [],
            options: [],
            ref: ''
        }
    },
    watch: {
        options() {
            for (let i = 0; i < this.options.length; i++) {
                const option = this.options[i];
                if(!option) continue;
                if(!option.key) option.key = new Date().getTime();
            }
        }
    },
    computed: {
        selectedCount() {
            return this.options.filter(x => x.selected).length;
        },
        selectMode() {
            return this.single ? 'single' : 'range'
        },
        selected() {
            return this.single ? this.options.find(x => x.selected) : this.options.filter(x => x.selected);
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
            for (let i = 0; i < this.options.length; i++) {
                const element = this.options[i];
                if(filterKeys.includes(element.key)) element.selected = true;
                else if (filterKeys.length === 0) element.selected = true;
            }   
            this.$emit('input', this.selected);   
        },
        clearSelections() {
            this.refCheck();
            const filterKeys = this.filter ? this.$refs[this.ref].filteredItems.map(x => x.key) : [];
            for (let i = 0; i < this.options.length; i++) {
                const element = this.options[i];
                if(filterKeys.includes(element.key)) element.selected = false;
                else if (filterKeys.length === 0) element.selected = false;
            }
            this.$emit('input', this.selected);
        },
        rowClicked(item, index) {
            this.options.forEach(element => { 
                if(element.key === item.key) element.selected = !element.selected 
                else if(this.single) element.selected = false;
            });
            this.$emit('input', this.selected);
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
        }
    },
}