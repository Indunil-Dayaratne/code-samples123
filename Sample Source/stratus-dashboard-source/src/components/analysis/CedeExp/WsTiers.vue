<template>
  <b-table striped hover small responsive show-empty bordered
            :items="tableData"
            :fields="fields">

    <template v-slot:cell(Tier1)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Tier2)="data">
      <span>{{ (data.value / 1000000) | toNumber }} </span>
    </template>

    <template v-slot:cell(Tier3)="data">
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
          { key: 'Tier1', label: 'Tier 1 ($m)', tdClass: 'text-right', thClass: 'text-center'},
          { key: 'Tier2', label: 'Tier 2 ($m)', tdClass: 'text-right', thClass: 'text-center'},
          { key: 'Tier3', label: 'Tier 3 ($m)', tdClass: 'text-right', thClass: 'text-center'}
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
                const { State: key, Tier1, Tier2, Tier3 } = item;
                const prev = map.get(key);

                if (prev) {
                  prev.Tier1 += Tier1;
                  prev.Tier2 += Tier2;
                  prev.Tier3 += Tier3;
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