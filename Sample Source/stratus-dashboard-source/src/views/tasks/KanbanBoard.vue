<template>
  <div>
    <b-card-group deck>
      <task-lane id="pending" title="Pending" :items="pendingItems"></task-lane>
      <task-lane id="inProgress" title="In Progress" :items="inProgressItems"></task-lane>
      <task-lane id="failed" title="Failed" :items="failedItems"></task-lane>
      <task-lane id="complete" title="Completed" :items="completeItems" v-if="displayComplete"></task-lane>
    </b-card-group>
    <HistoryModal/>
  </div>  
</template>

<script>
import { mapState } from 'vuex';
import TaskLane from '@/components/task/TaskLane';
import HistoryModal from '@/components/task/History';

export default {
  name: 'KanbanBoard',
  props: ['taskRef'],
  components: {
    TaskLane,
    HistoryModal
  },
  data() {
    return {
      polling: null,
      pauseLoadTasks: false,
      displayComplete: false
    };
   },
  mounted() {
    this.$bus.on('pause-tasks-reload', this.pauseReload);
    this.$bus.on('resume-tasks-reload', this.resumeReload);   
  }, 
  computed: mapState({
        pendingItems: s => s.tasks.items.pending,
        inProgressItems: s => s.tasks.items.inProgress,
        manualInputItems: s => s.tasks.items.manualInput,
        failedItems: s => s.tasks.items.failed,
        completeItems: s => s.tasks.items.complete
  }),
  methods: {
    async loadTasks() {
      await this.$store.dispatch('tasks/loadTasks', {taskReference: this.taskRef, showSpinner: true});
      this.displayComplete = true;
      
      this.polling = setInterval(() => {
        if (!this.pauseLoadTasks) {
          if (this.taskRef) {
            this.displayComplete = true;
          }

          this.$store.dispatch('tasks/loadTasks', {taskReference: this.taskRef, showSpinner: false});
        }
      }, 3000);
    },
    pauseReload() {
      this.pauseLoadTasks = true;
    },
    resumeReload() {
      this.pauseLoadTasks = false;
    }
  },
  beforeDestroy() {
    this.$bus.off('pause-tasks-reload', this.pauseReload);
    clearInterval(this.polling);
  },
  created() {
    this.loadTasks();
  },
};
</script>
