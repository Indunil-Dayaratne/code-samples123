<template>
  <b-modal :id="modalId" ok-only :title="title" size="xl">

    <b-card header="ANALYSIS DETAILS" header-bg-variant="info" no-body>
      <b-row class="m-2">
        <b-col sm="2"><label for="analysisName" class="col-form-label col-form-label-sm">Analysis Name:</label></b-col>
        <b-col sm="10"> <b-input id="analysisName" v-model="analysis.Name" size="sm" disabled /></b-col>
      </b-row>

      <b-row class="m-2">
        <b-col sm="2"><label for="description" class="col-form-label col-form-label-sm">Description:</label></b-col>
        <b-col sm="10"> <b-input id="description" v-model="analysis.Description" size="sm" disabled /></b-col>
      </b-row>

      <b-row class="m-2">
        <b-col sm="2"><label for="type" class="col-form-label col-form-label-sm">Type:</label></b-col>
        <b-col sm="2"> <b-input id="type" v-model="analysis.Type" size="sm" disabled /></b-col>

        <b-col sm="2"><label for="status" class="col-form-label col-form-label-sm">Status:</label></b-col>
        <b-col sm="2"> <b-input id="status" v-model="analysis.Status" size="sm" disabled /></b-col>

        <b-col sm="2"><label for="mode" class="col-form-label col-form-label-sm">Mode:</label></b-col>
        <b-col sm="2"> <b-input id="mode" v-model="analysis.Mode" size="sm" disabled /></b-col>
      </b-row>

      <b-row class="m-2">
        <b-col sm="2"><label for="groupType" class="col-form-label col-form-label-sm">Status:</label></b-col>
        <b-col sm="2"> <b-input id="groupType" v-model="analysis.GroupType" size="sm" disabled /></b-col>

        <b-col sm="2"><label for="groupId" class="col-form-label col-form-label-sm">Group ID:</label></b-col>
        <b-col sm="2"> <b-input id="groupId" v-model="analysis.GroupID" size="sm" disabled /></b-col>

        <b-col sm="4"><b-checkbox class="float-right" id="isGroup" v-model="analysis.IsGroup" name="isGroup" disabled>Is Group</b-checkbox></b-col>
      </b-row>

      <b-row class="m-2">
        <b-col sm="2"><label for="exposureType" class="col-form-label col-form-label-sm">Exposure Type:</label></b-col>
        <b-col sm="2"> <b-input id="exposureType" v-model="analysis.ExposureType" size="sm" disabled /></b-col>

        <b-col sm="2"><label for="eventTypeFilter" class="col-form-label col-form-label-sm">Event Type Filter:</label></b-col>
        <b-col sm="2"> <b-input id="eventTypeFilter" v-model="analysis.EventTypeFilter" size="sm" disabled /></b-col>

        <b-col sm="2"><label for="scaleFactor" class="col-form-label col-form-label-sm">Scale Factor:</label></b-col>
        <b-col sm="2"> <b-input id="scaleFactor" v-model="analysis.ScaleFactor" size="sm" disabled /></b-col>
      </b-row>

      <b-row class="m-2">
        <b-col sm="2"><label for="engineVersion" class="col-form-label col-form-label-sm">Engine Version:</label></b-col>
        <b-col sm="2"> <b-input id="engineVersion" v-model="analysis.EngineVersion" size="sm" disabled /></b-col>

        <b-col sm="2"><label for="enginType" class="col-form-label col-form-label-sm">Engine Type:</label></b-col>
        <b-col sm="2"> <b-input id="enginType" v-model="analysis.EnginType" size="sm" disabled /></b-col>

        <b-col sm="2"><label for="analysisRunDate" class="col-form-label col-form-label-sm">Analysis Run Date:</label></b-col>
        <b-col sm="2"> <b-input id="analysisRunDate" v-model="analysis.AnalysisRunDate" size="sm" disabled /></b-col>
      </b-row>
    </b-card>

    <b-card header="PERIL DETAILS" header-bg-variant="info" no-body>
      <b-row class="m-2">
        <b-col sm="2"><label for="peril" class="col-form-label col-form-label-sm">Peril:</label></b-col>
        <b-col sm="4"> <b-input id="peril" v-model="analysis.Peril" size="sm" disabled /></b-col>

        <b-col sm="2"><label for="subPeril" class="col-form-label col-form-label-sm">Sub Peril:</label></b-col>
        <b-col sm="4"> <b-input id="subPeril" v-model="analysis.SubPeril" size="sm" disabled /></b-col>
      </b-row>

      <b-row class="m-2">
        <b-col sm="2"><label for="region" class="col-form-label col-form-label-sm">Region:</label></b-col>
        <b-col sm="4"> <b-input id="region" v-model="analysis.Region" size="sm" disabled /></b-col>

        <b-col sm="2"><label for="lossAmplification" class="col-form-label col-form-label-sm">Loss Amplification:</label></b-col>
        <b-col sm="4"> <b-input id="lossAmplification" v-model="analysis.LossAmplification" size="sm" disabled /></b-col>
      </b-row>


      <b-row class="m-2">
        <b-col sm="2"><label for="invalidConstOccIncluded" class="col-form-label col-form-label-sm">Invalid Const/Occ Included:</label></b-col>
        <b-col sm="4"> <b-input id="invalidConstOccIncluded" v-model="analysis.InvalidConstOccIncluded" size="sm" disabled /></b-col>
      </b-row>
    </b-card>

    <b-card header="IMPORT DETAILS" header-bg-variant="info" no-body>
      <b-row class="m-2">
        <b-col sm="2"><label for="perspectiveCode" class="col-form-label col-form-label-sm">Perspective:</label></b-col>
        <b-col sm="2"><b-select v-model="analysis.PerspectiveCode" :options="perspectives" :disabled="disabled" /></b-col>

        <b-col sm="2"><label for="userField1" class="col-form-label col-form-label-sm">User Field 1:</label></b-col>
        <b-col sm="2"> <b-input id="userField1" v-model="analysis.UserField1" size="sm" :maxlength="maxfieldLength" :disabled="disabled" /></b-col>

        <b-col sm="2"><label for="userField2" class="col-form-label col-form-label-sm">User Field 2:</label></b-col>
        <b-col sm="2"> <b-input id="userField2" v-model="analysis.UserField2" size="sm" :maxlength="maxfieldLength" :disabled="disabled" /></b-col>
      </b-row>
    </b-card>

    <b-card header="RATE SCHEMES" header-bg-variant="info" no-body>
      <b-col class="mt-2">
        <b-table hover small bordered show-empty :fields="schemeFields" :items="analysis.RateSchemes" />
      </b-col>
    </b-card>

    <b-card  header="AALs" header-bg-variant="info" no-body>
      <b-row class="m-2">
        <b-col sm="3"><label for="currency" class="col-form-label col-form-label-sm">Currency:</label></b-col>
        <b-col sm="3"> <b-input id="currency" v-model="analysis.Currency" size="sm" disabled class="text-right" /></b-col>

        <b-col sm="3"><label for="gr" class="col-form-label col-form-label-sm">GR (Gross Loss):</label></b-col>
        <b-col sm="3"> <b-input id="gr" v-model="analysis.GR_GrossLoss" size="sm" disabled class="text-right" /></b-col>
      </b-row>

      <b-row class="m-2">
        <b-col sm="3"><label for="rl" class="col-form-label col-form-label-sm">RL (Net Loss Pre Cat):</label></b-col>
        <b-col sm="3"> <b-input id="rl" v-model="analysis.RL_NetLossPreCat" size="sm" disabled class="text-right" /></b-col>

        <b-col sm="3"><label for="rc" class="col-form-label col-form-label-sm">RC (Net Loss Post Corporate Cat):</label></b-col>
        <b-col sm="3"> <b-input id="rc" v-model="analysis.RC_NetLossPostCorporateCat" size="sm" disabled class="text-right" /></b-col>
      </b-row>

      <b-row class="m-2">
        <b-col sm="3"><label for="rp" class="col-form-label col-form-label-sm">RP (Net Loss Post Cat):</label></b-col>
        <b-col sm="3"> <b-input id="rp" v-model="analysis.RP_NetLossPostCat" size="sm" disabled class="text-right" /></b-col>

        <b-col sm="3"><label for="rg" class="col-form-label col-form-label-sm">RG (Reinsurance Gross Loss):</label></b-col>
        <b-col sm="3"> <b-input id="rg" v-model="analysis.RG_ReinsuranceGrossLoss" size="sm" disabled class="text-right" /></b-col>
      </b-row>
    </b-card>

    <b-card header="TREATIES"  header-bg-variant="info" no-body>
      <b-col>
        <b-table class="mt-2" hover small bordered show-empty :fields="treatyFields" :items="analysis.Treaties" responsive>

          <template v-slot:cell(OccurenceLimit)="data">
            <span>{{ data.value | toNumber}}</span>
          </template>

          <template v-slot:cell(AttachmentPoint)="data">
            <span>{{ data.value | toNumber}}</span>
          </template>

          <template v-slot:cell(RiskLimit)="data">
            <span>{{ data.value | toNumber}}</span>
          </template>

          <template v-slot:cell(InceptionDate)="data">
            <span> {{ data.value | moment(dateFormat) }} </span>
          </template>

          <template v-slot:cell(ExpiryDate)="data">
            <span> {{ data.value | moment(dateFormat) }} </span>
          </template>

          <template v-slot:cell(Premium)="data">
            <span>{{ data.value | toNumber}}</span>
          </template>
        </b-table>
      </b-col>
    </b-card>

  </b-modal>
