import Vue from 'vue';
import Router from 'vue-router';
import store from '../store';
import { ECHILD } from 'constants';
import VueAppInsights from "vue-app-insights";
import { ACCOUNT_TYPES } from '@/shared/types';
import pricingRouteGuards from './pricingRouteGuards'

//Containers
const DefaultContainer = () => import('@/containers/DefaultContainer')

// Views
const Backlog = () => import('@/views/tasks/Backlog.vue')
const KanbanBoard = () => import('@/views/tasks/KanbanBoard.vue')
const AnalysisIndex = () => import('@/views/analysis/Index.vue')
const Analysis = () => import('@/views/analysis/Analysis.vue')
const Program = () => import('@/views/analysis/Program.vue')
import programComponents from './programComponents';
const DataManagement = () => import('../views/analysis/DataManagement.vue');
const Status = () => import('../views/analysis/QueueStatus.vue');

// Views - Components
const AuthCallback = () => import('@/components/auth/Callback')

// Views - Pages
const Page404 = () => import('@/views/pages/Page404')
const Page500 = () => import('@/views/pages/Page500')

Vue.use(Router);

let router = new Router({
	scrollBehavior: () => ({ y: 0 }),
	routes: [
		{
			path: '/',
			redirect: '/backlog',
			name: 'Home',
			component: DefaultContainer,
			meta: () => {},
			children: [
				{
					path: 'analysis',
					redirect: '/analysis/index',
					props: true,
					component: {
						render(c) { return c('router-view') }
					},
					name: 'Analysis',
					children: [
						{
							path: 'index',
							component: AnalysisIndex,
							name: 'Index',
							meta: {
								requiresAuth: true,
								label: 'Index'
							},
							//redirect: '/program',
							props: { type: ACCOUNT_TYPES.analysis }
						},
						{
							path: ':programRef/:id/detail',
							component: Analysis,
							name: 'AnalysisDetails',
							props: true,
							meta: {
								requiresAuth: true,
								title: 'Details',
								label: 'Details'
							}
						}
					]
				},
				{
					path: 'backlog',
					component: Backlog,
					name: 'Backlog',
				},
				{
					path: 'program',
					redirect: '/program/index',
					component: {
						render(c) { return c('router-view') }
					},
					meta: {
						requiresAuth: true,
						label: 'Program'
					},
					name: 'program',
					children: [
						{
							path: 'index',
							component: AnalysisIndex,
							name: 'program_index',
							meta: {
								requiresAuth: true,
								label: 'Index',
								title: 'Index'
							},
							props: { type: ACCOUNT_TYPES.program }
						},
						{
							path: ':programRef',
							redirect: ':programRef/detail',
							props: true,
							component: Program,
							meta: {
								requiresAuth: true,
								title: 'Detail'
							},
							children: [
								{
									path: 'detail',
									name: 'program_details',
									component: programComponents.details,
									props: (route) => { return {...route.params, type: ACCOUNT_TYPES.program } },
									meta: {
										requiresAuth: true,
										label: 'Detail',
										title: 'Detail'
									}
								},
								{
									path: 'files',
									name: 'program_files',
									component: programComponents.files,
									props: true,
									meta: {
										requiresAuth: true,
										label: 'Files',
										title: 'Files'
									}
								},
								{
									path: 'tasks',
									name: 'program_tasks',
									component: programComponents.tasks,
									props: (route) => {
										return {
											taskRef: route.params.programRef
										}
									},
									meta: {
										requiresAuth: true,
										label: 'Tasks',
										title: 'Tasks'
									}
								},
								{
									path: 'source',
									component: programComponents.source,
									props: true,
									meta: {
										requiresAuth: true,
										label: 'Source',
										title: 'Source'
									},
									beforeEnter: (to, from, next) => {
										if(!store.getters['account/get']('files/areAvailable')()) next({ name: 'program_details', params: to.params, query: to.query });
										else next();
									},
									children: [
										{
											path: 'rdm',
											name: 'program_source_rdm',
											component: programComponents.rdm,
											props: true,
											meta: {
												requiresAuth: true,
												label: 'RDM',
												title: 'RDM'
											}
										},
										{
											path: 'clf',
											name: 'program_source_clf',
											component: programComponents.clf,
											props: true,
											meta: {
												requiresAuth: true,
												label: 'CLF',
												title: 'CLF'
											}
										},
										{
											path: 'cede-exp',
											name: 'program_source_cedeexp',
											component: programComponents.cedeExp,
											props: true,
											meta: {
												requiresAuth: true,
												label: 'CEDE Exposure',
												title: 'CEDE'
											}
										},
										{
											path: 'cede-res',
											name: 'program_source_cederes',
											component: programComponents.cedeRes,
											props: true,
											meta: {
												requiresAuth: true,
												label: 'CEDE Results',
												title: 'CEDE'
											}
										},
										{ path: '', redirect: 'rdm' }
									]
								},
								{
									path: 'pricing',
									component: programComponents.pricing,
									props: true,
									meta: {
										requiresAuth: true,
										label: 'Pricing',
										title: 'Pricing'
									},
									children: [
										{
											path: 'networks',
											name: 'program_pricing_networks',
											component: programComponents.networks,
											props: (route) => { return { ...route.params, useRoute: true }},
											meta: {
												requiresAuth: true,
												label: 'Networks',
												title: 'Networks'
											}
										},
										{
											path: 'losses',
											name: 'program_pricing_losses',
											component: programComponents.losses,
											props: true,
											meta: {
												requiresAuth: true,
												label: 'Loss sets',
												title: 'Loss sets'
											}
										},
										{
											path: 'layers',
											name: 'program_pricing_layers',
											component: programComponents.layers,
											props: true,
											meta: {
												requiresAuth: true,
												label: 'Layers',
												title: 'Layers'
											},
											beforeEnter: pricingRouteGuards.networkLoadedBeforeEachGuard(store, router),
										},
										{
											path: 'views',
											name: 'program_pricing_views',
											component: programComponents.views,
											props: true,
											meta: {
												requiresAuth: true,
												label: 'Views',
												title: 'Views'
											},
											beforeEnter: pricingRouteGuards.networkLoadedBeforeEachGuard(store, router),
										},
										{
											path: 'fx',
											name: 'program_pricing_fx',
											component: programComponents.fx,
											props: true,
											meta: {
												requiresAuth: true,
												label: 'FX',
												title: 'FX'
											}
										}, 
										{
											path: '', 
											redirect: 'networks',
											name: 'program_pricing'
										}
									]
								},
								{
									path: 'results',
									component: programComponents.results,
									props: true,
									meta: {
										requiresAuth: true,
										label: 'Results',
										title: 'Results'
									},
									beforeEnter: pricingRouteGuards.networkLoadedBeforeEachGuard(store, router),
									children: [
										{
											path: 'stc',
											name: 'program_res_stc',
											component: programComponents.stc,
											props: true,
											meta: {
												requiresAuth: true,
												label: 'Stochastic',
												title: 'Stochastic'
											}
										},
										{
											path: 'det',
											name: 'program_res_det',
											component: programComponents.det,
											props: true,
											meta: {
												requiresAuth: true,
												label: 'Deterministic',
												title: 'Deterministic'
											}
										},
										{ path: '', redirect: 'stc' }
									]
								}
							]
						}
					]
				},
				{
					path: '/data',
					name: 'Data',
					component: DataManagement,
					meta: {
						requiresAuth: true
					}
				},
				{
					path: '/status',
					name: 'Status',
					component: Status,
					meta: {
						requiresAuth: true
					}
				}
			]
		},
		{
			path: '/auth',
			redirect: '/auth/login',
			name: 'Auth',
			component: {
				render(c) { return c('router-view') }
			},
			children: [
				{
					path: 'callback',
					name: 'Callback',
					component: AuthCallback
				},
			]
		},
		{
			path: '/pages',
			redirect: '/pages/404',
			name: 'Pages',
			component: {
				render(c) { return c('router-view') }
			},
			children: [
				{
					path: '404',
					name: 'Page404',
					component: Page404
				},
				{
					path: '500',
					name: 'Page500',
					component: Page500
				}
			]
		},
		{
			path: '*', redirect: '/pages/404'
		}
	],
});

router.beforeEach(async (to, from, next) => {

	if (to.meta.title || to.name) {
		document.title = "Stratus - " + (to.meta.title || to.name);
	}
	else {
		document.title = "Stratus";
	}

	if (to.matched.some(record => record.meta.requiresAuth) && !store.getters['auth/isLoggedIn']) {
		await store.dispatch('auth/logIn')
		next();
		return;
	}
	
	store.dispatch('account/update', to);
	await pricingRouteGuards.beforeEach(to, router);
	next();
});

Vue.use(VueAppInsights, {
	id: config.appinsightsid,
	router
});

export default router;