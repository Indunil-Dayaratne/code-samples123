<template>    
  <b-table striped hover small responsive show-empty bordered
           :items="tableData"
           :fields="fields">

    <template v-slot:cell(Tiv)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Feet0To500)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Feet500To1000)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Feet1000To1500)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Feet1500To2000)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Feet2000To2500)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Feet2500To1Mile)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Mile1To2)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Mile2To3)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Mile3To4)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Mile4To5)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Mile5To10)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Mile10To15)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Mile15To20)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Mile20To25)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Mile25To50)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(MileMoreThan50)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

  </b-table>
</template>

<script>
  export default {
    props: ['items', 'selectedExposureDatabaseSID', 'selectedExposureSetSID'],
    data() {
      return {
        combined: [],
        fields: [
          { key: 'State', label: 'State' },
          { key: 'Tiv', label: 'TIV', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'Feet0To500', label: '0 - 500 feet', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'Feet500To1000', label: '500 - 1000 feet', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'Feet1000To1500', label: '1000 - 1500 feet', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'Feet1500To2000', label: '1500 - 2000 feet', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'Feet2000To2500', label: '2000 - 2500 feet', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'Feet2500To1Mile', label: '2500 feet - 1 mile', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'Mile1To2', label: '1 - 2 miles', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'Mile2To3', label: '2 - 3 miles', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'Mile3To4', label: '3 - 4 miles', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'Mile4To5', label: '4 - 5 miles', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'Mile5To10', label: '5 - 10 miles', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'Mile10To15', label: '10 - 15 miles', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'Mile15To20', label: '15 - 20 miles', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'Mile20To25', label: '20 - 25 miles', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'Mile25To50', label: '25 - 50 miles', tdClass: 'text-right', thClass: 'text-center' },
          { key: 'MileMoreThan50', label: '> 50 miles', tdClass: 'text-right', thClass: 'text-center'}
        ]
      };
    },
    mounted() {
      this.setCombined();    
    },
    methods: {
      setCombined() {
        var cedeIds = [...new Set(this.items.map(item => item.ExposureDatabaseSID))];
        var self = this;
        this.combined.push(...this.items);

        cedeIds.forEach(function (cedeId) {
          var filtered = JSON.parse(JSON.stringify(self.items.filter(x => x.ExposureDatabaseSID === cedeId)));

            self.combined.push(...[...filtered.reduce(
              (map, item) => {
                const { State: key, Tiv,
                  Feet0To500,
                  Feet500To1000,
                  Feet1000To1500,
                  Feet1500To2000,
                  Feet2000To2500,
                  Feet2500To1Mile,
                  Mile1To2,
                  Mile2To3,
                  Mile3To4,
                  Mile4To5,
                  Mile5To10,
                  Mile10To15,
                  Mile15To20,
                  Mile20To25,
                  Mile25To50,
                  MileMoreThan50
                } = item;

                const prev = map.get(key);

                if (prev) {
                  prev.Tiv += Tiv;
                  prev.Feet0To500 += Feet0To500;
                  prev.Feet500To1000 += Feet500To1000;
                  prev.Feet1000To1500 += Feet1000To1500;
                  prev.Feet1500To2000 += Feet1500To2000;
                  prev.Feet2000To2500 += Feet2000To2500;
                  prev.Feet2500To1Mile += Feet2500To1Mile;
                  prev.Mile1To2 += Mile1To2;
                  prev.Mile2To3 += Mile2To3;
                  prev.Mile3To4 += Mile3To4;
                  prev.Mile4To5 += Mile4To5;
                  prev.Mile5To10 += Mile5To10;
                  prev.Mile10To15 += Mile10To15;
                  prev.Mile15To20 += Mile15To20;
                  prev.Mile20To25 += Mile20To25;
                  prev.Mile25To50 += Mile25To50;
                  prev.MileMoreThan50 += MileMoreThan50;
                } else {
                  item.ExposureSetSID = 0;
                  item.ExposureSetName = 'All';
                  map.set(key, Object.assign({}, item))
                }

                return map
              },
              new Map()
            ).values()
            ]);
        });
      }
    },
    computed: {
      tableData() {
        return this.combined.filter(x => x.ExposureDatabaseSID === this.selectedExposureDatabaseSID && x.ExposureSetSID === this.selectedExposureSetSID);
      }
    }
  }
</script>