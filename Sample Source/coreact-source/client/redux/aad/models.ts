import * as types from '../../types/types';
import { User } from "msal/lib-commonjs/User";

export interface AADState {
  readonly loginAccessToken: types.Nullable<string>
  readonly user: types.Nullable<User>
  readonly options: types.Nullable<any>
  readonly acquireAccessTokenScope: types.Nullable<[]>
  readonly acquireAccessToken: types.Nullable<string>
}
