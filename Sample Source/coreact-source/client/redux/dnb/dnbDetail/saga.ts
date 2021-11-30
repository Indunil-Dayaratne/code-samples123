import *  as constants from '../constants';
import { delay, eventChannel} from 'redux-saga'
import { all, call, fork, put, takeEvery, spawn, select, take , takeLatest} from 'redux-saga/effects'
import * as actions from './actions';
import axios from 'axios';
import * as processSagas from '../../process/saga'
import { PROCESS_TYPE_GET } from '../../process/constants';
import * as defaultValues from '../../../constants/defaultValues'
import { ProcessTypeItem,ProcessEndpoint} from 'client/redux/process/models';
import { AADState } from 'client/redux/aad/models';
import * as detailTypes from './models';
import * as processApis from '../../process/api'
import * as SignalR from '@aspnet/signalr'
import { dnbApi } from '../dnbApi';
import { dnbApiExecutionList } from '../dnbApiExecutionList';
const aadStateReference = (state) => {
  return state.aad;
}

export const getData = async (url: string, accessToken: string) => {
  try
    {
      let result = await axios.request({
        method: 'get',
        url,
        headers: { "Authorization": "Bearer " + accessToken}
      });

      return await result.data;
    }
    catch(error) {
      return error;
    }
}

function* getDnbData(dnbPathName :string,payload,successMethodToCallWithData : Function) {

  const dunsNumber : string = payload;
  const aadState : AADState = yield select(aadStateReference);
  let url: string = defaultValues.dnbBaseUrl + "/"+dnbPathName+"/" + dunsNumber;
  let data =  yield call(getData,url,aadState.loginAccessToken as string);
  yield put(successMethodToCallWithData(data));
}

function* handleDnbPciGetDetails(action : any) {
  let data = yield call(dnbApi.getXValueQuery,'ci',action.payload, action.meta)
  yield put(actions.getDetailsDnbpciSuccess(data));
}
function* handleDnbPKycGetDetails(action : any) {
  let data = yield call(dnbApi.getXValueQuery,'kyc',action.payload, action.meta)
  yield put(actions.getDetailsDnbpkycSuccess(data));
}

function* handleDnbPviGetDetails(action : any) {
  let data = yield call(dnbApi.getXValueQuery,'vi',action.payload, action.meta)
  yield put(actions.getDetailsDnbpviSuccess(data));
}

function* handleDnbPownGetDetails(action : any) {
  let data = yield call(dnbApi.getXValueQuery,'own',action.payload, action.meta)
  yield put(actions.getDetailsDnbpownSuccess(data));
}

function* handleDnbPmlGetDetails(action : any) {
  let data = yield call(dnbApi.getXValueQuery,'ml',action.payload, action.meta)
  yield put(actions.getDetailsDnbpmlSuccess(data));
}

function* handleDnbPclGetDetails(action : any) {
  let data = yield call(dnbApi.getXValueQuery,'cl',action.payload, action.meta)
  yield put(actions.getDetailsDnbpclSuccess(data));
}

function* handleDnbPcrGetDetails(action : any) {
  let data = yield call(dnbApi.getXValueQuery,'cr',action.payload, action.meta)
  yield put(actions.getDetailsDnbpcrSuccess(data));
}

function* handleDnbPlebGetDetails(action : any) {
  let data = yield call(dnbApi.getXValueQuery,'leb',action.payload, action.meta)
  yield put(actions.getDetailsDnbplebSuccess(data));
}

function* handleDnbPlejGetDetails(action : any) {
  let data = yield call(dnbApi.getXValueQuery,'lej',action.payload, action.meta)
  yield put(actions.getDetailsDnbplejSuccess(data));
}

function* handleDnbPlesGetDetails(action : any) {
  let data = yield call(dnbApi.getXValueQuery,'les',action.payload, action.meta)
  yield put(actions.getDetailsDnbplesSuccess(data));
}

function* handleDnbPprGetDetails(action : any) {
  let data = yield call(dnbApi.getXValueQuery,'pr',action.payload, action.meta)
  yield(actions.getDetailsDnbpprSuccess(data));
}

function* handleGetDetails(action : any) {
  try
  {
    const dunsNumber = action.payload;

    const aadState : AADState = yield select(aadStateReference);

    yield all([
      yield call(handleDnbPKycGetDetails,{payload: dunsNumber, meta: aadState.loginAccessToken}),
      yield call(handleDnbPciGetDetails,{payload: dunsNumber, meta: aadState.loginAccessToken}),
      yield call(handleDnbPclGetDetails,{payload: dunsNumber, meta: aadState.loginAccessToken}),
      yield call(handleDnbPownGetDetails,{payload: dunsNumber, meta: aadState.loginAccessToken})
     ])
  } catch (error)
  {
    console.log(error);
  }
}

export function* watchGetDetails() { yield takeEvery(constants.DNB_GET_DETAILS,handleGetDetails); }

export function* watchGetDnbPcrDetails() { yield takeEvery(constants.DNB_GET_DNBPCR,handleDnbPcrGetDetails); }
export function* watchGetDnbPprDetails() { yield takeEvery(constants.DNB_GET_DNBPPR,handleDnbPprGetDetails); }
export function* watchGetDnbPlesDetails() { yield takeEvery(constants.DNB_GET_DNBPLES,handleDnbPlesGetDetails); }
export function* watchGetDnbPlebDetails() { yield takeEvery(constants.DNB_GET_DNBPLEB,handleDnbPlebGetDetails); }
export function* watchGetDnbPlejDetails() { yield takeEvery(constants.DNB_GET_DNBPLEJ,handleDnbPlejGetDetails); }

export function* watchGetDnbPciDetails() {
  yield takeEvery(constants.DNB_GET_DNBPCI,handleDnbPciGetDetails);
}

export function* watchGetDnbPkycDetails() {
  yield takeEvery(constants.DNB_GET_DNBPKYC,handleDnbPKycGetDetails);
}

export function* watchGetDnbPclDetails() {
  yield takeEvery(constants.DNB_GET_DNBPCL,handleDnbPclGetDetails);
}

export function* watchGetDnbPviDetails() {
  yield takeEvery(constants.DNB_GET_DNBPVI,handleDnbPviGetDetails);
}

export function* watchGetDnbPmlDetails() {
  yield takeEvery(constants.DNB_GET_DNBPML,handleDnbPmlGetDetails);
}

export function* watchGetDnbPownDetails() {
  yield takeEvery(constants.DNB_GET_DNBPOWN,handleDnbPownGetDetails);
}


export function* rootSaga() {
  yield all (
    [
      fork(watchGetDetails),
      fork(watchGetDnbPciDetails),
      fork(watchGetDnbPkycDetails),
      fork(watchGetDnbPownDetails),
      fork(watchGetDnbPmlDetails),
      fork(watchGetDnbPclDetails),
      fork(watchGetDnbPviDetails),
      fork(watchGetDnbPcrDetails),
      fork(watchGetDnbPprDetails),
      fork(watchGetDnbPlesDetails),
      fork(watchGetDnbPlebDetails),
      fork(watchGetDnbPlejDetails),
    ]);
}
