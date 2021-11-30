import {
  AAD_LOGIN_SUCCESS,
  AAD_LOGOUT_SUCCESS,
  AAD_LOGIN,
  AAD_LOGIN_ERROR,
  AAD_ACCESS_TOKEN_RECEIVED,
  AAD_ACQUIRE_ACCESS_TOKEN,
  AAD_CALLBACK_PROCESSED
} from './constants';

import { Reducer } from 'redux';
import { AADState } from './models';
import { isNullOrUndefined } from 'util';


const initialState : AADState =  {
    loginAccessToken: null,
    acquireAccessToken: null,
    user: null,
    options: null,
    acquireAccessTokenScope: null
}

const reducer: Reducer<AADState> = ( state = initialState, action) => {
  switch(action.type) {
    case AAD_LOGIN: {
      return { ...state,options : action.payload}
    }
    case AAD_ACQUIRE_ACCESS_TOKEN: {
      return { ...state,acquireAccessTokenScope: action.payload}
    }
    case AAD_LOGIN_SUCCESS: {
      return { ...state, aadResponse: action.payload}
    }
    case AAD_ACCESS_TOKEN_RECEIVED: {
      const accessTokenReceivedAction = action;

      return {
        ...state,
        loginAccessToken: accessTokenReceivedAction.accessToken,
        acquireAccessTokenScope: null,
        user: accessTokenReceivedAction.user,
      }


    }
    case AAD_LOGOUT_SUCCESS: {
      return { ...state, aadResponse: isNullOrUndefined}
    }
    case AAD_LOGIN_ERROR: {
      return { ...state, loading: false, error: action.payload}
    }
    default:  return { ...state };
  }
}

export { reducer as aadReducer}
