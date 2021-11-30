import numeral from 'numeral';
import _ from 'lodash';
import api from '../../../../shared/api';
import Vue from 'vue';

var state = {
    programRef: '',
    accountId: '',
    inputs: [],
    layers: [],
    relationships: [],
    activeRelationship: 0,
    unsavedChanges: false,
    isSaving: false,
    layerTypes: [
        'QS',
        'CatXL',
        'AggXL',
        //'ILW'
    ],
    schemaMappings: Object.assign({}, api.pricingConstants.mappings),
    financialDefinition: Object.assign({}, api.pricingConstants.financialDefinition),
    objectTypes: Object.assign({}, api.pricingConstants.objectTypes),
    relationshipItems: [
        'Gross',
        'Ceded',
        'Net',
        'RIPs'
    ]
};

var getters = {
    inputs: state => state.inputs,
    layers: (state) => state.layers.filter(x => x.data.objType === state.objectTypes.LAYER),
    subjectLosses: (state) => state.layers.filter(x => x.data.objType === state.objectTypes.SUBJECT_LOSS),
    getBaseSubjectLoss: (state) => state.layers.find(x => x.data.objType === state.objectTypes.SUBJECT_LOSS && x.data.name === api.pricingConstants.baseSubjectLossParams.name),
    getInputByIndex: (state) => (index) => {
        return state.inputs[index];
    },
    getLayerByIndex: (state) => (index) => {
        return state.layers[index];
    },
    getInputById: (state) => (id) => {
        return state.inputs.find(x => x.id === id);
    },
    getLayerById: (state) => (id) => {
        return state.layers.find(x => x.id === id);
    },
    getVisibleLayers: state => getters.layers(state).filter(x => !x.data.layer_type || x.data.layer_type === 'ceded'),
    getGrossLayerbyId: (state) => id => {
        const groupLayers = getters.getGroupLayersFromBaseId(state)(id);
        return groupLayers.find(x => x.data.layer_type === 'gross');
    },
    getGroupLayersFromBaseId: state => baseId => {
        const baseLayer = state.layers.find(x => x.id === baseId);
        if(!baseLayer) return [];
        if(!baseLayer.data.layer_group_id) return [baseLayer];
        return state.layers.filter(x => x.data.layer_group_id === baseLayer.data.layer_group_id);
    },
    getGroupNodesFromBaseId: state => baseId => {
        let baseLayer = state.layers.find(x => x.id === baseId);
        if(!baseLayer) baseLayer = state.inputs.find(x => x.id === baseId); 
        if(!baseLayer) return [];
        if(!baseLayer.data.layer_group_id) return [baseLayer];
        return state.layers.filter(x => x.data.layer_group_id === baseLayer.data.layer_group_id);
    },
    getGroupLayersbyId: state => id => {
        return state.layers.filter(x => x.data.layer_group_id === id);
    },
    getPerspectiveOptionsForSourceNode: state => id => {
        const node = getters.getLayerById(state)(id);
        // Is input or subject loss
        if(!node || node.data.objType != state.objectTypes.LAYER) return ['gross'];
        const options = getters.getGroupLayersFromBaseId(state)(id).map(x => x.data.layer_type || 'ceded');
        const output = [];
        // Options done like this to ensure order
        ['gross', 'ceded', 'net'].forEach(p => {
            if(options.includes(p)) output.push(p);
        });
        return output;        
    },
    getRelationshipOptions: state => relationship => {
        const destinationGroup = getters.getGroupLayersFromBaseId(state)(relationship.destination);
        const excludeIds = destinationGroup.map(x => x.id);
        const output = [];
        output.push({
            type: 'Inputs',
            options: state.inputs
        })

        const subjectLossOptions = getters.subjectLosses(state).filter(x => !excludeIds.includes(x.id))
        if(subjectLossOptions.length > 0) {
            output.push({
                type: 'Subject Loss',
                options: subjectLossOptions
            })
        }

        output.push({
            type: 'Layers',
            options: getters.layers(state).filter(x => {
                if(destinationGroup.map(x => x.id).includes(x.id)) return false;
                return !x.data.layer_type
                    || (x.id !== relationship.source && x.data.layer_type === 'ceded')
                    || (x.id === relationship.source && (x.item === null || x.data.layer_type === 'ceded'))
                    || (x.id === relationship.source && (x.item === x.data.layer_type))
            })
        })
        
        return output;
    },
    getPerspectiveLayer: state => (id, perspective) => {
        const group = getters.getGroupLayersFromBaseId(state)(id);
        return group.find(x => x.data.layer_type === perspective.toLowerCase());
    },
    getNodeById: (state) => (id) => {
        return state.layers.find(x => x.id === id) || state.inputs.find(x => x.id === id);
    },
    getRelationshipById: (state) => (id) => {
        return state.relationships.find(x => x.id === id);
    },
    getRelationshipForLossFilterById: (state) => (id) => {
        for (let i = 0; i < state.relationships.length; i++) {
            if (state.relationships[i].data.lossFilter.data.map(x => x.id).includes(id)) return state.relationships[i];
        }
    },
    getRelationshipsByToNode: (state) => (toNodeId) => {
        const baseLayer = getters.getNodeById(state)(toNodeId);
        const grossLayer = getters.getGrossLayerbyId(state)(toNodeId);
        let adjToNodeId = null;
        if(!baseLayer.data.layer_type || baseLayer.data.layer_type !== 'ceded' || !grossLayer) adjToNodeId = baseLayer.id;
        else adjToNodeId = grossLayer.id;

        return state.relationships.filter(x => x.destination === adjToNodeId);
    },
    relationshipIsActive: (state) => {
        return state.activeRelationship !== 0;
    },
    isInputMapped: (state, getters) => (viewIdentifier, inputId) => {
        var input = getters.getInputById(inputId);
        if (!input) { console.error(`No input found with ID: ${inputId}`); return; }
        return !!input.data.paths[viewIdentifier];
    },
    summaryMetrics: () => {
        return {
            primary: {
                QS: { metric: 'raw_share', identifierChar: '%', formatter: (value) => numeral(value / 100).format('0.0%') },
                CatXL: { metric: 'occurrence_limit_value', identifierChar: 'OL', formatter: (value) => numeral(value).format('0.0a') },
                AggXL: { metric: 'aggregate_limit_value', identifierChar: 'AL', formatter: (value) => numeral(value).format('0.0a') },
                ILW: { metric: 'trigger', identifierChar: 'T', formatter: (value) => numeral(value).format('0.0a') }
            },
            secondary: {
                QS: { metric: '', identifierChar: '', formatter: (value) => value },
                CatXL: { metric: 'occurrence_attachment_value', identifierChar: 'OA', formatter: (value) => numeral(value).format('0.0a') },
                AggXL: { metric: 'aggregate_attachment_value', identifierChar: 'AA', formatter: (value) => numeral(value).format('0.0a') },
                ILW: { metric: 'payout', identifierChar: 'P', formatter: (value) => numeral(value).format('0.0a') }
            }
        }
    },
    getAllNodeIds: (state) => {
        return [...state.inputs.map(x => x.id), ...state.layers.map(x => x.id)];
    }
};

