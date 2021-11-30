import {
  AAD_LOGIN,
  AAD_LOGIN_SUCCESS,
  AAD_LOGIN_ERROR,
  AAD_LOGOUT_SUCCESS,
  AAD_ACQUIRE_ACCESS_TOKEN
} from './constants';

import { action } from 'typesafe-actions';

export const acquireAccessToken = (scopes: any) => action(AAD_ACQUIRE_ACCESS_TOKEN,scopes);
export const login = (options: any) => action(AAD_LOGIN,options);
export const loginSuccess = (aadResponse: any) => action(AAD_LOGIN_SUCCESS,aadResponse);
export const logoutSuccess = () => action(AAD_LOGOUT_SUCCESS);
export const loginError = (message: string) => action(AAD_LOGIN_ERROR, message);

