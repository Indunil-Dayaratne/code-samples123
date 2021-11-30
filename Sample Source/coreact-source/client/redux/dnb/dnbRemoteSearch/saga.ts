import {
  DNB_REMOTESEARCH_GET,
  DNB_REMOTESEARCH_GET_DETAILS
} from '../constants';

import { all, call, fork, put, takeEvery, select, take , takeLatest} from 'redux-saga/effects'
import * as models from '../models';
import * as actions from './actions';
import { dnbApi } from '../dnbApi';
import { history} from '../../../App'
import * as jq from 'jsonq'
import { AADState } from 'client/redux/aad/models';

const extractJsonData = (data: any,objectNameToExtract: string) : Array<any> => {
  let jqO = jq.default(data);

  let findResult = jqO.find(objectNameToExtract);

  return findResult.value();
}

const aadStateReference = (state) => { return state.aad; }

function* handleRemoteSearch(action : any) {
  try
  {
    const options : models.DnbRemoteSearchOptions = action.payload;

    const aadState : AADState = yield select(aadStateReference);

    let searchResults = yield call(dnbApi.getRemoteSearch,
      options.searchKeyword as string ,
      options.selectedCountry as string,
      options.selectedActive,aadState.loginAccessToken as string);

    yield put(actions.remoteSearchSuccess(extractJsonData(searchResults,'MatchCandidate')[0]));
  } catch (err)
  {
    if(err instanceof Error) {
      yield put(actions.remoteSearchError(err.stack!));
    } else {
      yield put(actions.remoteSearchError('An unknown error has occured'));
    }
  }
}

function forwardTo(url : string) {
  history.push(url);
}

export function* handleGetDetails(action: any) {
  try
  {
    const item = action.payload as any;

    const url = "/dnb/"+ item.DUNSNumber;
    yield call(forwardTo,url);
  }
  catch(error) {
    console.log(error);
  }
}

export function* watchGetDetails() {
  yield takeEvery(DNB_REMOTESEARCH_GET_DETAILS,handleGetDetails);
}

export function* watchRemoteSearch() {
  yield takeEvery(DNB_REMOTESEARCH_GET,handleRemoteSearch);
}

export function* rootSaga() {
  yield all ([fork(watchRemoteSearch),fork(watchGetDetails)]);
}
