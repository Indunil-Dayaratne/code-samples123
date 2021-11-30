

import {
  DNB_REMOTESEARCH_GET,
  DNB_REMOTESEARCH_GET_ERROR,
  DNB_REMOTESEARCH_GET_SUCCESS,
  DNB_REMOTESEARCH_GET_DETAILS
} from '../constants';

import * as models from '../models';

import { action } from 'typesafe-actions';

export const remoteSearch = (keyword: models.DnbRemoteSearchOptions) => action(DNB_REMOTESEARCH_GET,keyword);
export const remoteSearchGetDetails = (dunsItem: any) => action(DNB_REMOTESEARCH_GET_DETAILS,dunsItem);
export const remoteSearchSuccess = (data: Array<any>) => action(DNB_REMOTESEARCH_GET_SUCCESS, data);
export const remoteSearchError = (message: string) => action(DNB_REMOTESEARCH_GET_ERROR, message);
