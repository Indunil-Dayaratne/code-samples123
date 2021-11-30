import Vue from 'vue';
import azure from 'azure-storage';
import AzureStorageUtils from '../../../../../shared/azure-storage-utils';

function getDisplayUserLob(state, lob) {
    switch (lob) {
        case '':
            return state.blankMappingPlaceholder;

        case null:
            return state.nullMappingPlaceholder;

        default:
            return lob;
    }
}

function getLobFromDisplayValue(state, display) {
    switch (display) {
        case state.blankMappingPlaceholder:
            return '';

        case state.nullMappingPlaceholder:
            return null;

        default:
            return display;
    }
}

function getLobRowKey(lob) {
    //remove invalid key characters
    const reg = new RegExp(/[/\\?#\t\n\r]/gm);
    return lob.replace(reg, (s) => {
        switch (s) {
            case '/':
                return ':-0';
            case '\\':
                return ':-1';
            case '?':
                return ':-2';
            case '#':
                return ':-3';
            default:
                return '';
        }
    })
}

const exposureTableName = config.appPrefix + 'ExposureSummary';
const rpxTableName = config.appPrefix + 'Rpx';
const mappingsTableName = config.appPrefix + 'LobMappings';

const state = {
    exposureSummary: [],
    geoLevels: [],
    constructions: [],
    occupancies: [],
    perils: [],
    stories: [],
    subAreas: [],
    wsTiers: [],
    yearBuilts: [],
    carlifoniaEQZones: [],
    distanceToCoast: [],
    lobs: [],
    rpxs: [],
    runCatalogTypes: [
        { value: 1, text: "WSST with Demand Surge", code: "WsstWithDemandSurge" },
        { value: 2, text: "WSST without Demand Surge", code: "WsstWithoutDemandSurge" },
        { value: 3, text: "STD with Demand Surge", code: "StdWithDemandSurge" },
        { value: 4, text: "STD without Demand Surge", code: "StdWithoutDemandSurge" },
    ],
    britLobOptions: [
        'All',
        'Residential',
        'Other'
    ],
    savedLobMappings: {},
    blankMappingPlaceholder: '(blank)',
    nullMappingPlaceholder: '(null)'
};

const getters = {
    dataItem: (state) => (itemKey) => {
        return state[itemKey];
    },
    getRunCatalogFromId: (state) => (id) => {
        return state.runCatalogTypes.filter(x => x.value === id)[0];
    },
    getMappedLobs(state) {
        return state.lobs.map(x => {
            let savedMapping = state.savedLobMappings[x.userLob];
            if (savedMapping) {
                x.savedMapping = savedMapping.britLob;
                x.britLob = x.britLob || savedMapping.britLob;
            }
            return x;
        }).sort((a, b) => {
            if(a.userLob > b.userLob) return 1;
            if(a.userLob < b.userLob) return -1;
            return 0;
        })
    },
    allLobsMappingSaved(state, getters) {
        return getters.getMappedLobs.every(x => !!x.savedMapping);
    }
};

const mutations = {
    setExposureSummary: (state, { list }) => {
        state.exposureSummary = [];
        list.forEach((entity) => {
            state.exposureSummary.push({
                PartitionKey: entity.PartitionKey._,
                RowKey: entity.RowKey._,
                GeocodingLevels: JSON.parse(entity.GeocodingLevels._),
                Constructions: JSON.parse(entity.Constructions._),
                Occupancies: JSON.parse(entity.Occupancies._),
                Perils: JSON.parse(entity.Perils._),
                Stories: JSON.parse(entity.Stories._),
                YearBuilts: JSON.parse(entity.YearBuilts._),
                WsTiers: JSON.parse(entity.WsTiers._),
                CarlifoniaEQZones: JSON.parse(entity.CarlifoniaEQZones._),
                DistanceToCoast: JSON.parse(entity.DistanceToCoast._),
                ExposureSetSID: entity.ExposureSetSID._,
                ExposureDatabaseSID: entity.ExposureDatabaseSID._,
                ExposureSetName: entity.ExposureSetName._,
                ExposureDatabaseName: entity.ExposureDatabaseName._,
                ExposureViewSID: entity.ExposureViewSID._,
                FileName: entity.FileName._,
                SelectedCurrencyCode: entity.SelectedCurrencyCode ? entity.SelectedCurrencyCode._ : null,
                LoBs: entity.LinesOfBusiness ? JSON.parse(entity.LinesOfBusiness._) : []
            });
        });

        Vue.bus.emit('display-tab', { tab: "CEDE-EXP", display: (state.exposureSummary.length > 0) });
    },
    setData: (state) => {
        state.geoLevels = [];
        state.constructions = [];
        state.occupancies = [];
        state.perils = [];
        state.stories = [];
        state.subAreas = [];
        state.wsTiers = [];
        state.yearBuilts = [];
        state.carlifoniaEQZones = [];
        state.distanceToCoast = [];
        state.lobs = [];

        state.exposureSummary.forEach(function (item) {
            state.geoLevels.push(...item.GeocodingLevels.map(function (elem) {
                return (Object.assign(elem, {
                    Category: elem.GeoMatchLevel,
                    ExposureSetName: item.ExposureSetName,
                    ExposureViewSID: item.ExposureViewSID,
                    ExposureDatabaseSID: item.ExposureDatabaseSID,
                    ExposureDatabaseName: item.ExposureDatabaseName
                }));
            }));

            state.constructions.push(...item.Constructions.map(function (elem) {
                return (Object.assign(elem, {
                    Category: elem.ConstructionCategory,
                    ExposureSetName: item.ExposureSetName,
                    ExposureViewSID: item.ExposureViewSID,
                    ExposureDatabaseSID: item.ExposureDatabaseSID,
                    ExposureDatabaseName: item.ExposureDatabaseName
                }));
            }
            ));

            state.occupancies.push(...item.Occupancies.map(function (elem) {
                return (Object.assign(elem, {
                    Category: elem.OccupancyCategory,
                    ExposureSetName: item.ExposureSetName,
                    ExposureViewSID: item.ExposureViewSID,
                    ExposureDatabaseSID: item.ExposureDatabaseSID,
                    ExposureDatabaseName: item.ExposureDatabaseName
                }));
            }
            ));

            state.stories.push(...item.Stories.map(function (elem) {
                return (Object.assign(elem, {
                    Category: elem.NumberOfStories,
                    ExposureSetName: item.ExposureSetName,
                    ExposureViewSID: item.ExposureViewSID,
                    ExposureDatabaseSID: item.ExposureDatabaseSID,
                    ExposureDatabaseName: item.ExposureDatabaseName
                }));
            }
            ));

            state.yearBuilts.push(...item.YearBuilts.map(function (elem) {
                return (Object.assign(elem, {
                    Category: elem.YearBuilt,
                    ExposureSetName: item.ExposureSetName,
                    ExposureViewSID: item.ExposureViewSID,
                    ExposureDatabaseSID: item.ExposureDatabaseSID,
                    ExposureDatabaseName: item.ExposureDatabaseName
                }));
            }
            ));

            state.wsTiers.push(...item.WsTiers.map(function (elem) {
                return (Object.assign(elem, {
                    ExposureSetName: item.ExposureSetName,
                    ExposureViewSID: item.ExposureViewSID,
                    ExposureDatabaseSID: item.ExposureDatabaseSID,
                    ExposureDatabaseName: item.ExposureDatabaseName
                }));
            }
            ));

            state.distanceToCoast.push(...item.DistanceToCoast.map(function (elem) {
                return (Object.assign(elem, {
                    ExposureSetName: item.ExposureSetName,
                    ExposureViewSID: item.ExposureViewSID,
                    ExposureDatabaseSID: item.ExposureDatabaseSID,
                    ExposureDatabaseName: item.ExposureDatabaseName
                }));
            }
            ));

            state.carlifoniaEQZones.push(...item.CarlifoniaEQZones.map(function (elem) {
                return (Object.assign(elem, {
                    ExposureSetName: item.ExposureSetName,
                    ExposureViewSID: item.ExposureViewSID,
                    ExposureDatabaseSID: item.ExposureDatabaseSID,
                    ExposureDatabaseName: item.ExposureDatabaseName
                }));
            }
            ));

            state.perils.push(...item.Perils.map(function (elem) {
                return (Object.assign(elem, {
                    PartitionKey: item.PartitionKey,
                    RowKey: item.RowKey,
                    ExposureSetName: item.ExposureSetName,
                    ExposureViewSID: item.ExposureViewSID,
                    ExposureDatabaseSID: item.ExposureDatabaseSID,
                    ExposureDatabaseName: item.ExposureDatabaseName,
                    MappedPerils: elem.MappedPerils ? elem.MappedPerils : [],
                    IsRemoved: elem.IsRemoved ? elem.IsRemoved : false,
                    SelectedCurrencyCode: item.SelectedCurrencyCode,
                    SelectedCatalogType: item.SelectedCatalogType
                }));
            }
            ));

            item.LoBs.forEach(lob => {
                let found = state.lobs.find(x => x.userLob === getDisplayUserLob(state, lob));
                if (found) {
                    found.exposureSets.push({
                        ExposureSetName: item.ExposureSetName,
                        ExposureViewSID: item.ExposureViewSID,
                        ExposureDatabaseSID: item.ExposureDatabaseSID,
                        ExposureDatabaseName: item.ExposureDatabaseName,
                        FileName: item.FileName
                    });
                } else {
                    state.lobs.push({
                        userLob: getDisplayUserLob(state, lob),
                        britLob: '',
                        exposureSets: [
                            {
                                ExposureSetName: item.ExposureSetName,
                                ExposureViewSID: item.ExposureViewSID,
                                ExposureDatabaseSID: item.ExposureDatabaseSID,
                                ExposureDatabaseName: item.ExposureDatabaseName,
                                FileName: item.FileName
                            }
                        ]
                    });
                }
            });
        });
    },
    setRpx: (state, { list }) => {
        state.rpxs = [];
        list.forEach((entity) => {
            state.rpxs.push({
                PartitionKey: entity.PartitionKey._,
                RowKey: entity.RowKey._,
                FilePath: entity.FilePath._,
                Program: entity.Program._,
                Source: entity.Source._,
                Treaties: entity.Treaties ? JSON.parse(entity.Treaties._) : [],
                IsNew: false,
                Label: entity.Program._ + " - " + entity.FilePath._
            });
        });
    },
    updateRpxs(state, rpx) {
        state.rpxs.push(rpx);
    },
    setSavedLobMappings(state, mappings) {
        state.savedLobMappings = {};
        state.lobs.forEach(x => x.britLob = '');

        for (const mapping of mappings) {
            const displayUserLob = getDisplayUserLob(state, mapping.UserLob ? mapping.UserLob._ : null)
            Vue.set(state.savedLobMappings, displayUserLob, {
                //displayUserLob: mapping.RowKey._,
                userLob: displayUserLob,
                britLob: mapping.BritLob._
            });
        }
    },
    mapLinesOfBusiness(state, mappings){
        for (let i = 0; i < mappings.length; i++) {
            const el = mappings[i];
            const i = state.lobs.findIndex(x => x.userLob === el.userLob);
            if(i < 0) return;
            const original = state.lobs[i];
            Vue.set(state.lobs, i, Object.assign({}, original, {britLob: el.britLob}));
        }
    }
}

const actions = {
    async load({dispatch}, { programRef, analysisId }) {
        const input = {
            programRef,
            analysisId
        }
        await dispatch('loadData', input);
        await dispatch('loadRpxs', input);
        await dispatch('getLobMappings', input);
    },
    loadData({ commit }, { programRef, analysisId }) {
        var tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);
        var tableQuery = new azure.TableQuery()

        tableQuery = tableQuery.where('PartitionKey eq ?', programRef + '-' + analysisId);

        tableService.queryEntities(exposureTableName, tableQuery, null, (error, results, response) => {
            commit('setExposureSummary', { list: results.entries });
            commit('setData');
        });
    },
    loadRpxs({ commit }, { programRef, analysisId }) {
        var tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);
        var tableQuery = new azure.TableQuery()

        tableQuery = tableQuery.where('PartitionKey eq ?', programRef + '-' + analysisId);

        tableService.queryEntities(rpxTableName, tableQuery, null, (error, results, response) => {
            commit('setRpx', { list: results.entries });
        });
    },
    updateRpxs({ commit }, rpx) {
        commit('updateRpxs', rpx);
    },
    async getLobMappings(context, { programRef, analysisId }) {
        const tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);
        const query = new azure.TableQuery().where('PartitionKey eq ?', programRef + '-' + analysisId);
        const mappings = await AzureStorageUtils.queryEntitiesAsync(tableService, mappingsTableName, query);
        context.commit('setSavedLobMappings', mappings);
    },
    async uploadLobMapping(context, { mappings, programRef, analysisId }) {
        var tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);

        let entGen = azure.TableUtilities.entityGenerator;
        let entities = mappings.map(x => {
            return {
                PartitionKey: entGen.String(programRef + '-' + analysisId),
                RowKey: entGen.String(getLobRowKey(x.userLob)),
                UserLob: entGen.String(getLobFromDisplayValue(context.state, x.userLob)),
                BritLob: entGen.String(x.britLob)
            }
        });

        for (const ent of entities) {
            await AzureStorageUtils.insertOrMergeEntityAsync(tableService, mappingsTableName, ent);
        }

        await context.dispatch('getLobMappings', { programRef, analysisId });
    }
}

export default {
    namespaced: true,
    state,
    getters,
    actions,
    mutations
}