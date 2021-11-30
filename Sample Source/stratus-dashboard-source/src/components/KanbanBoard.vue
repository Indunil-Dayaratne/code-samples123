<template>
  <div class="board">
    <div class="row">
      <div class="col-md-12">
        <button @click="loadTasks" class="btn btn-primary">
          Load Tasks
        </button>
      </div>
    </div>
    <div class="row">
        <div class="col-md">
          <task-lane id="pending" title="Pending" :items="pendingItems"></task-lane>
        </div>
        <div class="col-md">
          <task-lane id="inProgress" title="In progress" :items="inProgressItems"></task-lane>
        </div>
        <div class="col-md">
          <task-lane id="complete" title="Complete" :items="completeItems"></task-lane>
        </div>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex';
import TaskLane from './TaskLane';

export default {
  name: 'KanbanBoard',
  components: {
    'task-lane': TaskLane,
  },
  computed: mapState({
    pendingItems: s => s.items.pending,
    inProgressItems: s => s.items.inProgress,
    completeItems: s => s.items.complete,
  }),
  methods: {
    loadTasks() {
      this.$store.dispatch('LOAD_TASKS');
    },
  },
};
</script>
