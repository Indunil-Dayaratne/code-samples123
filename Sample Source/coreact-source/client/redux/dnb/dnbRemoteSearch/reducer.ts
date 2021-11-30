

import {
  DNB_REMOTESEARCH_GET,
  DNB_REMOTESEARCH_GET_ERROR,
  DNB_REMOTESEARCH_GET_SUCCESS,
  DNB_REMOTESEARCH_GET_DETAILS
} from '../constants';


import { Reducer } from 'redux';

import { DnbRemoteSearchState } from '../models';

const initialState: DnbRemoteSearchState = {
  allItems: [],
  error: null,
  loading: false,
  selectedRemoteSearchItem: null,
  searchOptions: null
}

const reducer: Reducer<DnbRemoteSearchState> = ( state = initialState, action) => {
  switch(action.type) {
    case DNB_REMOTESEARCH_GET: {
      return { ...state, loading: true,allItems:[],selectedRemoteSearchItem: null,searchOptions: action.payload}
    }
    case DNB_REMOTESEARCH_GET_SUCCESS: {
      return { ...state, loading: false, allItems: action.payload }
    }
    case DNB_REMOTESEARCH_GET_DETAILS: {
      return { ...state, selectedRemoteSearchItem: action.payload}
    }
    case DNB_REMOTESEARCH_GET_ERROR: {
      return { ...state, loading: false, error: action.payload}
    }
    default:  return { ...state };
  }
}

export { reducer as dnbRemoteSearchReducer}

