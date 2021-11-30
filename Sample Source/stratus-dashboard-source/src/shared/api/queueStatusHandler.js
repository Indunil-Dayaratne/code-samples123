import axios from 'axios';
import functionRequestHelper from './functionRequestHelpers';

async function getQueueStatus() {
    try {
        const response = await axios.get(config.taskFunctionAppUrl + config.queueStatusEndPoint, await functionRequestHelper.getAuthorizationHeader());
        return response.data;
    } catch (err) {
        console.log(err);
        throw err;
    }
}

export default {
    getQueueStatus
}