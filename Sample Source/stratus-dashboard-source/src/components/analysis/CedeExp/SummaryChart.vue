<template>
  <div>
    <pie-chart :chartdata="pieChartData" :options="options" />
    <b-table striped hover small responsive show-empty bordered
             :items="tableData"
             :fields="fields">

      <template v-slot:cell(TotalReplacementValue)="data">
        <span>{{ (data.value / 1000000) | toNumber }} </span>
      </template>

      <template v-slot:cell(NumberOfLocations)="data">
        <span>{{ data.value | toNumber }} </span>
      </template>
      
      <template v-slot:cell(PercentageTiv)="data">
        <span>{{ (data.value * 100) | toNumber }} </span>
      </template>
    </b-table>
  </div>
</template>

<script>
  import PieChart from '@/shared/charts/PieChart';
  export default {
    components: {
      PieChart      
    },
    props: ['items', 'title', 'selectedExposureDatabaseSID', 'selectedExposureSetSID', 'selectedPerilSetCode'],
    data() {
      return {  
        combined: [],
        fields: [
          { key: 'Category', label: this.title },
          { key: 'TotalReplacementValue', label: 'TIV ($m)', thClass: 'text-right', tdClass: 'text-right' },
          { key: 'NumberOfLocations', label: 'No. of Locations', thClass: 'text-right', tdClass: 'text-right' },
          { key: 'PercentageTiv', label: 'Percentage', thClass: 'text-right', tdClass: 'text-right' }
        ],  
        loaded: false,     
        options: {
          responsive: true,
          maintainAspectRatio: true,
          legend: {
            position: 'bottom',
            fullWidth: true,
            labels: {
              boxWidth: 10,
              fontSize: 11
            }
          },
          animation: {
            animateScale: true
          },
          title: {
            display: true,
            text: this.title
          }
        }
      }
    },
    mounted() {
      this.setCombined();    
    },
    methods: {
      setCombined() {
        var cedeIds = [...new Set(this.items.map(item => item.ExposureDatabaseSID))];
        var perilCodes = [...new Set(this.items.map(item => item.PerilSetCode))];
        var self = this;
        this.combined.push(...this.items);

        cedeIds.forEach(function (cedeId) {

          perilCodes.forEach(function (perilCode) {
            var filtered = JSON.parse(JSON.stringify(self.items.filter(x => x.ExposureDatabaseSID === cedeId && x.PerilSetCode === perilCode)));
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
        });    
      }
    },
    computed: {
      tableData() {
        return this.combined.filter(x => x.ExposureDatabaseSID === this.selectedExposureDatabaseSID
          && x.ExposureSetSID === this.selectedExposureSetSID
          && x.PerilSetCode === this.selectedPerilSetCode);          
      },
      pieChartData() {
        var labels = [...new Set(this.tableData.map(item => item.Category))];
        var data = [...new Set(this.tableData.map(item => item.PercentageTiv))];

        return {
          labels: labels,
          datasets: [
            {
              backgroundColor: [...new Set(labels.map(item => this.$getRandomColor()))],
              data: data
            }
          ]
        };
      }
    }
  }
</script>