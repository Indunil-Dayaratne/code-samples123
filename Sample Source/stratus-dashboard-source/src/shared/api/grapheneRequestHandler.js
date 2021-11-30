import axios from 'axios';
import functionHelper from './functionRequestHelpers';

async function getNetwork({networkId, revision}) {
    try {
        if(!networkId) return null;
        let rawArgs = `?networkId=${networkId}`;
        //rawArgs += `&revision=${revision || 0}`;
        return axios.get(config.grapheneFunctionAppUrl + config.loadStructureFunctionEndpoint + encodeURI(rawArgs), await functionHelper.getAuthorizationHeader());
    } catch (err) {
        throw err;
    }
}

async function saveNetwork(data) {
    try {
        return axios.post(config.grapheneFunctionAppUrl + config.saveStructureFunctionEndpoint, data, await functionHelper.getAuthorizationHeader());
    } catch (err) {
        throw err;
    }
}

async function getExchangeRates(token) {
    try {
        return axios.post(config.grapheneFunctionAppUrl + config.getExchangeRatesEndPoint, {}, await functionHelper.getAuthorizationHeader());
    } catch (err) {
        throw err;
    }
}

async function uploadExchangeRates(rates) {
    try {
        return axios.post(config.grapheneFunctionAppUrl + config.uploadExchangeRatesEndPoint, rates, await functionHelper.getAuthorizationHeader());
    } catch (err) {
        throw err;
    }
}

async function getNodeResultsFromBlobStorage(url) {
    try {
        return axios.post(config.grapheneFunctionAppUrl + config.getNodeResultFromBlobStorage, url, await functionHelper.getAuthorizationHeader());
    } catch (err) {
        throw err;
    }
}

async function getEventIds({networkId, lossViewIdentifiers}) {
    try {
        return axios.post(config.grapheneFunctionAppUrl + config.getEventIdsForNetworkEndPoint, {
            networkId: networkId,
            lossViewIdentifiers: lossViewIdentifiers
        }, await functionHelper.getAuthorizationHeader());
    } catch (err) {
        throw err;
    }
}

async function getYeltByEvent({ networkId, lossViewIdentifiers, currency, eventIds }) {
    try {
        return axios.post(config.grapheneFunctionAppUrl + config.getYeltByEventEndPoint, {
            networkId: networkId,
            lossViewIdentifiers: lossViewIdentifiers,
            currency,
            eventIds: eventIds
        }, await functionHelper.getAuthorizationHeader());
    } catch (err) {
        throw err;
    }
}

async function runPricingAnalysis(data) {
    try {
        return axios.post(config.runPricingAnalysisLogicAppEndpoint, data);
    } catch (err) {
        throw err;
    }
}

async function exportToPrime({programRef, analysisId, networkId, revision, nodeId, user, eventCatalogIds, currency, lossViewIdentifier, metadataNodeId}) {
    try {
        return axios.post(config.exportToPrimeLogicAppEndpoint, {
            programRef,
            analysisId,
            networkId,
            revision,
            nodeId,
            eventCatalogIds,
            user,
            currency,
            lossViewIdentifier,
            metadataNodeId
        });
    } catch (err) {
        throw err;
    }
}

async function downloadYelt(programRef, analysisId, exportInfo, user) {
    try {
        return axios.post(config.downloadYeltLogicAppEndpoint, {
            programRef,
            analysisId,
            networkId: exportInfo.networkId,
            networkName: exportInfo.networkName,
            nodeId: exportInfo.nodeId,
            nodeName: exportInfo.name,
            nodePerspective: exportInfo.perspective,
            lossViewIdentifier: exportInfo.lossViewIdentifier,
            lossViewName: exportInfo.lossViewName,
            currency: exportInfo.currency,
            user
        });
        // const token = await getToken();
        // let requestUrl = `${config.grapheneFunctionAppUrl + config.downloadYeltEndpoint}?fileUri=${filePath}&fileName=${fileName}&token=${token}`;
        // window.open(encodeURI(requestUrl),'_blank');
    } catch (err) {
        throw err;  
    }
}

export default {
    getNetwork,
    saveNetwork,
    getExchangeRates,
    uploadExchangeRates,
    getNodeResultsFromBlobStorage,
    getEventIds,
    getYeltByEvent,
    runPricingAnalysis,
    exportToPrime,
    downloadYelt
}
