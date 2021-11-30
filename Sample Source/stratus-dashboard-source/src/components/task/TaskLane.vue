 <template>
   <b-card header-tag="header" body-class="pl-0 pr-0 pb-0">
     <template v-slot:header>
        <h6 class="mb-0 text-center">{{ title }}
          <span class="float-right" v-if="itemCount > 0">
            <fa-icon icon="tasks" class="mr-2"/>
            <b-badge class="badge-task" :variant="variant">{{ itemCount }}</b-badge>
          </span>
        </h6>
     </template>
     
     <div v-for="item in items" :key="item.id">
       <item :item="item"></item>
     </div>     
   </b-card>    
</template>

<script>
import TaskLaneItem from './TaskLaneItem';

export default {
  name: 'task-lane',
  props: ['items', 'title', 'id'],
  components: {
    item: TaskLaneItem
  },
  computed: {
    itemCount() {
      return this.items.length;
    },
    variant() {
      switch (this.title) {
        case "Pending":
          return "info";
        case "Manual Input":
          return "warning";
        case "In Progress":
          return "primary";
        case "Failed":
          return "danger";
        case "Completed":
          return "success";
      }
    }
  },
};
</script>

<style>
  .badge-task {    
    position: relative;
    top: -6px;
    left: -8px;
  }
</style>
