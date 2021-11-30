<template>
  <b-modal 
      id="new-program-modal"
      ref="newProgramModal"
      centered title="New Program Request" 
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
          Program reference is required, must be alpha numeric and 6 characters long only
        </b-form-invalid-feedback>
      </b-form-group>
      <b-form-group label="Summary:" label-for="txtSummary">
        <b-form-textarea id="txtSummary"
                      v-model="summary"
                      placeholder="Enter Summary"
                      :state="$v.summary.$dirty ? !$v.summary.$error : null"
                      aria-describedby="summary-feedback"
                      rows="3"
                      max-rows="5"/>

        <b-form-invalid-feedback id="summary-feedback">
          Summary is required
        </b-form-invalid-feedback>
      </b-form-group>
      <b-form-group label="Default Currency:" label-for="">
        <multiselect v-model="defaultCurrency"       
                      :options="currencyOptions"
                      :allowEmpty="false">
        </multiselect>
      </b-form-group>
    </b-form> 
  </b-modal>
</template>
<script>

import axios from 'axios';
import { validationMixin } from 'vuelidate'
import { required, minLength, maxLength, alphaNum } from "vuelidate/lib/validators";
import { mapState } from 'vuex';
import Multiselect from 'vue-multiselect';
import { ACCOUNT_TYPES } from '../../shared/types';
import stratusApi from '../../shared/api';

export default {
  name: 'NewProgramModal',
  mixins: [validationMixin],
  components: {
    Multiselect
  },
  data() {
    return {
      accountName: '',
      programRef: '',
      summary: '',
      defaultCurrency: 'USD'
    };
  },
  validations: {
    accountName: { required },
    programRef: { required, alphaNum, minLength: minLength(6), maxLength: maxLength(6) },
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
       stratusApi.createProgram({
          accountName: this.accountName,
          programRef: this.programRef,
          summary: this.summary,
          userName: this.user.userName,
          defaultCurrency: this.defaultCurrency
      }).then(() => this.$store.dispatch('program/getPrograms'), (reason) => console.error(reason));

      this.$nextTick(() => {
        this.$refs.newProgramModal.hide();
      });
    }
  }
};
</script>
