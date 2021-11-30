import {
  PROCESS_TYPE_GET,
  PROCESS_TYPE_GET_ERROR,
  PROCESS_TYPE_GET_SUCCESS
} from './constants';import { all, call, fork, put, takeEvery, select, take } from 'redux-saga/effects'
import * as models from './models';
import * as actions from './actions';
import { PayloadAction } from 'typesafe-actions/dist/types';
import * as apiFunctions from './api'
import { AADState } from 'client/redux/aad/models';
const processStateReference = (state) => {
  return state.process;
}

const aadStateReference = (state) => {
  return state.aad;
}

export function* handleProcessTypeGet(action: PayloadAction<"PROCESS_TYPE_GET",string>) {
  try
  {
    // check whether the processType currently exists
    const aadState : AADState = yield select(aadStateReference);

    let processState : models.ProcessState = yield select(processStateReference);

    // find process type
    let processType = processState.processTypes
      .find((item : models.ProcessTypeItem) => item.name.toLowerCase() === action.payload.toLowerCase()) as models.ProcessTypeItem;

    // if not exists in state request from server
    if(processType == null)
      processType = yield call(apiFunctions.getProcessType,action.payload as any,aadState.loginAccessToken as any);

    // update state
    yield put(actions.processTypeSuccess(processType));

    // return result
    return processType;
  }
  catch (err)
  {
    if(err instanceof Error) {
      yield put(actions.processTypeError(err.stack!));
    } else {
      yield put(actions.processTypeError('An unknown error has occured'));
    }
  }
}

export function* watchProcessTypeGet() {
  yield takeEvery(PROCESS_TYPE_GET,handleProcessTypeGet);
}

export function* rootSaga() {
  yield all ([fork(watchProcessTypeGet)]);
}
