<template>
    <b-modal id="elt-dependencies" title="ELT conversion dependencies" size="xl" 
	:ok-only="true" >
		<b-row>
			<b-col>
				<b-card-group deck>
					<b-card class="d-flex">
						<template v-slot:header>
							<h5 class="mt-1">Upload simulation set</h5>
						</template>
						<b-row style="height: 100%">
							<b-col md="12">
								<b-form-group id="upload-server"
									label="Server:"
									label-for="server-input">
									<b-form-input id="server-input" v-model="uploadForm.server"
										:state="!$v.uploadForm.server.$dirty ? null : !$v.uploadForm.server.$invalid"
										@blur="$v.uploadForm.server.$touch()">
									</b-form-input>
								</b-form-group>
								<b-form-group id="upload-db"
									label="Database:"
									label-for="db-input">
									<b-form-input id="db-input" v-model="uploadForm.database"
										:state="!$v.uploadForm.database.$dirty ? null : !$v.uploadForm.database.$invalid"
										@blur="$v.uploadForm.database.$touch()">
									</b-form-input>
								</b-form-group>
								<b-form-group id="upload-tbl"
									label="Table:"
									label-for="tbl-input">
									<b-form-input id="tbl-input" v-model="uploadForm.table"
										:state="!$v.uploadForm.table.$dirty ? null : !$v.uploadForm.table.$invalid"
										@blur="$v.uploadForm.table.$touch()">
									</b-form-input>
								</b-form-group>
							</b-col>
							<b-col md="12" align-self="end" class="d-flex flex-row-reverse">
								<b-button variant="primary" :disabled="$v.uploadForm.$invalid"
									@click="onUploadClick">
									Upload
									<b-spinner small v-if="spinners.upload" variant="light"></b-spinner>
								</b-button>
							</b-col>
						</b-row>
					</b-card>
					<b-card v-if="showGenerateSimSet">
						<template v-slot:header>
							<h5 class="mt-1">Generate simulation set</h5>
						</template>
						<b-row style="height: 100%">
							<b-col md="12">
								<b-form-group id="gen-name"
									label="Name:"
									label-for="gen-name-input">
									<b-form-input id="gen-sims-input" 
										v-model="generateForm.name" 
										:state="!$v.generateForm.name.$dirty ? null : !$v.generateForm.name.$invalid"
										@blur="$v.generateForm.name.$touch()">
									</b-form-input>
								</b-form-group>
								<b-form-group
									id="event-set-elt-conversion"
									label="Event set:"
									label-for="event-set-elt-select">
									<b-select id="event-set-elt-select"
										v-model="$v.generateForm.eventSet.$model"
										:options="eventSets"
										:state="!$v.generateForm.eventSet.$dirty ? null : !$v.generateForm.eventSet.$invalid">
									</b-select>
								</b-form-group>
								<b-form-group id="gen-sims"
									label="No. of simulations:"
									label-for="gen-sims-input">
									<b-form-input id="gen-sims-input" 
										v-model="generateForm.sims" 
										type="number" min=0 max=100000 step=1000
										:state="!$v.generateForm.sims.$dirty ? null : !$v.generateForm.sims.$invalid"
										@blur="$v.generateForm.sims.$touch()">
									</b-form-input>
								</b-form-group>
								<b-form-group id="gen-seed"
									label="Seed:"
									label-for="gen-seed-input"
									description="The seed determines the start point of the pseudo-random number generation. 
										i.e. if the same seed is given (and the same number of simulations and event set), the same 
										simulation set will be generated.">
									<b-form-input id="gen-seed-input" 
										v-model="generateForm.seed" 
										type="number"
										:state="!$v.generateForm.seed.$dirty ? null : !$v.generateForm.seed.$invalid"
										@blur="$v.generateForm.seed.$touch()">
									</b-form-input>
								</b-form-group>
							</b-col>
							<b-col md="12" align-self="end" class="d-flex flex-row-reverse">
								<b-button variant="primary" :disabled="$v.generateForm.$invalid" @click="onGenerateClick">
									Generate
									<b-spinner small v-if="spinners.generate" variant="light"></b-spinner>
								</b-button>
							</b-col>
						</b-row>
						
					</b-card>
					<b-card class="d-flex" v-if="showRefreshDayDistributions">
						<template v-slot:header>
							<h5 class="mt-1">Refresh day distributions</h5>
						</template>
						<b-row style="height: 100%">
							<b-col style="height: 100%">
								<b-row style="height: 100%">
									<b-col md="12">
										<p>
											As part of the simulation set generation process, 
											we simulate a day of year for an event. This is a random
											draw from the days of the year for events for the given model
											within the Touchstone event catalog.
										</p>
										<p>
											This will update the day distributions for each model based off
											those defined in <code>[SQLTCHDBS01T].[StratusTools].[elt].[DayDistributions]</code>
											table.
										</p>
									</b-col>
									<b-col align-self="end">
										<b-button block variant="primary" @click="onRefreshClick">
											Refresh
											<b-spinner small v-if="spinners.refresh" variant="light"></b-spinner>
										</b-button>
									</b-col>
								</b-row>
							</b-col>
						</b-row>
					</b-card>
				</b-card-group>
			</b-col>
		</b-row>
    </b-modal>
</template>

<script>
import {mapState, mapGetters} from 'vuex';
import Multiselect from 'vue-multiselect';
import {required} from 'vuelidate/lib/validators';

    export default {
		name: "EltDependencyModal",
		components: {
			Multiselect
		},
		data() {
			return {
				uploadForm: {
					server: 'SQLTCHDBS01T',
					database: '',
					table: ''
				},
				generateForm: {
					name: "",
					eventSet: null,
					sims: 10000,
					seed: 0
				},
				spinners: {
					upload: false,
					generate: false,
					refresh: false
				},
				showGenerateSimSet: false,
				showRefreshDayDistributions: false
			}
		},
		validations: {
			uploadForm: {
				server: {required},
				database: {required},
				table: {required}
			},
			generateForm: {
				name: {required},
				eventSet: {required},
				sims: {required},
				seed: {required}
			}
		},
		computed: {
			...mapGetters({
				eventSets: 'elt/eventSets'
			})
		},
		methods: {
			onUploadClick() {
				this.$v.uploadForm.$touch();
				this.$store.dispatch('elt/uploadSimulationSet', this.uploadForm);
				this.manageButtonClick('upload');
			},
			onGenerateClick() {
				this.$v.generateForm.$touch();
				this.generateForm.sims = Number(this.generateForm.sims);
				this.generateForm.seed = Number(this.generateForm.seed);
				this.$store.dispatch('elt/generateSimulationSet', this.generateForm);
				this.manageButtonClick('generate');
			},
			onRefreshClick() {
				this.$store.dispatch('elt/refreshDayDistributions');
				this.manageButtonClick('refresh');
			},
			manageButtonClick(button) {
				let self = this;
				this.spinners[button] = true;
				setTimeout(() => {
					self.spinners[button] = false;
					self.$bvModal.hide('elt-dependencies');
					self.reset();
				}, 1000);
			},
			reset() {
				this.uploadForm = {
					server: 'SQLTCHDBS01T',
					database: '',
					table: ''
				};

				this.generateForm = {
					name: "",
					eventSet: null,
					sims: 10000,
					seed: 0
				}
			}
		}
    }
</script>

<style lang="scss" scoped>

</style>