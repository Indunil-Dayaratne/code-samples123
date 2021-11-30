import {
  PROCESS_TYPE_GET,
  PROCESS_TYPE_GET_ERROR,
  PROCESS_TYPE_GET_SUCCESS
} from './constants';

import * as types from '../../types/types';

import { Reducer } from 'redux';

import { ProcessState } from './models';
import { processTypeSuccess } from './actions';

const initialState: ProcessState = {
  processTypes: [],
  processType: null,
  processTypeName: null
}

const reducer: Reducer<ProcessState> = ( state = initialState, action) => {
  switch(action.type) {
    case PROCESS_TYPE_GET: {
      return { ...state, loading: true,processType: action.payload}
    }
    case PROCESS_TYPE_GET_SUCCESS: {
      // add if process item doesnt exist
      if(state.processTypes.filter(x => x.name === action.payload.name).length === 0)
        state.processTypes.push(action.payload);

      return { ...state, loading: false, processType: action.payload}
    }
    case PROCESS_TYPE_GET_ERROR: {
      return { ...state, loading: false, error: action.payload}
    }
    default:  return { ...state };
  }
}

export { reducer as processReducer}
