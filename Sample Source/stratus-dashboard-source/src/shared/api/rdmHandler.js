import AzureStorageUtils from '../azure-storage-utils';
import azure from 'azure-storage';
import moment from 'moment';
import { formatNumber } from '../formatters';
const rdmTable = config.appPrefix + 'RdmAnalysis';
const tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);

const internalRdmSorter = (a, b) => {
    var a_split = a.split('.');
    var b_split = b.split('.');

    if(Number.isNaN(Number.parseInt(a_split[0])) && Number.isNaN(Number.parseInt(b_split[0]))) return 0;
    if(Number.isNaN(Number.parseInt(a_split[0]))) return -1;
    if(Number.isNaN(Number.parseInt(b_split[0]))) return 1;

    if(Number(a_split[0]) === Number(b_split[0])) {
        a_split.splice(0,1);
        b_split.splice(0,1);
        return internalRdmSorter(a_split.join('.'), b_split.join('.'));
    } else {
        return Number(a_split[0]) - Number(b_split[0]);
    }
}

const orderRdmAnalyses = (analyses, parentRmsAnalysisId = 0, parentSortId = 0, fileName = undefined) => {
    var filesSet = fileName ? [fileName] : new Set(analyses.map(x => x.RdmName));
    for (let file of filesSet) {
        var filtered = analyses.filter(x => x.GroupID === parentRmsAnalysisId && x.RdmName === file);
        if(filtered.length === 0) return;

        filtered.sort((a, b) => a.RmsAnalysisID - b.RmsAnalysisID);
        for(let i = 0; i < filtered.length; i++) {
            filtered[i].SortOrder = parentSortId + '.' + i;
            orderRdmAnalyses(analyses, filtered[i].RmsAnalysisID, filtered[i].SortOrder, file);
        }

        filtered.sort((a, b) => internalRdmSorter(a.SortOrder, b.SortOrder));
    }
}

const getRdmAnalysesFromAnalysis = async (programRef, analysisId) => {
    try {
        var tableQuery = new azure.TableQuery().where('PartitionKey eq ?', programRef + '-' + analysisId);
        const results = await AzureStorageUtils.queryEntitiesAsync(tableService, rdmTable, tableQuery)
        const output = [];
        let rowIndex = 0;
        results.forEach(entity => {
            output.push({
                PartitionKey: entity.PartitionKey._,
                RowKey: entity.RowKey._,
                DatabaseName: entity.DatabaseName._,
                RdmName: entity.FileName._,
                IsSelected: entity.IsSelected ? entity.IsSelected._ : false,
                GroupID: entity.GroupID._,
                IsGroup: entity.IsGroup._,
                RmsAnalysisID: entity.RmsAnalysisID._,
                Name: entity.Name._,
                Description: entity.Description._,
                Peril: entity.Peril._,
                SubPeril: entity.SubPeril._,
                LossAmplification: entity.LossAmplification._,
                RateSchemes: JSON.parse(entity.RateSchemes._),
                Treaties: JSON.parse(entity.Treaties._),
                InvalidConstOccIncluded: entity.InvalidConstOccIncluded._,
                Type: entity.Type._,
                Status: entity.Status._,
                Region: entity.Region._,
                Mode: entity.Mode._,
                GroupType: entity.GroupType._,
                ExposureType: entity.ExposureType._,
                EventTypeFilter: entity.EventTypeFilter._,
                AnalysisRunDate: moment(entity.AnalysisRunDate._).format(config.dateFormat),
                ScaleFactor: entity.ScaleFactor._,
                EDMName: entity.EDMName._,
                EDMGUID: entity.EDMGUID._,
                EventDate: moment(entity.EventDate._).format(config.dateFormat),
                EngineVersion: entity.EngineVersion._,
                ExposureID: entity.ExposureID._,
                EnginType: entity.EnginType._,
                Currency: entity.Currency._,
                MinSaffirSimpson: entity.MinSaffirSimpson._,
                Cedant: entity.Cedant._,
                CedantID: entity.CedantID._,
                GR_GrossLoss: formatNumber(entity.GR_GrossLoss._),
                RL_NetLossPreCat: formatNumber(entity.RL_NetLossPreCat._),
                RC_NetLossPostCorporateCat: formatNumber(entity.RC_NetLossPostCorporateCat._),
                RP_NetLossPostCat: formatNumber(entity.RP_NetLossPostCat._),
                RG_ReinsuranceGrossLoss: formatNumber(entity.RG_ReinsuranceGrossLoss._),
                PerspectiveCode: entity.PerspectiveCode ? entity.PerspectiveCode._ : '',
                UserField1: entity.UserField1 ? entity.UserField1._ : '',
                UserField2: entity.UserField2 ? entity.UserField2._ : '',
                IsExpanded: false,
                HasChildren: entity.IsGroup._,             
                RowIndex: rowIndex,
                RowDepth: 0,
                SortOrder: '' //.padStart(10, 'A')
            });            

            rowIndex++;
        });

        output.forEach((row) => {       
            row.ParentRow = row.GroupID > 0 ? output.filter(x => x.RmsAnalysisID === row.GroupID && x.RdmName === row.RdmName)[0] : null;
        });

        orderRdmAnalyses(output);
        output.forEach(x => x.RowDepth = x.SortOrder.split('.').length);
        return output;
    } catch (err) {
        console.error(err);
    }
}

export default {
    getRdmAnalysesFromAnalysis,
    orderRdmAnalyses,
    rdmSorter: internalRdmSorter
}