var mutations = {
    loadData(state, {inputs, layers, links}) {
        state.inputs = inputs;
        state.layers = layers;
        state.relationships = links;
        state.activeRelationship = 0;
        state.unsavedChanges = false;

        state.inputs.sort((a, b) => a.id - b.id);
        state.layers.sort((a, b) => a.id - b.id);
    },
    clear(state) {
        state.inputs = [];
        state.layers = [];
        state.relationships = [];
        state.activeRelationship = 0;
        state.unsavedChanges = false;
        state.programRef = '';
        state.analysisId = '';
    },
    addInput(state){
        const input = api.getNewInput();
        state.inputs.push(input);
        state.unsavedChanges = true;
        const baseSubjectLoss = getters.getBaseSubjectLoss(state)
        if(!baseSubjectLoss) return;
        const relationship = api.getNewRelationship(baseSubjectLoss.id)
        relationship.source = input.id;
        relationship.data.sourceType = 'input'
        relationship.data.item = 'gross'
        state.relationships.push(relationship);        
    },
    addLayerManual(state, layer) {
        state.layers.push(layer);
        state.unsavedChanges = true;
    },
    addSubjectLoss(state) {
        state.layers.push(api.getNewSubjectLoss())
        state.unsavedChanges = true
    },
    addLayer(state) {
        const base = api.getNewLayer(); 
        const gross = api.getNewGrossLayer(base);
        const net = api.getNewNetLayer(base, gross.layer);
        state.layers.push(base, gross.layer, net.layer);
        state.relationships.push(...gross.relationships, ...net.relationships);
        state.unsavedChanges = true;
    },
    copyNode(state, id) {
        const base = getters.getNodeById(state)(id);
        if(!base) { console.log(`No layer found with ID: ${id}`); return;}
        const copy = api.copyNode(base);
        switch (copy.data.objType) {
            case state.objectTypes.LAYER:
                const gross = api.getNewGrossLayer(copy);
                const net = api.getNewNetLayer(copy, gross.layer);
                const relationshipCopies = api.copyDestinationRelationships(getters.getRelationshipsByToNode(state)(id), gross.layer.id);
                state.layers.push(copy, gross.layer, net.layer);
                state.relationships.push(...gross.relationships, ...net.relationships, ...relationshipCopies);
                state.unsavedChanges = true;
                break;

            case state.objectTypes.INPUT:
                state.input.push(copy);
                state.unsavedChanges = true;
                break;

            case state.objectTypes.SUBJECT_LOSS:
                state.layers.push(copy)
                state.unsavedChanges = true;
                break;

            default:
                break;
        }
    },
    addReinstatement(state, id) {
        var layer = state.layers.find(x => x.id === id);
        if(!layer) { console.error(`No layer found with ID: ${id}`); return;}
        layer.data.reinstatements.push(api.getNewReinstatement());
        state.unsavedChanges = true;
    },
    addRelationship(state, toNodeId) {
        const layer = getters.getNodeById(state)(toNodeId);
        let adjToNodeId = toNodeId;
        if(layer.data.layer_type && layer.data.layer_type !== 'gross') {
            const grossLayer = getters.getGrossLayerbyId(state)(toNodeId);
            adjToNodeId = grossLayer.id;
        }

        state.relationships.push(api.getNewRelationship(adjToNodeId));
        state.unsavedChanges = true;
    },
    addRelationshipManual(state, relationships) {
        state.relationships.push(...relationships);
        state.unsavedChanges = true;
    },
    addLossFilter(state, relationshipId) {
        var relationship = state.relationships.find(x => x.id === relationshipId);
        if(!relationship) {
            console.error({msg: `Unidentified relationship ID: ${relationshipId}`});
            return;
        };
        relationship.data.lossFilter.data.push(api.getNewLossFilter());
        state.unsavedChanges = true;
    },
    updateRelationship(state, data){
        if (!state.isSaving) {
            if (!data) return;
            var relationship = state.relationships.find(x => x.id === data.id);
            if(!relationship) {
                console.error({
                    msg: `Unidentified relationship ID: ${data.id}`,
                    obj: data
                });
                return;
            };
            Object.assign(relationship, data);
            state.unsavedChanges = true;
        }
    },
    updateRelationshipSource(state, {original, updated}) {
        const rels = state.relationships.filter(r => r.destination === original);
        if(!rels.length) return;
        for (let i = 0; i < rels.length; i++) {
            const r = rels[i];
            const newR = api.getNewRelationship(updated);
            newR.source = r.source;
            newR.data = Object.assign({}, r.data);
            const existingIndex = state.relationships.findIndex(x => x.id === r.id);
            state.relationships.splice(existingIndex, 1);
            state.relationships.push(newR);
        }
        state.unsavedChanges = true;
    },
    updateLayer(state, layer){
        if (!state.isSaving) {
            var stateLayer = state.layers.find(x => x.id === layer.id);
            if(!stateLayer) {console.error(`No layer found with ID: ${layer.id}`); return;}
            if(stateLayer.data.layer_type && stateLayer.data.layer_type !== 'ceded') return;
            Object.assign(stateLayer, layer);
            const layerGroup = state.layers.filter(x => x.data.layer_group_id === layer.data.layer_group_id);
            ['gross', 'net'].forEach(perspective => {
                const perspLayer = layerGroup.find(x => x.data.layer_type === perspective);
                if(!perspLayer) return;
                Object.assign(perspLayer, api.getUpdatePerspectiveLayer(stateLayer, perspLayer));
            });

            state.unsavedChanges = true;
        }
    },
    updateInput(state, input) {
        if (!state.isSaving) {
            var stateInput = state.inputs.find(x => x.id === input.id);
            if (!stateInput) { console.error(`No input found with ID: ${input.id}`); return;}
            Object.assign(stateInput, input);
            state.unsavedChanges = true;
        }
    },
    updateSubjectLoss(state, subjectLoss) {
        if(!state.isSaving) {
            var stateSubjectLoss = state.layers.find(x => x.id === subjectLoss.id);
            if (!stateSubjectLoss) { console.error(`No subject loss found with ID: ${subjectLoss.id}`); return;}
            Object.assign(stateSubjectLoss, subjectLoss);
            state.unsavedChanges = true;
        }
    },
    deleteInput(state, id) {
        var index = state.inputs.findIndex(x => x.id === id);
        if(index < 0) { console.error(`No input found with ID: ${id}`); return;}
        state.inputs.splice(index, 1);
        state.unsavedChanges = true;
    },
    deleteSubjectLoss(state, id) {
        var index = state.layers.findIndex(x => x.id === id);
        if(index < 0) { console.error(`No subject loss found with ID: ${id}`); return;}
        state.layers.splice(index, 1);
        state.unsavedChanges = true;
    },
    deleteLayer(state, id) {
        var index = state.layers.findIndex(x => x.id === id);
        if(index < 0) { console.error(`No layer found with ID: ${id}`); return;}
        const layerGroup = getters.getGroupLayersFromBaseId(state)(id);
        layerGroup.map(x => x.id).forEach(i => {
            index = state.layers.findIndex(x => x.id === i);
            if(index < 0) return;
            state.layers.splice(index, 1);
        });
        state.unsavedChanges = true;
    },
    deleteReinstatement(state, data) {
        var layer = state.layers.find(x => x.id === data.layerId);
        if(!layer) { console.error(`No layer found with ID: ${data.layerId}`); return;}
        var id;
        for (id of data.reinstatementIds) {
            var index = layer.data.reinstatements.findIndex(x => x.id === id);
            if(index < 0) { console.error(`No reinstatement found with ID: ${id}`); continue;}
            layer.data.reinstatements.splice(index, 1);
            state.unsavedChanges = true;
        }
    },
    deleteRelationship(state, ids) {
        for (var id of ids) {
            var index = state.relationships.findIndex(x => x.id === id);
            if (index < 0) { console.error(`No relationships found with ID: ${id}`); continue; }
            state.relationships.splice(index, 1);
            state.unsavedChanges = true;
        }
    },
    deleteLossFilter(state, input) {
        var relationship = state.relationships.find(x => x.id === input.relationshipId);
        if (!relationship) { console.error(`No relationships found with ID: ${input.relationshipId}`); return; }
        var filterIndex = relationship.data.lossFilter.data.findIndex(x => x.id === input.filterId);
        if (filterIndex < 0) { console.error(`No filter found with ID: ${input.filterId}`); return; }
        relationship.data.lossFilter.data.splice(filterIndex, 1);
        state.unsavedChanges = true;
    },
    activateRelationship(state, id) {
        var relationship = state.relationships.find(x => x.id === id);
        if (!relationship) { console.error(`Could not edit filters. No relationship found with ID: ${id}`); return;}
        state.activeRelationship = id;
    },
    deactivateRelationship(state) {
        state.activeRelationship = 0;
    },
    mapLossSetToInput(state, data) {
        var input = state.inputs.find(x => x.id === data.inputId);
        if (!input) { console.error(`No input found with ID: ${data.inputId}`); return; }
        if (!Object.keys(input.data.paths).some((key) => !!input.data.paths[key])) input.data.currency = data.currency;
        if(!data.filePath) {
            Vue.delete(input.data.paths, data.viewIdentifier);
            Vue.delete(input.data.pathsObj, data.viewIdentifier);
        } else {
            Vue.set(input.data.pathsObj, data.viewIdentifier, data.lossSet);
            Vue.set(input.data.paths, data.viewIdentifier, data.filePath);
        }
        if (!Object.keys(input.data.paths).some((key) => !!input.data.paths[key])) input.data.currency = data.currency;
        state.unsavedChanges = true;
    },
    removeLossSetMappings(state, identifier) { 
        for (let i = 0; i < state.inputs.length; i++) {
            const input = state.inputs[i];
            Vue.delete(input.data.paths, identifier);
            Vue.delete(input.data.pathsObj, identifier);
        }
    },
    updateInputsOnLossViewChange(state, {newIdentifier, oldIdentifier}) {
        for (let i = 0; i < state.inputs.length; i++) {
            if (!!state.inputs[i].data.paths[oldIdentifier]) {
                state.inputs[i].data.paths[newIdentifier] = state.inputs[i].data.paths[oldIdentifier];
                Vue.delete(state.inputs[i].data.paths, oldIdentifier);
            }
        }
    },
    isSaving(state, isSaving) {
        state.isSaving = isSaving;
    }
};

