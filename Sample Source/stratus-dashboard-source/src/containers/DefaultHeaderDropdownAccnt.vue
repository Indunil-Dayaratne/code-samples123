<template>
  <div>
    <AppHeaderDropdown right no-caret class="pr-3" v-if="!user"> 
      <template v-slot:header>
        <strong>Anonymous</strong>
      </template>
      <template v-slot:dropdown>
        <b-dropdown-item @click="login"><fa-icon icon="lock" class="mr-2" />Login</b-dropdown-item>
      </template>
    </AppHeaderDropdown>  
    <AppHeaderDropdown right no-caret class="pr-3" v-if="user"> 
      <!-- Authenticated -->
      <template v-slot:header>
        <strong>{{ user.userName }}</strong>
      </template>
      <template v-slot:dropdown>
        <b-dropdown-item @click="logout"><fa-icon icon="lock" class="mr-2" />Logout</b-dropdown-item>
      </template>
    </AppHeaderDropdown>
  </div>
</template>

<script>
  import { HeaderDropdown as AppHeaderDropdown } from '@coreui/vue';
  import { mapState } from 'vuex';

  export default {
    name: 'DefaultHeaderDropdownAccnt',
    components: {
      AppHeaderDropdown,
    },
    mounted() {
      this.setUser();
    },
    computed: mapState({
      user: s => s.auth.user
    }),
    methods: {
      logout() {
        this.user = null;
        this.$store.dispatch('auth/logOut');
      },
      login() {
        this.$store.dispatch('auth/logIn');
      },
      setUser() {
        this.$store.dispatch('auth/setUser');
      },
    },
  };
</script>