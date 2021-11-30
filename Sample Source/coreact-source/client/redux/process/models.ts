import * as types from '../../types/types';

export interface ProcessEndpoint {
  name: string,
  topicName : types.Nullable<string>,
  type: types.Nullable<string>,
  urlFragment: types.Nullable<string>
}

export interface ProcessTypeItem {
  name: string;
  id: string,
  endpoints: types.Nullable<ProcessEndpoint[]>
}

export interface ProcessState {
  readonly processTypes: ProcessTypeItem[],
  readonly processType: types.Nullable<ProcessTypeItem>,
  readonly processTypeName: types.Nullable<string>
}