</template>

<script>
  export default {
    name: "RdmModal",
    props: ['analysis', 'modalId', 'perspectives', 'maxfieldLength', 'disabled'],
    data() {
      return {
        schemeFields: [
          { key: 'Peril', label: 'Peril' },
          { key: 'RateScheme', label: 'Rate Scheme'}
        ],
        treatyFields: [
          { key: 'TreatyNumber', label: 'Number' },
          { key: 'TreatyName', label: 'Name' },
          { key: 'TreatyType', label: 'Type' },
          { key: 'Currency', label: 'Currency' },
          { key: 'OccurenceLimit', label: 'Occurence Limit', tdClass:'text-right'},
          { key: 'AttachmentPoint', label: 'Attachment Point', tdClass:'text-right' },
          { key: 'RiskLimit', label: 'Risk Limit', tdClass:'text-right' },
          { key: 'Retention', label: 'Retention', tdClass:'text-right' },
          { key: 'PercentageCovered', label: '% Covered', tdClass:'text-right' },
          { key: 'PercentagePlaced', label: '% Placed', tdClass:'text-right' },
          { key: 'InceptionDate', label: 'Inception', tdClass:'date text-right' },
          { key: 'ExpiryDate', label: 'Expiry', tdClass:'date text-right' },
          { key: 'PercentageRetained', label: '% Retained', tdClass:'text-right' },
          { key: 'PercentageShare', label: '% Share', tdClass:'text-right' },
          { key: 'AttachmentBasis', label: 'Attachment Basis' },
          { key: 'Priority', label: 'Priority', tdClass:'text-right' },
          { key: 'Reinstatements', label: 'Reinstatements', tdClass:'text-right' },
          { key: 'ReinstamentCharge', label: 'Reinstament Charge', tdClass:'text-right' },
          { key: 'AttachmentLevel', label: 'Attachment Level' },
          { key: 'Premium', label: 'Premium', tdClass:'text-right' },
        ]
      }
    },   
    computed: {
      title() {
        return "RDM Analysis Details for #" + this.analysis.RmsAnalysisID;
      },
      dateFormat() {
        return 'DD-MM-YYYY';
      }
    }
  }              
</script>

<style>
  .date {
    min-width: 7em;   
  }
</style>