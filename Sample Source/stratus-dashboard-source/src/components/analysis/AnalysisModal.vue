<template>
  <b-modal 
      id="analysis-modal"
      ref="analysisModal"
      centered title="New Analysis Request" 
      @ok="handleOk"  
      @show="resetModal"
      @hidden="resetModal">
    <b-form>
      <b-form-group label="Account Name:" label-for="txtAccountName">
        <b-input id="txtAccountName"
                      v-model="accountName"
                      placeholder="Enter Account Name"
                      :state="$v.accountName.$dirty ? !$v.accountName.$error : null"
                      aria-describedby="account-name-feedback" />

        <b-form-invalid-feedback id="account-name-feedback">
          Account name is required
        </b-form-invalid-feedback>
      </b-form-group>
      <b-form-group label="Program Ref:" label-for="txtProgramRef">
        <b-input id="txtProgramRef"
                      v-model="programRef"
                      placeholder="Enter Program Reference"
                      :state="$v.programRef.$dirty ? !$v.programRef.$error : null" 
                      aria-describedby="program-ref-feedback"/>

        <b-form-invalid-feedback id="program-ref-feedback">
          Program reference is required and must be alpha numeric
        </b-form-invalid-feedback>
      </b-form-group>
      <b-form-group label="Summary:" label-for="txtSummary">
        <b-input id="txtSummary"
                      v-model="summary"
                      placeholder="Enter Summary"
                      :state="$v.summary.$dirty ? !$v.summary.$error : null"
                      aria-describedby="summary-feedback"/>

        <b-form-invalid-feedback id="summary-feedback">
          Summary is required
        </b-form-invalid-feedback>
      </b-form-group>
      <b-form-group label="Data File Location:" label-for="txtDataFileLocation">
        <b-input id="txtDataFileLocation"
                      v-model="dataFileLocation"
                      placeholder="Enter Data File Location"
                      :state="$v.dataFileLocation.$dirty ? !$v.dataFileLocation.$error : null"
                      aria-describedby="summary-feedback" />

        <b-form-invalid-feedback id="summary-feedback">
          Data file location required
        </b-form-invalid-feedback>
      </b-form-group>
      <b-form-group label="Default Currency:" label-for="">
        <multiselect v-model="defaultCurrency"       
                      :options="currencyOptions"
                      :allowEmpty="false">
        </multiselect>
      </b-form-group>
      <b-form-group>
        <b-form-checkbox id="run-analysis"
          v-model="runHazardAnalysis">
          Run CEDE hazard analysis
        </b-form-checkbox>
      </b-form-group>
    </b-form> 
  </b-modal>
</template>
<script>

import axios from 'axios';
import { validationMixin } from 'vuelidate'
import { required, alphaNum } from "vuelidate/lib/validators";
import { mapState } from 'vuex';
import Multiselect from 'vue-multiselect';

export default {
  name: 'TaskItemModal',
  mixins: [validationMixin],
  components: {
    Multiselect
  },
  data() {
    return {
      accountName: '',
      programRef: '',
      dataFileLocation: '',
      summary: '',
      runHazardAnalysis: true,
      defaultCurrency: 'USD'
    };
  },
  validations: {
    accountName: { required },
    programRef: { required, alphaNum },
    dataFileLocation: { required },
    summary: { required },
  },
  computed: {    
    ...mapState('auth', {
        user: s => s.user
    }),
    ...mapState('pricing', {
      exchangeRates: s => s.exchangeRates
    }),
    currencyOptions() {
      return this.exchangeRates.map(x => x.currency).sort();
    }
  },
  methods: {
    resetModal() {
      this.accountName = '';
      this.programRef = '';
      this.dataFileLocation = '';
      this.summary = '';
      this.$nextTick(() => { this.$v.$reset() });
    },
    handleOk(bvModalEvt) {
      bvModalEvt.preventDefault();

      this.$v.$touch();
      if (this.$v.$invalid) {
          return;
      }

      this.submit();
    },
    submit() {
       axios.post(config.kickStartLogicAppEndpoint,
        {
          accountName: this.accountName,
          programRef: this.programRef,
          dataFileLocation: this.dataFileLocation,
          summary: this.summary,
          createBy: this.user.userName,
          runCedeHazardAnalysis: this.runHazardAnalysis,
          defaultCurrency: this.defaultCurrency
        }
      );

      this.$nextTick(() => {
        this.$refs.analysisModal.hide();
      });
    }
  }
};
</script>
