<template>
  <b-tabs>
    <b-tab>
      <template v-slot:title>
        <i class='icon-list'></i>
      </template>
      <b-list-group class="list-group-accent">
      </b-list-group>
    </b-tab>
  </b-tabs>
</template>

<script>
import { Switch as cSwitch } from '@coreui/vue';

export default {
  name: 'DefaultAside',
  components: {
    cSwitch,
  },
};
</script>
