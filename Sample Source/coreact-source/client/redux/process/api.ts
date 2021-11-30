
import * as constants from '../../constants/defaultValues';
import * as models from './models';
import axios from 'axios';
import * as types from '../../types/types';

export const getProcessType = async (processType: string, accessToken: string) => {
  try
    {
      let result = await  axios.request({
        method: 'get',
        url: constants.processApiUrl + constants.processApiGetType + "/" +  processType,
        headers: { "Authorization": "Bearer " + accessToken}
      });

      return await result.data as models.ProcessTypeItem;
    }
    catch(error) {

      return error;
    }
}

export const createNewProcess = async (processType: string, processId: string, accessToken: string) => {
  try
    {
      let result = await  axios.request({
        method: 'post',
        url: constants.processApiUrl + constants.processApiCreateProcess + "/" +  processType + "/" + processId,
        headers: { "Authorization": "Bearer " + accessToken}
      });

      return await result.data;
    }
    catch(error) {
      console.log("api error:" + error);

      return error;
    }
}

