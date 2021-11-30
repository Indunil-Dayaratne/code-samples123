import {
 AAD_LOGIN,
 AAD_LOGIN_SUCCESS,
 AAD_CALLBACK_PROCESSED,
 AAD_ACCESS_TOKEN_RECEIVED,
 AAD_LOGIN_ERROR,
 AAD_ACQUIRE_ACCESS_TOKEN
} from './constants';

import { channel, delay, SagaIterator } from 'redux-saga';
import { all, call, fork, put, takeEvery, select, take , takeLatest} from 'redux-saga/effects'
import * as models from './models';
import * as actions from './actions';
import { PayloadAction } from 'typesafe-actions/dist/types';
import * as Msal from 'msal';
import * as defaultValues from '../../constants/defaultValues'
import * as jwtDecode from 'jwt-decode';

const processStateReference = (state) => {
  return state.aad;
}

let userAgentApplication: Msal.UserAgentApplication;

export function* accessTokenReceived(action: any): any {
  yield delay(600000);
  yield call(acquireNewAccessToken, action.scopes);
}

export function* acquireNewAccessToken(action : any): SagaIterator {
  try {
      const accessToken: string = yield (userAgentApplication.acquireTokenSilent(
          action.payload as string[],
          defaultValues.azureAadAuthorityUrl,
          userAgentApplication.getUser(),
      ) as any);

      //const decodedToken: any = jwtDecode(accessToken);
      const scopes: any = action.payload;

      yield put({
          type: AAD_ACCESS_TOKEN_RECEIVED,
          accessToken,
          scopes,
          user: {
              ...userAgentApplication.getUser(),
              roles: [],
          },
      });
  } catch (error) {
      console.log(error);
      yield put({ type: AAD_LOGIN_ERROR, error });
  }
}


function *login() {
  if(userAgentApplication.isCallback(window.location.hash)) {
    yield put({ type: AAD_LOGIN_SUCCESS});
  }

  const user = userAgentApplication.getUser();
  const currentTime = Math.ceil(Date.now() / 1000);
  const tokenExpired = user ? ((user.idToken as any).exp < currentTime) : false;

  const loginStatusChannel = channel();

  if (user && !tokenExpired) {
    yield call(acquireNewAccessToken, { payload: defaultValues.azureAadScope}  as PayloadAction<"AAD_LOGIN",any>);
  } else {
    userAgentApplication.loginRedirect(defaultValues.azureAadScope);
  }

}

export function* loginSaga(action: PayloadAction<"AAD_LOGIN",any>): SagaIterator {
  const mergedOptions = {
      redirectUri: action.payload.redirectUrl,
      // Avoid redirection on url callback
      navigateToLoginRequestUrl: false,
      ...action.payload.options,
      //cacheLocation: 'localStorage'
  };

  // @ts-ignore
  userAgentApplication = new Msal.UserAgentApplication(action.payload.clientId, action.payload.authorityUrl,null, mergedOptions);

  yield all([
      takeLatest(AAD_ACCESS_TOKEN_RECEIVED, accessTokenReceived),
      call(login),
  ]);
}

export function* watchAADLogin() {
  yield takeEvery(AAD_LOGIN,loginSaga);
  yield takeEvery(AAD_ACQUIRE_ACCESS_TOKEN,acquireNewAccessToken);
}

export function* rootSaga() {
  yield all ([fork(watchAADLogin)]);
}
