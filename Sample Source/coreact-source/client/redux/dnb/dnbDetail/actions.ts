import *  as constants from '../constants';
import * as models from '../models';

import { action } from 'typesafe-actions';

export const clearItemState = () => action(constants.DNB_GET_CLEAR_STATE);

export const getDetailsTaskStarted = (processId: string) => action(constants.DNB_GET_DETAILS_TASK_STARTED,processId);
export const getDetails = (dunsNumber: string) => action(constants.DNB_GET_DETAILS,dunsNumber);
export const getDetailsSuccess = (data: Array<any>) => action(constants.DNB_GET_DETAILS_SUCCESS, data);
export const getDetailsError = (message: string) => action(constants.DNB_GET_DETAILS_ERROR, message);

export const getDetailsDnbpci = (dunsNumber: string,accessToken: string) => action(constants.DNB_GET_DNBPCI,dunsNumber,accessToken);
export const getDetailsDnbpciSuccess = (data: any) => action(constants.DNB_GET_DNBPCI_SUCCESS,data);

export const getDetailsDnbpcomp = (dunsNumber: string,accessToken: string) => action(constants.DNB_GET_DNBPCOMP,dunsNumber,accessToken);
export const getDetailsDnbpcompSuccess = (data: any) => action(constants.DNB_GET_DNBPCOMP_SUCCESS,data);

export const getDetailsDnbpkyc = (dunsNumber: string,accessToken: string) => action(constants.DNB_GET_DNBPKYC,dunsNumber,accessToken);
export const getDetailsDnbpkycSuccess = (data: any) => action(constants.DNB_GET_DNBPKYC_SUCCESS,data);

export const getDetailsDnbpcl = (dunsNumber: string,accessToken: string) => action(constants.DNB_GET_DNBPCL,dunsNumber,accessToken);
export const getDetailsDnbpclSuccess = (data: any) => action(constants.DNB_GET_DNBPCL_SUCCESS,data);

export const getDetailsDnbpml = (dunsNumber: string,accessToken: string) => action(constants.DNB_GET_DNBPML,dunsNumber,accessToken);
export const getDetailsDnbpmlSuccess = (data: any) => action(constants.DNB_GET_DNBPML_SUCCESS,data);

export const getDetailsDnbpown = (dunsNumber: string,accessToken: string) => action(constants.DNB_GET_DNBPOWN,dunsNumber,accessToken);
export const getDetailsDnbpownSuccess = (data: any) => action(constants.DNB_GET_DNBPOWN_SUCCESS,data);

export const getDetailsDnbpvi = (dunsNumber: string,accessToken: string) => action(constants.DNB_GET_DNBPVI,dunsNumber,accessToken);
export const getDetailsDnbpviSuccess = (data: any) => action(constants.DNB_GET_DNBPVI_SUCCESS,data);

export const getDetailsDnbpcr = (dunsNumber: string,accessToken: string) => action(constants.DNB_GET_DNBPCR,dunsNumber,accessToken);
export const getDetailsDnbpcrSuccess = (data: any) => action(constants.DNB_GET_DNBPCR_SUCCESS,data);
export const getDetailsDnbpmed = (dunsNumber: string,accessToken: string) => action(constants.DNB_GET_DNBPMED,dunsNumber,accessToken);
export const getDetailsDnbpmedSuccess = (data: any) => action(constants.DNB_GET_DNBPMED_SUCCESS,data);
export const getDetailsDnbples = (dunsNumber: string,accessToken: string) => action(constants.DNB_GET_DNBPLES,dunsNumber,accessToken);
export const getDetailsDnbplesSuccess = (data: any) => action(constants.DNB_GET_DNBPLES_SUCCESS,data);
export const getDetailsDnbplej = (dunsNumber: string,accessToken: string) => action(constants.DNB_GET_DNBPLEJ,dunsNumber,accessToken);
export const getDetailsDnbplejSuccess = (data: any) => action(constants.DNB_GET_DNBPLEJ_SUCCESS,data);
export const getDetailsDnbpleb = (dunsNumber: string,accessToken: string) => action(constants.DNB_GET_DNBPLEB,dunsNumber,accessToken);
export const getDetailsDnbplebSuccess = (data: any) => action(constants.DNB_GET_DNBPLEB_SUCCESS,data);
export const getDetailsDnbppr = (dunsNumber: string,accessToken: string) => action(constants.DNB_GET_DNBPPR,dunsNumber,accessToken);
export const getDetailsDnbpprSuccess = (data: any) => action(constants.DNB_GET_DNBPPR_SUCCESS,data);

