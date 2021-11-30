<template>
  <b-card>
    <b-row>
      <b-col md="8">
        <b-button v-if="type.canCreateModal" @click="$bvModal.show(modalTitle)" variant="info">New {{type.name}}</b-button>
      </b-col>
      <b-col md="4" class="mb-2 d-flex justify-content-end">
        <b-input-group>
          <b-input :placeholder="`Search ${type.plural}`" v-model="filter"/>
          <b-input-group-append>
            <b-button @click="clearFilter">Clear</b-button>
          </b-input-group-append>
      </b-input-group>
      <new-program-modal />
      <analysis-modal />
      </b-col>
    </b-row> 
    <b-table striped hover small bordered show-empty 
      :fields="fields" 
      :items="items" 
      :current-page="currentPage" 
      :per-page="perPage"
      :sort-by.sync="sortBy"
      :sort-desc.sync="sortDesc"
      :filter="filter"
      @filtered="onFiltered">
      <template v-slot:cell(ProgramRef)="data" >
        <b-link :to="getLink(data)">
          {{ data.value }}
        </b-link>
      </template>
      <template v-slot:cell(CreatedOn)="data">
        <span> {{ data.value | moment(dateFormat) }} </span>
      </template>
    </b-table>
    <nav>
      <b-pagination :total-rows="totalRows" :per-page="perPage" v-model="currentPage" prev-text="Prev" next-text="Next" hide-goto-end-buttons />
    </nav>
  </b-card>
</template>

<script>
  import NewProgramModal from '@/components/analysis/NewProgramModal';
  import AnalysisModal from '../../components/analysis/AnalysisModal';
  import azure from 'azure-storage';
  import { mapState, mapGetters } from 'vuex';
  import { ACCOUNT_TYPES } from '../../shared/types';
  import api from '../../shared/api';

  export default {
    name: "AnalysisIndex",
    props: {
      type: {
        type: Object,
        default: ACCOUNT_TYPES.analysis
      },
      programFilter: {
        type: String,
        default: ''
      }
    },
    components: {
      NewProgramModal,
      AnalysisModal
    },
    data() {
      return {
        sortBy: 'CreatedOn',
        sortDesc: true,
        polling: null,
        fields: [
          { key: 'ProgramRef', label: 'Program Reference', sortable: true },
          { key: 'AccountName', label: 'Account Name', sortable: true },
          { key: 'Summary', label: 'Summary' },
          { key: 'CreatedOn', label: 'Requested On', sortable: true},
          { key: 'CreatedBy', label: 'Requested By', sortable: true}
        ],
        perPage: 20,
        currentPage: 1,
        dateFormat: config.dateFormat,
        filter: null,
        filterRows: 0     
      };
    },
    computed: {
      ...mapGetters('account/index',{
        programs: 'getPrograms',
        analyses: 'getAnalyses'
      }),
      items() {
        switch (this.type.name) {
          case ACCOUNT_TYPES.program.name:
            return this.programs.filter(x => !this.programFilter || (this.programFilter && x.ProgramRef === this.programFilter));

          case ACCOUNT_TYPES.analysis.name:
            return this.analyses.filter(x => (!this.programFilter || (this.programFilter && (x.ProgramRef === this.programFilter || api.checkAnalysisProgramReference(this.programFilter, x.ProgramRef)))));
        
          default:
            break;
        }
      },
      totalRows() {
        return !!this.filter ? this.filterRows : this.items.length;
      },
      modalTitle() {
        return this.type.name === ACCOUNT_TYPES.program.name ? 'new-program-modal' : 'analysis-modal'
      }
    },
    methods: {
      getLink(data) {
        return {
          name: this.type.routeName, 
          params: {
            programRef: data.value, 
            id: data.item.AnalysisId
          }
        }
      },
      clearFilter() {
        this.filter = '';
        this.filterRows = 0;
      },
      onFiltered(filtered, filterCount) {
        this.filterRows = filterCount;
      }
    },
    created () {
      this.$store.dispatch('account/index/initialise');
      this.$store.dispatch('pricing/getExchangeRates');
    },
  }

</script>
