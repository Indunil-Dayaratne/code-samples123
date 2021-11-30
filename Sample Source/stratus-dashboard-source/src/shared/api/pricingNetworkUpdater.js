import pricingHandler from './pricingHandler';
import cloneDeep from 'lodash/cloneDeep';

const upgradeNetwork = async (store) => {
    await addMissingPerspectiveLayers(store);
    await updateLossSetVersion(store);
    await convertToMultiYear(store);
};

const addMissingPerspectiveLayers = async ({ state, getters, dispatch }) => {
    try {
        let grossLayer;
        const perspectives = ['gross', 'net'];
        for (let i = 0; i < getters.layers.length; i++) {
            const layer = getters.layers[i];
            for (let j = 0; j < perspectives.length; j++) {
                const p = perspectives[j];
                const perspLayer = getters.getPerspectiveLayer(layer.id, p);
                if(!perspLayer) {
                    const newLayer = p === 'gross' ? pricingHandler.getNewGrossLayer(layer) : pricingHandler.getNewNetLayer(layer, grossLayer);
                    await dispatch('commitChange', { mutation: 'addLayerManual', data: newLayer.layer });
                    if(p === 'gross') {
                        grossLayer = newLayer.layer;
                        await dispatch('commitChange', { mutation: 'updateRelationshipSource', data: { original: layer.id, updated: newLayer.layer.id }});
                    }
                    await dispatch('commitChange', { mutation: 'addRelationshipManual', data: newLayer.relationships });
                } else if (p === 'gross') grossLayer = perspLayer;
            }
        }
    } catch (err) {
        console.error(err);
    }
};

const updateLossSetVersion = async ({ state, dispatch }) => {
    try {
        for (let i = 0; i < state.inputs.length; i++) {
            const input = state.inputs[i];
            const newInput = pricingHandler.getNewInput();
            if(input.data._schema !== newInput.data._schema || !!input.data._schema_version) {
                const copy = cloneDeep(input);
                copy.data._schema = newInput.data._schema;
                delete copy.data._schema_version;
                await dispatch('commitChange', 
                    { 
                        mutation: 'updateInput', 
                        data: copy
                    }
                )
            }
        }
    } catch (err) {
        console.log(err);
    }
};

const convertToMultiYear = async ({state, dispatch}) => {
    try {
        for (let i = 0; i < state.layers.length; i++) {
            const layer = state.layers[i];
            if(layer.data.layer_type && layer.data.layer_type === 'ceded' && 
                (layer.data._schema !== pricingHandler.pricingConstants.mappings.MultiYear.schema || !layer.data.layer_schema)) {
                const copy = cloneDeep(layer);
                copy.data._schema = pricingHandler.pricingConstants.mappings.MultiYear.schema;
                copy.data.layer_schema = pricingHandler.pricingConstants.mappings[layer.data.type].schema;
                delete copy.data._schema_version;
                await dispatch('commitChange', {
                    mutation: 'updateLayer',
                    data: copy
                });
            }
        }
    } catch (err) {
        console.log(err);
    }
}

export default {
    upgradeNetwork
}