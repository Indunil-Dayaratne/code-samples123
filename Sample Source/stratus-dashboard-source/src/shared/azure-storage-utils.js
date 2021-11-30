import azure from 'azure-storage';

const retrieveEntityAsync = async (tableService, tableName, partitionKey, rowKey) => {
    return new Promise((resolve, reject) => {
        tableService.retrieveEntity(tableName, partitionKey, rowKey, (error, result, response) => {
            if (error) {
                reject(error);
            } else {
                resolve(result);
            }
        });
    });
}

const queryEntitiesAsyncInternalWithToken = async (tableService, tableName, tableQuery, continuationToken) => {
    return new Promise((resolve, reject) => {
        tableService.queryEntities(tableName, tableQuery, continuationToken, (error, results, response) => {
            if (error) {
                reject(error);
            } else {
                resolve(results);
            }
        });
    });
};

const queryEntitiesAsync = async (tableService, tableName, tableQuery) => {
    let token = null;
    const output = [];
    do {
        const results = await queryEntitiesAsyncInternalWithToken(tableService, tableName, tableQuery, token);
        token = results.continuationToken;
        output.push(...results.entries);
    } while (!!token)
    return output;
}


const insertOrMergeEntityAsync = async (tableService, tableName, entity) => {
    return new Promise((resolve, reject) => {
        tableService.insertOrMergeEntity(tableName, entity, (error, result, response) => {
            if (error) {
                reject(error);
            } else {
                resolve(entity);
            }
        });
    });
}

const getAllRowsAsync = async (tableName) => {
    const tableService = azure.createTableService(config.azureTableStore.account, config.azureTableStore.key);
    const tableQuery = new azure.TableQuery();
    return await queryEntitiesAsync(tableService, tableName, tableQuery);
}

export default {
    retrieveEntityAsync,
    queryEntitiesAsync,
    insertOrMergeEntityAsync,
    getAllRowsAsync
}
