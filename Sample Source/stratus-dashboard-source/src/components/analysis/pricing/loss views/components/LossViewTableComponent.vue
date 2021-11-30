<template>
    <b-container fluid>
        <b-row>
            <b-col class="mb-2" style="display: flex; justify-content: flex-end">
                <b-button variant="success"
                    @click="addView"
                    class="m-1 mr-n2"
                    :disabled="slotsRemaining === 0">
                    Add
                </b-button>
            </b-col>
        </b-row>
        <b-row>
            <b-table id="lossView-table"
                :fields="fields"
                :items="getValidViews"
                striped>
                <template v-slot:cell(index)="data">
                    {{data.index + 1}}
                </template>
                <template v-slot:cell(label)="data">
                    <span class="label-link" @click="activateView(data.item.id)">{{data.value}}</span>
                </template>
                <template v-slot:cell(description)="data">
                    <div class="text-truncate" style="max-width: 250px">{{data.value}}</div>
                </template>
                <template v-slot:cell(unmapped)="data">
                    {{getUnmappedInputs(data.item.id).length}}
                </template>
                <template v-slot:cell(remove)="data">
                    <div class="d-flex justify-content-end">
                        <b-button :id="`delete-btn_${data.item.id}`"
                            pill variant="danger"
                            @click="handleViewDelete(data.item.id)"
                            class="delete-item-btn">
                            -
                        </b-button>
                    </div>
                </template>
            </b-table>
        </b-row>
    </b-container>
</template>

<script>
import {mapState, mapGetters} from 'vuex';
    export default {
        data() {
            return {
                fields: [
                    {
                        key: 'index',
                        label: 'ID'
                    },
                    {
                        key: 'label',
                        label: 'Name'
                    },
                    {
                        key: 'type',
                        label: 'Type'
                    },
                    {
                        key: 'loss',
                        label: 'Expected Loss'
                    },
                    {
                        key: 'unmapped',
                        label: 'Inputs Outstanding'
                    },
                    {
                        key: 'remove',
                        label: ''
                    }
                ]
            }
        },
        computed: {
            ...mapState({
                views: state => state.pricing.views.data
            }),
            ...mapGetters('pricing/views', [
                'getUnmappedInputs',
                'slotsRemaining',
                'getValidViews',
                'getFirstValidIndex'
            ]),
            items() {
                return this.views.filter(x => x !== undefined);
            }
        },
        methods: {
            addView() {
                this.$store.dispatch('pricing/views/commitChange', { mutation: 'addView', data: this.getFirstValidIndex });
            },
            handleViewDelete(id) {
                this.$store.dispatch('pricing/views/deleteLossView', id);
            },
            activateView(id) {
                this.$store.commit('pricing/views/activateView', id);
            }
        }
    }
</script>

<style lang="scss" scoped>
.delete-item-btn {
    height: 22px;
    width:  22px;
    margin-top: 0px;
    padding-left: 6.5px;
    padding-top: 1.5px;
    
}

.label-link {
    color: #20a8d8;
    text-decoration: none;
    background-color: transparent;

    &:hover {
        color: #167495;
        text-decoration: underline;
        cursor: pointer;
    }
}


</style>