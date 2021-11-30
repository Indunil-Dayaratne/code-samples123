<template>
  <div>
    <b-card header-tag="header" no-body class="mb-3">
      <template v-slot:header>
        <div >        
          <b-link class="text-dark task-header" :to="{ name:'AnalysisDetails', params: { programRef: item.programRef, id: item.analysisId } }" target="_blank">{{item.text}}</b-link>
          <b-link class="float-right h5 ml-0" @click="showModal(item)" title="History" v-b-tooltip.hover><fa-icon icon="history" /></b-link>     
        </div>
      </template>
      <b-card-text>
        <b-link class="m-2" v-if="item.Status._ == 'Manual Input'" :to="{ name:'AnalysisDetails', params: { programRef: item.programRef, id:item.analysisId }, query: { tab: item.Data ? item.Data._ : 'AnalysisDetails' , taskId: item.RowKey._ } }" target="_blank">Action</b-link>

        <b-progress :max="100" class="mt-2"  v-if="item.Progress && item.Progress._ > 0">
          <b-progress-bar :value="item.Progress._">{{ item.Progress._ }}%</b-progress-bar>
        </b-progress>
      </b-card-text>      
    </b-card>
  </div>
</template>
<script>
  import HistoryModal from './History';

  export default {
    name: 'TaskLaneItem',
    components: {
      HistoryModal
    },
    methods:{
      showModal(item) {
        this.$store.dispatch('tasks/loadTaskHistory', { taskReference: item.PartitionKey._, taskId: item.RowKey._  }); 
        this.$root.$emit('bv::show::modal', 'task-history')
      }
    },
    props: ['item']
  };
</script>

<style>
  .task-header {
    font-size: 80%;
    font-weight: 500;   
  }
</style>