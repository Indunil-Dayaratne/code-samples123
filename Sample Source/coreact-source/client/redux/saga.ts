
import { all, fork } from 'redux-saga/effects';

import * as dnbSagas from './dnb/dnbRemoteSearch/saga';
import * as dnbDetailSagas from './dnb/dnbDetail/saga';
import * as processSagas from './process/saga';
import * as aadSagas from './aad/saga';
export function* rootSaga() {
  yield all([
    fork(dnbSagas.rootSaga),
    fork(processSagas.rootSaga),
    fork(aadSagas.rootSaga),
    fork(dnbDetailSagas.rootSaga)
  ]);
}
