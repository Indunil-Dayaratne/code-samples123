<template>
    <div>
        <b-form-group :label="labelText" :label-for="uniqueId" :label-size="labelSize" :label-cols="labelColsText">
            <b-select :id="uniqueId" :options="yoaOptions" v-model="yoa" :class="selectColsText"/>
        </b-form-group>
    </div>
</template>

<script>
    import { mapState, mapGetters } from 'vuex';

    export default {
        props: {
            prefix: {
                type: String,
                default: "",
                required: false
            },
            labelCols: {
                type: String,
                default: "3",
                required: false
            },
            labelSize: {
                type: String,
                default: "md",
                required: false
            },
            selectCols: {
                type: String,
                default: "",
                required: false
            }
        },
        data() {
            return {
                id: ""
            }
        },
        computed: {
            uniqueId() {
                return "yoaSelect_" + this.id;
            },
            ...mapState({
                yoaOptions: (state, get) => get['account/get']('files/yoaOptions')
            }),
            yoa: {
                get() {
                    return this.$store.getters['account/get']('files/yoa');
                },
                set(value) {
                    this.$store.dispatch('account/mutate', {
                        mutation: 'files/setYoa',
                        data: value
                    });
                }
            },
            labelText() {
                return this.prefix + "YOA:"
            },
            labelColsText() {
                return new String(this.labelCols);
            },
            selectColsText() {
                return this.selectCols !== "" 
                    ? "col-" + this.selectCols
                    : "";
            }
        },
        created () {
            this.id = new Date().getTime();
        },
    }
</script>

<style lang="scss" scoped>

</style>