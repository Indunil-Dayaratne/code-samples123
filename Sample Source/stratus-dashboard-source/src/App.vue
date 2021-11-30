<template>
  <router-view></router-view>
</template>
<script>

//import './assets/css/coreui-icons.min.css';
//import './assets/css/simple-line-icons.css';
//import './assets/css/font-awesome.min.css';
import 'vue-multiselect/dist/vue-multiselect.min.css';


/* Brit Specific */
//import './assets/scss/'

export default {
  name: 'app',
};
</script>
<style lang="scss">
@import "./assets/scss/style.scss";

  .page-header h1 {
    font-weight: 300;
  }
  .card {
    margin-bottom: 10px;
  }
  .card:last-child {
    margin-bottom: 25px;
  }
  .card-block {
    padding: 15px;
  }
  multiselect, .multiselect__input, .multiselect__option, .multiselect__single {
    font-size: 1em;
  }


</style>
<style lang="scss">
  @import 'assets/scss/style';
</style>
