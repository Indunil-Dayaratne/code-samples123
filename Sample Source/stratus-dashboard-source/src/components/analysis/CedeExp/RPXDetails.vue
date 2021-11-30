<template>
    <b-modal ok-only :id="modalId" title="RPX Details" size="xl">
      <multiselect v-model="clfDetail.RpxDetails" 
                  tag-placeholder="Add this as new path" 
                  placeholder="Search or add a path 'Program - FilePath" 
                  track-by="RowKey"
                  label="Label"      
                  :options="rpxs"
                  :taggable="true" 
                  @tag="addRpx"
                  :disabled="!canModify">
      </multiselect>
      <b-card header="TREATIES" header-bg-variant="primary" v-if="selectedRpx && selectedRpx.IsNew" class="mt-2">
        <p><b>RPX information will be loaded as part of the Map Perils run. Please ensure that the treaty details are correct in the file.</b></p>
      </b-card>
      <b-card header="TREATIES" header-bg-variant="primary" v-if="selectedRpx && !selectedRpx.IsNew" class="mt-2" >
          <b-table striped hover small responsive show-empty bordered
                    :items="selectedRpx.Treaties"
                    :fields="fields">

            <template v-slot:cell(ProgramName)>
              <span>{{ selectedRpx.Program }} </span>
            </template>

            <template v-slot:cell(InceptionDate)="data">
              <span>{{ data.value | moment(dateFormat) }} </span>
            </template>

            <template v-slot:cell(ExpirationDate)="data">
              <span>{{ data.value | moment(dateFormat) }} </span>
            </template>

            <template v-slot:cell(ParticipationGross)="data">
              <span>{{ (data.value * 100) }} </span>
            </template>

            <template v-slot:cell(RiskRetention)="data">
              <span>{{ data.value  | toNumber }} </span>
            </template>

            <template v-slot:cell(RiskLimit)="data">
              <span>{{ data.value  | toNumber }} </span>
            </template>

            <template v-slot:cell(OccurrenceRetention)="data">
              <span>{{ data.value  | toNumber }} </span>
            </template>

            <template v-slot:cell(OccurrenceLimit)="data">
              <span>{{ data.value  | toNumber }} </span>
            </template>

            <template v-slot:cell(AggregateRetention)="data">
              <span>{{ data.value  | toNumber }} </span>
            </template>

            <template v-slot:cell(AggregateLimit)="data">
              <span>{{ data.value  | toNumber }} </span>
            </template>

          </b-table>
      </b-card>
    </b-modal>
</template>

<script>
import draggable from "vuedraggable";
import { mapState } from 'vuex';
import Multiselect from 'vue-multiselect';

export default {
  name: "RpxDetails",
  props: ['modalId', 'programRef', 'analysisId', 'id', 'clfDetail', 'canModify'],
  components: {
    Multiselect
  },
  data() {
    return {
      options: null,
      dateFormat: "DD-MM-YYYY",
      fields: [
        { key: "ProgramName", label: "Program"},
        { key: 'InceptionDate', label: 'Inception', tdClass:'date text-right' },
        { key: 'ExpirationDate', label: "Expiry", tdClass:'date text-right'},        
        { key: "CurrencyCode", label: "Currency"},  
        { key: "ParticipationGross", label: "Participation Gross", tdClass:'text-right'},        
        { key: "RiskRetention", label: "Risk Retention", tdClass:'text-right'},
        { key: "RiskLimit", label: "Risk Limit", tdClass:'text-right'},   
        { key: "OccurrenceRetention", label: "Occurrence Retention", tdClass:'text-right'},     
        { key: "OccurrenceLimit", label: "Occurrence Limit", tdClass:'text-right'},
        { key: "AggregateRetention", label: "Aggregate Retention", tdClass:'text-right'},     
        { key: "AggregateLimit", label: "Aggregate Limit", tdClass:'text-right'},  
        { key: 'TreatyTypeCode', label: "Treaty Type"},
        { key: 'TriggerTypeCode', label: "Trigger Type"}
      ],
    }
  },
  methods: {
    addRpx(newRpx) {
      var a = newRpx.split("-");

      if (a.length !== 2) {
          this.$bvToast.toast("Please enter the RPX details as 'Program - filepath'", {
            title: 'ERROR: Cannot add RPX',
            toaster: 'b-toaster-top-center',
            autoHideDelay: 3000,
            variant: "danger"
        });
          return;
      }

      const rpx = {
        FilePath: a[1].trim(),
        Label: newRpx,
        Program: a[0].trim(),
        Source: "MANUAL",
        IsNew: true,
        Treaties: [],
        PartitionKey: "",
        RowKey: ""        
      }
       this.$store.dispatch('account/act', {action: 'files/cedeExp/updateRpxs', data: rpx });      
    }
  },
  computed: {
    ...mapState( {
      rpxs: (state, get) => get['account/get']('files/cedeExp/dataItem')('rpxs')
    }),    
    selectedRpx() {     
      return this.rpxs.filter(x => x.FilePath === (this.clfDetail.RpxDetails ? this.clfDetail.RpxDetails.FilePath : ""))[0]
    }
  }
}
</script>