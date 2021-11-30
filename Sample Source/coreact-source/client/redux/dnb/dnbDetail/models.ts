import * as types from '../../../types/types';
export interface DnbDetailState {
  readonly processId: types.Nullable<string>;
  readonly dunsNumber:  types.Nullable<string>;
  readonly loading: boolean;
  readonly error: types.Nullable<string>;
  readonly dnbpciData: types.Nullable<any>;
  readonly dnbpciLoading: boolean;
  readonly dnbpkycData: types.Nullable<any>;
  readonly dnbpkycLoading: boolean;

  readonly dnbpviData: types.Nullable<any>;
  readonly dnbpviLoading: boolean;

  readonly dnbpclData: types.Nullable<any>;
  readonly dnbpclLoading: boolean;

  readonly dnbpmlData: types.Nullable<any>;
  readonly dnbpmlLoading: boolean;

  readonly dnbpownData: types.Nullable<any>;
  readonly dnbpownLoading: boolean;

  readonly dnbpcompData: types.Nullable<any>;
  readonly dnbpcompLoading: boolean;

  readonly dnbpprData: types.Nullable<any>,
  readonly dnbpprLoading: boolean,
  readonly dnbpmedData: types.Nullable<any>,
  readonly dnbpmedLoading: boolean,
  readonly dnbplesData: types.Nullable<any>,
  readonly dnbplesLoading: boolean,
  readonly dnbplejData: types.Nullable<any>,
  readonly dnbplejLoading: boolean,
  readonly dnbplebData: types.Nullable<any>,
  readonly dnbplebLoading: boolean,
  readonly dnbpcrData: types.Nullable<any>,
  readonly dnbpcrLoading: boolean,
  readonly dnbAccessToken: types.Nullable<string>
};

export interface signalRMessage {
  status: string,
  processId: string,
  endpoint: string
}
