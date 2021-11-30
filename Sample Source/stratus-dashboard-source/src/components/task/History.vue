<template>
  <b-modal id="task-history" :title="title" ok-only  @ok="handleOk" size="xl" @shown="getTaskHistory" @hidden="onHidden">        
    <b-table striped hover small bordered responsive  show-empty        
             :fields="fields" 
             :items="items" 
             :current-page="currentPage" 
             :per-page="perPage">

      <template v-slot:cell(Message)="data">
        <stratus-task-message :message="data.value"/>
      </template>

      <template v-slot:cell(Progress)="data">
        <b-progress :max="100" class="mt-2" v-show="data.value > 0">
          <b-progress-bar :value="data.value">{{ data.value }}%</b-progress-bar>
        </b-progress>
      </template>

    </b-table>
      <nav>
        <b-pagination :total-rows="totalRows" :per-page="perPage" v-model="currentPage" prev-text="Prev" next-text="Next" hide-goto-end-buttons />
      </nav>               
  </b-modal>
</template>

<script>
  import { mapState } from 'vuex';
  import StratusTaskMessage from '../task/StratusTaskMessage';
  
  export default {
    name: "TaskHistoryModal",
    components: {
      StratusTaskMessage
    },
    data() {
      return {    
        fields: [        
          { key: 'Status', label: 'Status', tdClass: 'task-10' },
          { key: 'Progress', label: 'Progress', tdClass:'task-5' },
          { key: 'Message', label: 'Message', tdClass:'table-ellipsis' },         
          {
            key: 'LastModifiedOn', label: 'Last Modified On', tdClass:'task-10', 
            formatter: (value, key, item) => {
              var date = item.ModifiedOn || item.CreatedOn;

              return this.$moment(date).format(config.dateFormat);
            }
          }
        ],
        perPage: 20,
        currentPage: 1
      };
    },
    methods: {
      getTaskHistory() {
        this.$bus.emit('pause-tasks-reload');  
      },
      handleOk() {
        this.$emit('close');
      },
      onHidden() {
       this.$bus.emit('resume-tasks-reload');
      }
    },
    computed: {
      ...mapState( {
        items: state => state.tasks.taskHistory,
      }),
      programRef() {
        var str = this.items.length ? this.items[0].PartitionKey.split("-") : "-";
        return str[0];
      },
      type() {
        return this.items.length ? this.items[0].Type : "";          
      },
      totalRows() {
        return this.items.length ? this.items.length : 0;          
      },
      title() {
        return "Task History: " + this.programRef + "/" + this.type;
      }
    }
  }
</script>

<style>
  .task-13{
    width: 13em;
  }

  .task-30{
    width: 30em;
  }

  .task-10{
    width: 10em;
  }

  .task-5{
    width: 5em;
  }

  .popover {
    white-space: pre-wrap;
  }
</style>