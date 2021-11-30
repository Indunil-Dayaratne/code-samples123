import axios from 'axios';
import AzureStorageUtils from '../azure-storage-utils';
import azure from 'azure-storage';
import moment from 'moment';
const fileTable = config.appPrefix + 'Files';
const tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);

const getFiles = async (programRef, folder, user) => {
    try {
        const res = await axios.post(config.getFileLogicAppEndpoint, {
            programRef,
            folder,
            user
        });
        if(res.status !== 200) throw res;
        return res.data;
    } catch (err) {
        console.error(err);
        return [];
    }
}

const loadFile = async (fileInfo, yoa, programRef, accountName, defaultCurrency, summary, runHazard, user, analysisId) => {
    try {
        const res = await axios.post(config.kickstartFileLogicAppEndpoint, {
            accountName,
            programRef,
            analysisId,
            createBy: user,
            defaultCurrency,
            runCedeHazardAnalysis: runHazard,
            summary,
            dataFileLocation: fileInfo.Path,
            fileInfo,
            yoa
        });
    } catch (err) {
        console.error(err);
        return;
    }
}

const reloadFile = async (fileInfo, yoa, programRef, accountName, defaultCurrency, summary, runHazard, user, analysisId) => {
    try {
        let reload = Object.assign({}, fileInfo);
        const reg = new RegExp(/\.mdf\s*$/gim);

        if(fileInfo.Extension.search(reg) >= 0) {  
            const loadedFiles = await getLoadedFiles(programRef);
            const bakFiles = loadedFiles.filter(x => x.Path.toLowerCase() == fileInfo.Path.replace(reg, ".bak").toLowerCase());
            if(bakFiles.length == 1) reload = Object.assign({}, bakFiles[0]);
        }

        await loadFile(reload, yoa, programRef, accountName, defaultCurrency, summary, runHazard, user, analysisId);
    } catch (err) {
        console.log(err);
    }
};

const getLoadedFiles = async (programRef) => {
    try {
        var tableQuery = new azure.TableQuery();
        tableQuery = tableQuery.where('PartitionKey eq ?', programRef);
        const results = await AzureStorageUtils.queryEntitiesAsync(tableService, fileTable, tableQuery);
        const output = [];

        results.forEach(entity => {
            output.push(extractEntity(entity));
        });
        return output;
    } catch (err) {
        console.error(err);
        return [];
    }
}

const getAllFiles = async () => {
    try {
        const results = await AzureStorageUtils.getAllRowsAsync(fileTable);
        const output = [];
        results.forEach(entity => {
            output.push(extractEntity(entity));
        });
        return output;
    } catch (err) {
        console.error(err);
        return [];
    }
}

const extractEntity = (entity) => {
    return {
        PartitionKey: entity.PartitionKey._ ,
        RowKey: entity.RowKey._ ,
        Name: entity.Name._,
        Directory: entity.Directory._,
        Path: entity.Path._,
        Size: entity.Size._,
        Status: entity.Status._,
        Extension: entity.Extension._,
        CreationTime: moment(entity.CreationTime._).format(config.dateFormat),
        LastWriteTime: moment(entity.LastWriteTime._).format(config.dateFormat),
        LastAccessTime: moment(entity.LastAccessTime._).format(config.dateFormat),
        YOA: entity.YOA._,
        ImportedAt: moment(entity.LastAccessTime._).format(config.dateFormat),
        Description: entity.Description ? entity.Description._ : "",
        RelatedTo: entity.RelatedTo ? entity.RelatedTo._ : ""
    }
}

const locationIsFolder = (location) => {
    //Search for . with no \ following at any point, this expression will return whole extension
    const re = new RegExp(/\.\w*(?!.*\\)/g);
    return location.match(re) === null;
}

const getRelatedFiles = (files, rowKeyStart) => {
    const output = [];
    const related = files.filter(file => file.RelatedTo && file.RelatedTo === rowKeyStart);
    output.push(...related);
    for (let i = 0; i < related.length; i++) {
        const file = related[i];
        output.push(...getRelatedFiles(files, file.RowKey));
    }
    return output;
};

const getRelatedAnalyses = (analyses, path) => {
    const output = [];
    output.push(...analyses.filter(x => x.DataFileLocation === path));
    const reg = new RegExp(/\.mdf$/gim);
    if(path.search(reg) >= 0) {
        const bakPath = path.replace(reg, '.bak');
        output.push(...analyses.filter(x => x.DataFileLocation === bakPath));
    }
    return output;
};

const checkAnalysisProgramReference = (programRef, analysisProgRef) => {
    const re = new RegExp(`^${programRef}\\w*`, 'gi');
    return analysisProgRef.match(re) !== null;
};

export default {
    getFiles,
    loadFile,
    reloadFile,
    getLoadedFiles,
    locationIsFolder,
    getAllFiles,
    getRelatedFiles,
    getRelatedAnalyses,
    checkAnalysisProgramReference
}