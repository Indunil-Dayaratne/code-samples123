<template>
  <b-table striped hover small responsive show-empty bordered
            :items="tableData"
            :fields="fields">

    <template v-slot:cell(TIV)="data">
      <span>{{ data.value | toNumber }} </span>
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
          { key: 'CaliforniaDOIZone', label: 'DOI Zone' },
          { key: 'TotalReplacementValue', label: 'TIV', tdClass: 'text-right', thClass: 'text-center'},
          { key: 'PercentageTiv', label: 'Percentage', tdClass: 'text-right', thClass: 'text-center'}
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
            const totalTiv = filtered.reduce((prev, cur) => prev + cur.TotalReplacementValue, 0);

            self.combined.push(...[...filtered.reduce(
              (map, item) => {
                const { Category: key, TotalReplacementValue, NumberOfLocations } = item;
                const prev = map.get(key);

                if (prev) {
                  prev.TotalReplacementValue += TotalReplacementValue;
                  prev.NumberOfLocations += NumberOfLocations;
                  prev.PercentageTiv = (prev.TotalReplacementValue / totalTiv);
                } else {
                  item.PercentageTiv = (item.TotalReplacementValue / totalTiv);
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
         return this.combined.filter(x => x.ExposureDatabaseSID === this.selectedExposureDatabaseSID
          && x.ExposureSetSID === this.selectedExposureSetSID);   
      }
    }
  }
</script>