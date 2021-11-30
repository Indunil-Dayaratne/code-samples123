import AzureStorageUtils from '../azure-storage-utils';
import azure from 'azure-storage';
import moment from 'moment';
const clfTable = config.appPrefix + 'Clf';
const tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);

const getClfAnalysesFromAnalysis = async (programRef, analysisId) => {
    try {
        var tableQuery = new azure.TableQuery();
        tableQuery = tableQuery.where('PartitionKey eq ?', programRef + '-' + analysisId);

        const output = [];
        const results = await AzureStorageUtils.queryEntitiesAsync(tableService, clfTable, tableQuery);

        results.forEach((entity) => {
            output.push({
                PartitionKey: entity.PartitionKey._,
                RowKey: entity.RowKey._,
                Company: entity.Company._,
                CompanyID: entity.CompanyID._,
                Program: entity.Program._,
                ContractID: entity.ContractID._,
                CLFBaseName: entity.CLFBaseName._,
                DateCLFCreated: moment(entity.DateCLFCreated._).format(config.dateFormat),
                DateCLFInstalled: moment(entity.DateCLFInstalled._).format(config.dateFormat),
                SubPerils: entity.SubPerils ? entity.SubPerils._.split(",") : [],
                CLFVersion: entity.CLFVersion ? entity.CLFVersion._ : '',
                ILFVersion: entity.ILFVersion ? entity.ILFVersion._ : '',
                Model: entity.Model ? entity.Model._ : '',
                CLFModelVersion: entity.CLFModelVersion ? entity.CLFModelVersion._ : '',
                ILFModelVersion: entity.ILFModelVersion ? entity.ILFModelVersion._ : '',
                LossCatalogue: entity.LossCatalogue ? entity.LossCatalogue._ : '',
                EventSet: entity.EventSet ? entity.EventSet._ : '',
                LossFileExtension: entity.LossFileExtension ? entity.LossFileExtension._ : '',
                DemandSurge: entity.DemandSurge._,
                StochasticLossFile: entity.StochasticLossFile ? entity.StochasticLossFile._ : '',
                HistoricalLossFile: entity.HistoricalLossFile ? entity.HistoricalLossFile._ : '',
                RDSLossFile: entity.RDSLossFile ? entity.RDSLossFile._ : '',
                AreaDetail: entity.AreaDetail ? entity.AreaDetail._ : '',
                LossFileType: entity.LossFileType ? entity.LossFileType._ : 0,
                LossType: entity.LossType ? entity.LossType._ : 0,
                AALs: entity.AALs ? JSON.parse(entity.AALs._) : [],
                CompanyLoss: entity.CompanyLoss ? entity.CompanyLoss._ : 0,
                ConditionLoss: entity.ConditionLoss ? entity.ConditionLoss._ : 0,
                ContractLoss: entity.ContractLoss ? entity.ContractLoss._ : 0,
                FileName: entity.FileName._,
                MatchesCurrentVersion: entity.CLFVersion && entity.ILFVersion ? entity.CLFVersion._ === entity.ILFVersion._ : false,
                SelectedValuesStd: entity.SelectedValuesStd ? JSON.parse(entity.SelectedValuesStd._) : { Perspective: "", UserField1: "", UserField2: "" },
                ResultSetName: entity.ResultSetName ? entity.ResultSetName._ : '',
                ClfPath: entity.ClfPath ? entity.ClfPath._ : '',
                RunType: entity.RunType ? entity.RunType._ : '',
                EviProgramName: entity.EviProgramName ? entity.EviProgramName._ : "",
                ResultsCurrency: entity.ResultsCurrency ? entity.ResultsCurrency._ : "",
                CompanySID: entity.CompanySID ? entity.CompanySID._ : 0,
                ProgramSID: entity.ProgramSID ? entity.ProgramSID._ : 0,
                ActivitySID: entity.ActivitySID ? entity.ActivitySID._ : 0,
                LineOfBusiness: entity.LineOfBusiness ? entity.LineOfBusiness._ : "All"
            });
        });

        return output;

    } catch (err) {
        console.error(`Error loading CLFs:`, err);
    }
}

export default {
    getClfAnalysesFromAnalysis
}