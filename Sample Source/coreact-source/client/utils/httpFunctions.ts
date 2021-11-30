import axios from 'axios';
import * as types from '../types/types'

export interface IHttpOptions {
  method: string,
  headers: any,
  url: string,
  inputData: any,
  params?: any
}

export const httpWrapper = async (options: IHttpOptions) => {
  try
    {
      let result = await  axios.request({
        method: options.method,
        url: options.url,
        headers: options.headers,
        params: options.params
      });

      return result;
    }
    catch(error) {
      console.log("api error:" + error);

      return error;
    }
}
