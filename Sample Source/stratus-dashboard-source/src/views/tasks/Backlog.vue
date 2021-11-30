<template>
  <b-card>
    <b-row>
      <b-col md="3">
        <b-form-group>
          <b-input-group>
            <b-form-input placeholder="Type to Search" v-model="filter" @keyup.enter="filterTasks"></b-form-input>
            <b-input-group-append>
              <b-button @click="filterTasks" variant="primary">Filter</b-button>
              <b-button :disabled="!filter" @click="clearFilter">Clear</b-button>
            </b-input-group-append>
          </b-input-group>
        </b-form-group>
      </b-col>
      <b-col class="d-flex justify-content-end">
        <template v-if="initialLoad || this.polling > 0">
          <span class="text-primary mt-1 pr-2">Live</span>
          <b-spinner type="grow" variant="primary"></b-spinner>
        </template>
        <template v-else>
          <span class="text-secondary">Connecting...</span>
        </template>
      </b-col>
    </b-row>
    <b-row>
      <b-col>
        <b-form-group label="From:">
          <b-form-datepicker v-model="dateFrom" value-as-date @input="updateDates"></b-form-datepicker>
        </b-form-group>
      </b-col>
      <b-col>
        <b-form-group label="To:">
          <b-form-datepicker v-model="dateTo" value-as-date @input="updateDates"></b-form-datepicker>
        </b-form-group>
      </b-col>
    </b-row>
    <b-table striped
              hover
              small
              bordered
              responsive
              :fields="fields"
              :items="filteredItems"
              :current-page="currentPage"
              :per-page="perPage"
              :sort-by.sync="sortBy"
              :sort-desc.sync="sortDesc">
      <template v-slot:cell(programRef)="data">
        <b-link :to="getLink(data.item)" target="_blank">{{ data.value }}</b-link>
      </template>

      <template v-slot:cell(Message._)="data">
        <stratus-task-message :message="data.value" />
      </template>

      <template v-slot:cell(Status._)="data">
        <b-link v-if="data.value == 'Manual Input'"
                :to="getLink(data.item)"
                target="_blank">
          {{ data.value }}
        </b-link>
        <span :class="badgeClass(data.item)" v-if="data.value != 'Manual Input'" :to="getLink(data.item)">{{ data.value }}</span>
      </template>

      <template v-slot:cell(Progress._)="data" >
        <b-progress :max="100" class="mt-2" v-show="data.value > 0">
          <b-progress-bar :value="data.value">{{ data.value }}%</b-progress-bar>
        </b-progress>
      </template>

      <template v-slot:cell(CreatedOn._)="data" >
        <span> {{ data.value | moment(dateFormat) }} </span>
      </template>

      <template v-slot:cell(History)="data">
        <b-link class="float-right" @click="showModal(data.item)" title="History" v-b-tooltip.hover><fa-icon icon="history" /></b-link>       
      </template>

    </b-table>
    <nav>
      <b-row>
        <b-col md="auto">
          <b-pagination :total-rows="totalRows" :per-page="perPage" v-model="currentPage" prev-text="Prev" next-text="Next" />
        </b-col>
        <b-col>
          <b-form inline>
            <span class="mr-2">Go to page: </span>
            <b-input type="number" v-model="currentPage" min="1" :max="maxPage"></b-input>
          </b-form>
        </b-col>
      </b-row>
    </nav>
    <div>Tasks loaded: {{totalTasks}}</div>
    <div>Filtered tasks: {{totalRows}}</div>
    <HistoryModal />
  </b-card>
</template>

<script>
  import { mapState, mapGetters } from 'vuex';
  import HistoryModal from '@/components/task/History';
  import { ACCOUNT_TYPES } from '../../shared/types'; 
  import StratusTaskMessage from '../../components/task/StratusTaskMessage';

const badgeDetail = {
    pending: {
        text: 'pending',
        class: 'text-warning',
    },
    inProgress: {
        text: 'in progress',
        class: 'text-dark',
    },
    manualInput: {
        text: 'manual input',
        class: 'text-warning',
    },
    failed: {
        text: 'failed',
        class: 'text-danger',
    },
    complete: {
        text: 'completed',
        class: 'text-success',
    }
};

