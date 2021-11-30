import *  as constants from '../constants';
import { Reducer } from 'redux';
import { DnbDetailState } from './models';

const initialState: DnbDetailState = {
  error: null,
  loading: false,
  dunsNumber: null,
  processId: null,
  dnbpciData: null,
  dnbpciLoading: true,
  dnbpcompData: null,
  dnbpcompLoading: true,
  dnbpkycData: null,
  dnbpkycLoading: true,
  dnbpclData: null,
  dnbpclLoading: true,
  dnbpmlData: null,
  dnbpmlLoading: true,
  dnbpownData: null,
  dnbpownLoading: true,
  dnbpprData: null,
  dnbpprLoading: true,
  dnbpmedData: null,
  dnbpmedLoading: true,
  dnbplesData: null,
  dnbplesLoading: true,
  dnbplejData: null,
  dnbplejLoading: true,
  dnbplebData: null,
  dnbplebLoading: true,
  dnbpcrData: null,
  dnbpcrLoading: true,
  dnbpviData: null,
  dnbAccessToken: null,
  dnbpviLoading: true
}

const reducer: Reducer<DnbDetailState> = ( state = initialState, action) => {
  switch(action.type) {
    case constants.DNB_GET_CLEAR_STATE: {
      return { ...state, loading: true,dunsNumber: null,
        dnbpcompData: null,
        dnbpcompLoading: true,
        dnbpkycData: null,
        dnbpkycLoading: true,
        dnbpclData: null,
        dnbpclLoading: true,
        dnbpmlData: null,
        dnbpmlLoading: true,
        dnbpownData: null,
        dnbpownLoading: true,
        dnbpprData: null,
        dnbpprLoading: true,
        dnbpmedData: null,
        dnbpmedLoading: true,
        dnbplesData: null,
        dnbplesLoading: true,
        dnbplejData: null,
        dnbplejLoading: true,
        dnbplebData: null,
        dnbplebLoading: true,
        dnbpcrData: null,
        dnbpcrLoading: true,
        dnbpviData: null,
        dnbpviLoading: true,
        processId: null,
        dnbAccessToken : null}
    }
    case constants.DNB_GET_DETAILS: {
      return { ...state, loading: true,dunsNumber: action.payload,
        dnbpcompData: null,
        dnbpcompLoading: true,
        dnbpkycData: null,
        dnbpkycLoading: true,
        dnbpclData: null,
        dnbpclLoading: true,
        dnbpmlData: null,
        dnbpmlLoading: true,
        dnbpownData: null,
        dnbpownLoading: true,
        dnbpprData: null,
        dnbpprLoading: true,
        dnbpmedData: null,
        dnbpmedLoading: true,
        dnbplesData: null,
        dnbplesLoading: true,
        dnbplejData: null,
        dnbplejLoading: true,
        dnbplebData: null,
        dnbplebLoading: true,
        dnbpcrData: null,
        dnbpcrLoading: true,
        dnbpviData: null,
        dnbpviLoading: true,
        dnbAccessToken : null}
    }
    case constants.DNB_GET_DNBPCI: {
      return { ...state, dnbpciLoading: true,dunsNumber: action.payload,dnbAccessToken: action.meta}
    }
    case constants.DNB_GET_DNBPCI_SUCCESS: {
      return { ...state, dnbpciLoading: false,dnbpciData: action.payload}
    }

    case constants.DNB_GET_DNBPVI: {
      return { ...state, dnbpviLoading: true,dunsNumber: action.payload,dnbAccessToken: action.meta}
    }
    case constants.DNB_GET_DNBPVI_SUCCESS: {
      return { ...state, dnbpviLoading: false,dnbpviData: action.payload}
    }

    case constants.DNB_GET_DNBPCL: {
      return { ...state, dnbpclLoading: true,dunsNumber: action.payload,dnbAccessToken: action.meta}
    }
    case constants.DNB_GET_DNBPCL_SUCCESS: {
      return { ...state, dnbpclLoading: false,dnbpclData: action.payload}
    }

    case constants.DNB_GET_DNBPML: {
      return { ...state, dnbpmlLoading: true,dunsNumber: action.payload,dnbAccessToken: action.meta}
    }
    case constants.DNB_GET_DNBPML_SUCCESS: {
      return { ...state, dnbpmlLoading: false,dnbpmlData: action.payload}
    }

    case constants.DNB_GET_DNBPOWN: {
      return { ...state, dnbpownLoading: true,dunsNumber: action.payload,dnbAccessToken: action.meta}
    }
    case constants.DNB_GET_DNBPOWN_SUCCESS: {
      return { ...state, dnbpownLoading: false,dnbpownData: action.payload}
    }

    case constants.DNB_GET_DNBPKYC: {
      return { ...state, dnbpkycLoading: true,dunsNumber: action.payload,dnbAccessToken: action.meta}
    }
    case constants.DNB_GET_DNBPKYC_SUCCESS: {
      return { ...state, dnbpkycLoading: false,dnbpkycData: action.payload}
    }
    case constants.DNB_GET_DNBPCOMP: {
      return { ...state, dnbpcompLoading: true,dunsNumber: action.payload,dnbAccessToken: action.meta}
    }
    case constants.DNB_GET_DNBPCOMP_SUCCESS: {
      return { ...state, dnbpcompLoading: false,dnbpcompData: action.payload}
    }
    case constants.DNB_GET_DETAILS_TASK_STARTED: {
      return { ...state, loading: true,processId: action.payload}
    }
    case constants.DNB_GET_DETAILS_SUCCESS: {
      return { ...state, loading: false}
    }
    case constants.DNB_GET_DETAILS_ERROR: {
      return { ...state, loading: false, error: action.payload}
    }

    case constants.DNB_GET_DNBPCR: { return { ...state, dnbpcrLoading: true,dunsNumber: action.payload,dnbAccessToken: action.meta} }
    case constants.DNB_GET_DNBPCR_SUCCESS: { return { ...state, dnbpcrLoading: false,dnbpcrData: action.payload}}
    case constants.DNB_GET_DNBPMED: { return { ...state, dnbpmedLoading: true,dunsNumber: action.payload,dnbAccessToken: action.meta} }
    case constants.DNB_GET_DNBPMED_SUCCESS: { return { ...state, dnbpmedLoading: false,dnbpmedData: action.payload}}
    case constants.DNB_GET_DNBPLEB: { return { ...state, dnbplebLoading: true,dunsNumber: action.payload,dnbAccessToken: action.meta} }
    case constants.DNB_GET_DNBPLEB_SUCCESS: { return { ...state, dnbplebLoading: false,dnbplebData: action.payload}}
    case constants.DNB_GET_DNBPLEJ: { return { ...state, dnbplejLoading: true,dunsNumber: action.payload,dnbAccessToken: action.meta} }
    case constants.DNB_GET_DNBPLEJ_SUCCESS: { return { ...state, dnbplejLoading: false,dnbplejData: action.payload}}
    case constants.DNB_GET_DNBPLES: { return { ...state, dnbplesLoading: true,dunsNumber: action.payload,dnbAccessToken: action.meta} }
    case constants.DNB_GET_DNBPLES_SUCCESS: { return { ...state, dnbplesLoading: false,dnbplesData: action.payload}}
    case constants.DNB_GET_DNBPPR: { return { ...state, dnbpprLoading: true,dunsNumber: action.payload,dnbAccessToken: action.meta} }
    case constants.DNB_GET_DNBPPR_SUCCESS: { return { ...state, dnbpprLoading: false,dnbpprData: action.payload}}


    default:  return { ...state };
  }
}

export { reducer as dnbDetailsReducer}
