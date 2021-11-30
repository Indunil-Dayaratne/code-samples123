<template>
    <b-modal :id="id"
        title="Load files"
        size="xl"
        :ok-disabled="!readyToLoad"
        @ok="loadFiles">
        <b-container fluid>
            <b-row>
                <b-col>
                    <b-form-group :id="`${id}_folder_inputgroup`"
                        label="Enter folder on Touchstone server"
                        :label-for="`${id}_folder_input`">
                        <b-input-group :id="`${id}_folder_input`">
                            <b-form-input v-model.lazy="folder"
                                type="text"
                                placeholder="Enter folder location">
                            </b-form-input>
                            <b-input-group-append>
                                <b-button @click="getFiles"
                                    :disabled="fileLoadSpinner">
                                    Get files
                                </b-button>
                            </b-input-group-append>
                        </b-input-group>
                    </b-form-group>
                </b-col>
            </b-row>
            <b-row class="mb-2" v-if="folders.length > 0">
                <b-col>
                    <div class="mb-1">
                        Previous options
                    </div>
                    <div class="link-container">
                        <div v-for="folder in folders" :key="folder">
                            <b-link href="#" @click="setFolder(folder)">{{folder}}</b-link>
                        </div>
                    </div>
                    
                </b-col>
            </b-row>
            <b-row>
                <b-col>
                    <b-form-group :id="`${id}_yoa_input_group`"
                        label="Enter YOA"
                        :label-for="`${id}_yoa_input`">
                        <b-form-input :id="`${id}_yoa_input`"
                            type="number"
                            v-model.number="yoa">
                        </b-form-input>
                    </b-form-group>
                </b-col>
            </b-row>
            <b-row>
                <b-col class="mb-2">
                    <b-button @click="selectAll">Select all</b-button>
                    <b-button @click="clearSelections">Clear all</b-button>
                </b-col>
            </b-row>
            <b-row>
                <b-col>
                    <b-table :id="`${id}_file_table`"
                        class="fileSelectionTable"
                        :items="validFiles"
                        :fields="fileFields"
                        :busy="fileLoadSpinner"
                        @row-clicked="rowClicked"
                        :tbody-tr-class="isRowSelectedClass"
                        striped hover show-empty>
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

                        <template v-slot:cell(Name)="data">
                            {{ data.value.substring(0, data.value.lastIndexOf('.')) }}
                        </template>

                        <template v-slot:cell(Size)="data">
                            {{ formatSize(data.value) }}
                        </template>

                        <template v-slot:cell(Directory)="data">
                            {{ data.value.substring(data.value.lastIndexOf('\\') + 1) }}
                        </template>

                        <template v-slot:table-busy>
                            <div class="text-center text-primary my-2">
                                <b-spinner class="align-middle"></b-spinner>
                                <strong>Loading files...</strong>
                            </div>
                        </template>

                        <template v-slot:empty>
                            <div class="text-center text-secondary my-2">
                                <h4>Load folder...</h4>
                            </div>
                        </template>
                    </b-table>
                </b-col>
            </b-row>
        </b-container>
    </b-modal>
</template>

<script>
import api from '../../../shared/api';
import { mapState, mapGetters } from 'vuex';
import numeral from 'numeral';

 const stringSorter = function(a, b) {
    if(a < b) return -1;
    if(a > b) return 1;
    return 0;
};

export default {
    name: "FileLoadModal",
    components: {},
    props: {
        id: {
            type: String,
            required: true
        }
    },
    data() {
        return {
            folder: '',
            yoa: new Date().getFullYear(),
            files: [],
            fileLoadSpinner: false,
            fileFields: [
                { key: 'selected', label: '' },
                { key: 'Name' },
                { key: 'Extension' },
                //{ key: 'Directory' },
                { key: 'Size' }
            ]
        }
    },
    computed: {
        ...mapState({
            programRef: (state, get) => get['account/get']('programRef'),
            user: (state) => state.auth.user.userName,
            defaultCurrency: (state, get) => get['account/get']('defaultCurrency'),
            accountName: (state, get) => get['account/get']('accountName'),
            folders: (state, get) => get['account/get']('files/folders'),
            isFileLoaded: (state, get) => get['account/get']('files/isFileLoaded')
        }),
        folderInputState() {

        },
        validFiles() {
            const validExtensions = ['.rpx', '.evi', '.mdf', '.bak', '.zip'];
            let files = this.files;
            return this.files.filter(f => validExtensions.includes(f.Extension.toLowerCase()))
                // .map(f => {
                //     return {
                //         ...f,
                //         disabled: f.Extension === '.mdf' && files.filter(fi => fi.Path === f.Path.replace('.mdf', '.bak')),
                //     }
                // })
                .sort((a, b) => stringSorter(a.Name, b.Name));
        },
        selected() {
            return this.validFiles.filter(x => x.selected);
        },
        readyToLoad() {
            return this.selected.length > 0;
        }
    },
    methods: {
        async getFiles() {
            this.fileLoadSpinner = true;
            let files = await api.getFiles(this.programRef, this.folder, this.user);
            const self = this;
            files.forEach(x => {
                const isMdf = !!x.Extension.match(/.mdf\s*$/gi);
                const isBak = !!x.Extension.match(/.bak\s*$/gi);
                const relativeBakPath = x.Path.replace(/.mdf\s*/gi, '.bak');
                const relativeMdfPath = x.Path.replace(/.bak\s*/gi, '.mdf');
                x.disabled = self.isFileLoaded(x.Path)
                    || (isMdf && files.filter(fi => fi.Path.toLowerCase() == relativeBakPath.toLowerCase()).length > 0)
                    || (isBak && self.isFileLoaded(relativeMdfPath));
                x.selected = false;
                if(!x.disabled) x.selected = true;
            })
            this.files = files;
            this.fileLoadSpinner = false;
        },
        formatSize(size) {
            return numeral(size).format('0.0 b');
        },
        rowClicked(item, index) {
            this.files.forEach(element => { 
                if(!element.disabled && element.Path === item.Path) element.selected = !element.selected
            });
        },
        isRowSelectedClass(item, type) {
            if(!item || type !== 'row') return;
            let classes = '';
            if(item.disabled) classes = classes.concat(' ', 'file-row-disabled');
            if(item.selected) classes = classes.concat(' ', 'file-row-selected');
            return classes;
        },
        selectAll() {
            for (let i = 0; i < this.validFiles.length; i++) {
                const element = this.validFiles[i];
                if(!element.disabled) element.selected = true;
            }
        },
        clearSelections() {
            for (let i = 0; i < this.validFiles.length; i++) {
                const element = this.validFiles[i];
                element.selected = false;
            }
        },
        loadFiles() {
            for (let i = 0; i < this.selected.length; i++) {
                const element = this.selected[i];
                api.loadFile(element, this.yoa, this.programRef, this.accountName, this.defaultCurrency, 'Manual file load', true, this.user);
            }
            this.$router.push(`/program/${this.programRef}/tasks`);
        },
        setFolder(previousFolder) {
            this.folder = previousFolder;
        }
    },
}
</script>

<style lang="scss">
.fileSelectionTable {
    tr {
        cursor: pointer;
        user-select: none;
    }

    .file-row-selected {
        & > td {
           border-color: #8bd2eb;
           background-color: #c1e7f4; 
        }
    }

    .file-row-disabled, .file-row-disabled:hover {
        cursor: not-allowed;
        font-style: italic;
        background-color: rgba(0, 0, 0, 0.1);
    }
}

.link-container {
    max-height: 25vh;
    overflow-y: auto;
}
</style>