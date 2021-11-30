import * as types from '../../types/types';
import * as searchTypes from './dnbRemoteSearch/models';

export interface DnbRemoteSearchState {
  readonly allItems: Array<any>[];
  readonly selectedRemoteSearchItem : types.Nullable<Array<any>>;
  readonly error: types.Nullable<string>;
  readonly loading: boolean;
  readonly searchOptions: types.Nullable<DnbRemoteSearchOptions>;
};
export interface DnbRemoteSearchOptions {
  searchKeyword: types.Nullable<string>;
  selectedCountry: types.Nullable<string>;
  selectedActive: boolean;
}
