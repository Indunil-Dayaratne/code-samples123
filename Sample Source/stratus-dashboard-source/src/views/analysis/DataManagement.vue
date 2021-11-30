<template>
    <b-card no-body>
        <b-card-body>
            <b-table
                :items="files"
                :fields="fields" 
                sort-by="Size"
                sort-desc
                striped hover>
                <template v-slot:cell(PartitionKey)="pk">
                    <b-link :to="`/program/${pk.value}/files`">
                        {{pk.value}}
                    </b-link>
                </template>
                <template v-slot:cell(Size)="data">
                    {{ formatSize(data.value) }}
                </template>
            </b-table>
        </b-card-body>
    </b-card>
</template>

<script>
import api from '../../shared/api';
import numeral from 'numeral';
    export default {
        name: 'DataManagement',
        data() {
            return {
                files: [],
                fields: [
                    { key: 'Name', sortable: true },
                    { key: 'PartitionKey', label: 'Program', sortable: true },
                    { key: 'Directory', sortable: true  },
                    { key: 'ImportedAt', label: 'Import Time', sortable: true },
                    { key: 'Size', sortable: true  }
                ]
            }
        },
        methods: {
            formatSize(size) {
                return numeral(size).format('0.0 b');
            }
        },
        async created() {
            this.files = await api.getAllFiles();
        }
    }
</script>

<style lang="scss" scoped>

</style>