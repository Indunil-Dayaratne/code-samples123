export default {
    details: () => import('@/components/analysis/Detail.vue'),
    files: () => import('@/components/analysis/files/Files.vue'),
    tasks: () =>  import('@/views/tasks/Backlog'),
    pricing: () => import('../components/analysis/pricing/Pricing.vue'),
    layers: () => import('@/components/analysis/pricing/layers/LayersPageComponent.vue'),
    views: () => import('@/components/analysis/pricing/loss views/LossViewPageComponent.vue'),
    networks: () => import('@/components/analysis/pricing/networks/NetworkSelectionComponent.vue'),
    losses: () => import('@/components/analysis/pricing/lossSets/LossSetPageComponent.vue'),
    fx: () => import('../components/analysis/pricing/rates/ExchangeRateUploadComponent.vue'),
    source: () => import('../components/analysis/Source.vue'),
    rdm: () => import('@/components/analysis/Rdm/RdmFileSelector.vue'),
    clf: () => import('@/components/analysis/Clf/ClfFileSelector.vue'),
    cedeExp: () => import('@/components/analysis/CedeExp/CedeExpFileSelector.vue'),
    cedeRes: () => import('@/components/analysis/CedeRes/CedeResFileSelector.vue'),
    results: () => import('../components/analysis/pricing/Results.vue'),
    stc: () => import('@/components/analysis/pricing/results/StochasticResultsComponent.vue'),
    det: () => import('@/components/analysis/pricing/results/DeterministicResultsComponent.vue')
}