<template>
  <b-modal :id="modalId" ok-only title="Clf Details" size="xl">

    <b-card header="SUMMARY" header-bg-variant="info" no-body >
      <b-row class="m-2">
        <b-col sm="2"><label class="col-form-label col-form-label-sm">Company:</label></b-col>
        <b-col sm="4"> <b-input v-model="clfDetail.Company" size="sm" disabled /></b-col>

        <b-col sm="2"><label class="col-form-label col-form-label-sm">Program:</label></b-col>
        <b-col sm="4"> <b-input v-model="clfDetail.Program" size="sm" disabled /></b-col>
      </b-row>

      <b-row class="m-2">
        <b-col sm="2"><label class="col-form-label col-form-label-sm">Loss Catalogue:</label></b-col>
        <b-col sm="4"> <b-input v-model="clfDetail.LossCatalogue" size="sm" disabled /></b-col>

        <b-col sm="2"><label class="col-form-label col-form-label-sm">Event Set:</label></b-col>
        <b-col sm="4"> <b-input v-model="clfDetail.EventSet" size="sm" disabled /></b-col>
      </b-row>

      <b-row class="m-2">
        <b-col sm="2"><label class="col-form-label col-form-label-sm">Line of business:</label></b-col>
        <b-col sm="4"> <b-input v-model="clfDetail.LineOfBusiness" size="sm" disabled /></b-col>
      </b-row>

      <b-row class="m-2">
        <b-col sm="2"><label class="col-form-label col-form-label-sm">Base Name:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail.CLFBaseName" size="sm" disabled /></b-col>

        <b-col sm="2"><label class="col-form-label col-form-label-sm">Date Created:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail.DateCLFCreated" size="sm" disabled /></b-col>

        <b-col sm="2"><label class="col-form-label col-form-label-sm">Date Installed:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail.DateCLFInstalled" size="sm" disabled /></b-col>
      </b-row>

      <b-row class="m-2">
        <b-col sm="2"><label class="col-form-label col-form-label-sm">CLF Version:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail.CLFVersion" size="sm" disabled /></b-col>

        <b-col sm="2"><label class="col-form-label col-form-label-sm">ILF Version:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail.ILFVersion" size="sm" disabled /></b-col>

        <b-col sm="2"><label class="col-form-label col-form-label-sm">Versions Matches:</label></b-col>
        <b-col sm="2"><b-checkbox v-model="clfDetail.MatchesCurrentVersion" size="sm" disabled /></b-col>
      </b-row>

      <b-row class="m-2">
        <b-col sm="2"><label class="col-form-label col-form-label-sm">CLF Model Version:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail.CLFModelVersion" size="sm" disabled /></b-col>

        <b-col sm="2"><label class="col-form-label col-form-label-sm">ILF Model Version:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail.ILFModelVersion" size="sm" disabled /></b-col>

        <b-col sm="2"><label class="col-form-label col-form-label-sm">Model:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail.Model" size="sm" disabled /></b-col>
      </b-row>

      <b-row class="m-2">
        <b-col sm="2"><label class="col-form-label col-form-label-sm">Loss File Extension:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail.LossFileExtension" size="sm" disabled /></b-col>

        <b-col sm="2"><label class="col-form-label col-form-label-sm">Loss File Type:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail.LossFileType" size="sm" disabled /></b-col>

        <b-col sm="2"><label class="col-form-label col-form-label-sm">Demand Surge:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail.DemandSurge" size="sm" disabled /></b-col>       
      </b-row>

      <b-row class="m-2">
        <b-col sm="2"><label class="col-form-label col-form-label-sm">Stochastic Loss File:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail.StochasticLossFile" size="sm" disabled /></b-col>

        <b-col sm="2"><label class="col-form-label col-form-label-sm">Historical Loss File:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail.HistoricalLossFile" size="sm" disabled /></b-col>

        <b-col sm="2"><label class="col-form-label col-form-label-sm">RDS Loss File:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail.RDSLossFile" size="sm" disabled /></b-col>
      </b-row>

      <b-row class="m-2">
        <b-col sm="2"><label class="col-form-label col-form-label-sm">Sub Perils:</label></b-col>
        <b-col sm="2"><b-select :options="clfDetail.SubPerils" :select-size="4"></b-select></b-col>

        <b-col sm="2"><label class="col-form-label col-form-label-sm">Area Detail:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail. AreaDetail" size="sm" disabled /></b-col>

        <b-col sm="2"><label class="col-form-label col-form-label-sm">Loss Type:</label></b-col>
        <b-col sm="2"> <b-input v-model="clfDetail.LossType" size="sm" disabled /></b-col>
      </b-row>
    </b-card>

    <b-card header="IMPORT DETAILS" header-bg-variant="info" no-body>
      <b-row class="m-2">
        <b-col sm="2"><label for="userField1" class="col-form-label col-form-label-sm">User Field 1:</label></b-col>
        <b-col sm="4">
          <b-input id="userField1" v-model="clfDetail.SelectedValuesStd.UserField1" size="sm" disabled />
        </b-col>      

        <b-col sm="2"><label for="userField2" class="col-form-label col-form-label-sm">User Field 2:</label></b-col>
        <b-col sm="4">
          <b-input id="userField2" v-model="clfDetail.SelectedValuesStd.UserField2" size="sm" disabled />
        </b-col>     
      </b-row>

      <b-row class="m-2">
        <b-col sm="2"><label for="perspective" class="col-form-label col-form-label-sm">Perspective:</label></b-col>
        <b-col sm="4">
          <b-select id="perspective" v-model="clfDetail.SelectedValuesStd.Perspective" :options="perspectives" disabled />
        </b-col>
      </b-row>

    </b-card>

    <b-card header="AALs" header-bg-variant="info" no-body>
      <b-col>
        <b-table class="mt-2" hover small bordered show-empty :fields="aalFields" :items="clfDetail.AALs" responsive>
          <template v-slot:cell(LossAmount)="data">
            <span>{{ data.value | toNumber }} </span>
          </template>
        </b-table>
      </b-col>
    </b-card>
  </b-modal>
</template>

<script>
  export default {
    name: "ClfModal",
    props: ['clfDetail', 'modalId', 'perspectives', 'disabled'],
    data() {
      return {
         aalFields: [
          { key: 'LossType', label: 'Perspective' },
          { key: 'Peril', label: 'Peril' },
          { key: 'LossAmount', label: 'Loss Amount ($)', thClass: 'text-right', tdClass: 'text-right'  }
        ]
      }
    },
    computed: {      
      dateFormat() {
        return 'DD-MM-YYYY';
      }
    }
  }
</script>