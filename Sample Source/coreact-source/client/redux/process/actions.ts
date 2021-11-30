import {
  PROCESS_TYPE_GET,
  PROCESS_TYPE_GET_ERROR,
  PROCESS_TYPE_GET_SUCCESS
} from './constants';

import * as models from './models';

import { action } from 'typesafe-actions';

export const processTypeGet = (typeName: string) => action(PROCESS_TYPE_GET,typeName);
export const processTypeSuccess = (data: models.ProcessTypeItem) => action(PROCESS_TYPE_GET_SUCCESS, data);
export const processTypeError = (message: string) => action(PROCESS_TYPE_GET_ERROR, message);
