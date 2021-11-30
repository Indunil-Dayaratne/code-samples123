<template>
  <div class="app">
    <AppHeader fixed>
      <SidebarToggler class="d-lg-none" display="md" mobile />
      <b-link class="navbar-brand" to="#">
        <img class="navbar-brand-full" src="../assets/img/brit.png"
        alt="Brit Logo">
        <img class="navbar-brand-minimized" src="../assets/img/brit.png"
        alt="Brit Logo">
      </b-link>
      <SidebarToggler class="d-md-down-none d-none" display="lg" :defaultOpen=false />
      <b-navbar-nav class="d-md-down-none">
        <b-nav-item class="px-3" to="/program">Programs</b-nav-item>
        <b-nav-item class="px-3" to="/data">Data</b-nav-item>
        <b-nav-item class="px-3" to="/backlog" exact>Backlog</b-nav-item>
        <b-nav-item class="px-3" to="/status">Status</b-nav-item>
      </b-navbar-nav>
      <b-navbar-nav class="ml-auto">
        <!--<b-nav-item class="d-md-down-none">
          <i class="icon-bell"></i>
          <b-badge pill variant="danger">5</b-badge>
        </b-nav-item>-->
        <DefaultHeaderDropdownAccnt/>
      </b-navbar-nav>
      <AsideToggler class="d-none" />
      <AsideToggler class="d-lg-none" mobile />
    </AppHeader>
    <div class="app-body">
      <AppSidebar fixed>
        <SidebarHeader/>
        <SidebarForm/>
        <SidebarNav :navItems="nav"></SidebarNav>
        <SidebarFooter/>
        <SidebarMinimizer/>
      </AppSidebar>
      <main class="main">
        <Breadcrumb :list="list"/>
        <div class="container-fluid">
          <router-view></router-view>
        </div>
      </main>
      <AppAside fixed>
        <!--aside-->
        <DefaultAside/>
      </AppAside>
    </div>
    <TheFooter>
      <!--footer-->
      <div>
        <a href="http://www.britinsurance.com">Brit Insurance</a>
        <span>&copy; {{ new Date() | moment('YYYY') }}.</span>
      </div>
    </TheFooter>
  </div>
</template>

<script>
import nav from '@/nav';
import { Header as AppHeader, SidebarToggler, Sidebar as AppSidebar, SidebarFooter, SidebarForm, SidebarHeader, SidebarMinimizer, SidebarNav, Aside as AppAside, AsideToggler, Footer as TheFooter, Breadcrumb } from '@coreui/vue';
import DefaultAside from './DefaultAside';
import DefaultHeaderDropdownAccnt from './DefaultHeaderDropdownAccnt';

export default {
  name: 'DefaultContainer',
  components: {
    AsideToggler,
    AppHeader,
    AppSidebar,
    AppAside,
    TheFooter,
    Breadcrumb,
    DefaultAside,
    DefaultHeaderDropdownAccnt,
    SidebarForm,
    SidebarFooter,
    SidebarToggler,
    SidebarHeader,
    SidebarNav,
    SidebarMinimizer,
  },
  data() {
    return {
      nav: nav.items,
    };
  },
  computed: {
    name() {
      return this.$route.name;
    },
    list() {
      const output = this.$route.matched.filter(route => route.meta.label || route.name).map(x => Object.create(x)); 
      const $route = this.$route;
      output.forEach(route => {
        Object.keys(this.$route.params).forEach(key => {
          route.path = route.path.replace(`:${key}`, $route.params[key]);
        });
      });
      return output;
    },
  },
};
</script>

<style lang="scss" scoped>
  .main .container-fluid {
    padding: 0 10px;
  }

  .app-header .navbar-brand
  {
    width: 85px;
  }
  .breadcrumb {
    margin-bottom: 0.5rem;
    padding: 0.5rem 1rem;
  }

  img {
    width: 95%;
    height: 95%;
    object-fit: contain;
    //margin-bottom: 10px;
  }

</style>