export default {
  name: 'Backlog',
  components: {
    HistoryModal,
    StratusTaskMessage
  },
  props: {
    taskRef: {
      type: String,
      required: false
    },
    defaultDateFrom: {
      type: Date,
      required: false,
      default: function() {
        return new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate() - 1)
      }
    }
  },
  computed: {
    ...mapState({
      items: s => [...s.tasks.items.manualInput, ...s.tasks.items.pending, ...s.tasks.items.inProgress, ...s.tasks.items.failed, ...s.tasks.items.complete]
    }),
    ...mapGetters('auth', {
      isLoggedIn: 'isLoggedIn'
    }),
    ...mapGetters({
      //analysisCheck: 'account/index/isStandaloneAnalysis',
      totalTasks: 'tasks/tasksLoaded'
    }),
    maxPage() {
      return Math.ceil(this.totalRows / this.perPage);
    },
    requestPayload() {
      return this.taskRef ? {taskReference: this.taskRef, showSpinner: true} : {};
    }
  },
  data() {
    return {
      sortBy: 'CreatedOn._',
      sortDesc: true,
      polling: null,
      fields: [
        { key: 'History', label: ''},
        { key: 'programRef', label: 'Program Reference', sortable: true },
        { key: 'Type._', label: 'Task Type' },
        { key: 'Status._', label: 'Status', sortable: true },
        { key: 'Progress._', label: 'Progress' },
        { key: 'Message._', label: 'Message', tdClass:'table-ellipsis'},
        { key: 'CreatedOn._', label: 'Requested On', sortable: true },
        { key: 'CreatedBy._', label: 'Requested By' }          
      ],
      perPage: 20,
      currentPage: 1,
      dateFormat: config.dateFormat,
      totalRows: 1,
      filter: null,
      filteredItems: null,
      pauseLoadTasks: false,
      initialLoad: false,
      dateFrom: new Date(),
      dateTo: new Date()
    }
  },
  methods: {
    itemLane(item) {

       switch (item.Status._) {
        case 'Pending':
           return 'pending';
        case 'In Progress':
          return 'inProgress';
        case 'Manual Input':
          return 'manualInput';
        case 'Failed':
          return 'failed';
        default:
         return 'complete';
       }      
    },
    filterTasks() {
      if (this.filter) {
        this.filteredItems = this.items.filter(x => x.programRef.toUpperCase().includes(this.filter.toUpperCase())
          || (x.Status && x.Status._.toUpperCase().includes(this.filter.toUpperCase()))
          || (x.CreatedBy && x.CreatedBy._.toUpperCase().includes(this.filter.toUpperCase())
          || (x.Type && x.Type._.toUpperCase().includes(this.filter.toUpperCase())))
          || (x.Message && x.Message._.toUpperCase().includes(this.filter.toUpperCase()))
          || (x.CreatedBy && x.CreatedBy._.toUpperCase().includes(this.filter.toUpperCase()))
        );        
      }
      else {
        this.filteredItems = this.items;      
      }     
      this.totalRows = this.filteredItems.length;      
    },
    updateTasksIfNoFilter() {
      if(!this.filter) {
        this.filterTasks();
      }
    },
    clearFilter() {
      this.filter = "";
      this.filterTasks();
    },
    badgeText(item) {
      const lane = this.itemLane(item);
      return badgeDetail[lane].text;
    },
    badgeClass(item) {
      const lane = this.itemLane(item);
      return badgeDetail[lane].class;
    },
    async loadTasks() {
      this.initialLoad = true;
      //let payload = this.taskRef ? {taskReference: this.taskRef, showSpinner: true} : {};
      await this.$store.dispatch('tasks/loadTasks', this.requestPayload);
      this.updateTasksIfNoFilter();
      this.initialLoad = false;
      
      this.startPolling();
    },
    showModal(item) {
        this.$store.dispatch('tasks/loadTaskHistory', { taskReference: item.PartitionKey._, taskId: item.RowKey._  }); 
        this.$root.$emit('bv::show::modal', 'task-history')
    },
    pauseReload() {
      this.pauseLoadTasks = true;
    },
    resumeReload() {
      this.pauseLoadTasks = false;
    },
    getLink(item) {
      //console.log(this.analysisCheck);
      return ACCOUNT_TYPES.getLink(item);//, this.analysisCheck);
    },
    updateDates() {
      this.$store.dispatch('tasks/updateDates', {
        dateFrom: this.dateFrom,
        dateTo: this.dateTo
      });
    },
    startPolling() {
      this.$store.dispatch('tasks/updateTasks', {...(this.requestPayload), showSpinner: false});
      this.polling = setInterval(async () => {
        if (!this.pauseLoadTasks) {
          await this.$store.dispatch('tasks/updateTasks', {...(this.requestPayload), showSpinner: false});
          this.updateTasksIfNoFilter();
        }
      }, 5000);
    },
    stopPolling() {
      clearInterval(this.polling);
    },
    visibilityChangeEventListenerFn() {
      if(document.visibilityState === 'visible') {
        this.startPolling();
      } else {
        this.stopPolling();
      }
    }
  },  
  beforeDestroy() {
    this.$bus.off('pause-tasks-reload', this.pauseReload);
    this.stopPolling();
    //clearInterval(this.polling);
    //this.$store.commit('tasks/reset');
    document.removeEventListener('visibilitychange', this.visibilityChangeEventListenerFn);
  },
  destroyed() {
    
  },
  async created() {    
    this.dateFrom = this.defaultDateFrom;
    this.dateTo = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());
    this.updateDates();
    if (!this.isLoggedIn) {
      return;
    }
    this.initialLoad = true;
    this.$store.dispatch('account/index/initialise')
    this.loadTasks();
    this.totalRows = this.items.length;
    
    document.addEventListener('visibilitychange', this.visibilityChangeEventListenerFn);
  },
  mounted() {
    this.$bus.on('pause-tasks-reload', this.pauseReload);
    this.$bus.on('resume-tasks-reload', this.resumeReload);   
  },
};
</script>

<style>
  .popover {
    white-space: pre-wrap;
  }
</style>