var actions = {
    commitChange(context, { mutation , data }) {
        try {
            let initialStateUnsavedChanges = context.state.unsavedChanges;
            context.commit(mutation, data);
            if (context.state.unsavedChanges && !initialStateUnsavedChanges) context.dispatch('pricing/updateCalculationOutOfDateFlag', null, {root: true});
        } catch (err) {
            console.error(err);
        }
    },
    deleteNode(context, { mutation, data: id }) {
        try {
            const nodes = context.getters.getGroupNodesFromBaseId(id);
            const relationshipIds = nodes.reduce((acc, node) => {
                acc.push(...context.state.relationships.filter(x => x.source === node.id || x.destination === node.id).map(x => x.id));
                acc = [...new Set(acc)];
                return acc;
            }, []);

            context.dispatch('commitChange', { mutation: mutation, data: id });
            context.dispatch('commitChange', { mutation: 'deleteRelationship', data: relationshipIds });
        } catch (err) {
            console.error(err);
        }
    },
    async loadData(context, data) {
        try {
            data.links.forEach(x => {
                x.data.lossFilter.data.forEach(y => y._valueObj = context.rootGetters['pricing/filter/getFilterObject'](y.filter, y.value));
            });
            context.commit('loadData', data);
            await api.pricingNetworkUpdater.upgradeNetwork(context);
        } catch (err) {
            console.error(err);
        }
    },
    clear(context) {
        context.commit('clear');
    }
};

export default{
    namespaced: true,
    state,
    getters,
    mutations,
    actions    
}
