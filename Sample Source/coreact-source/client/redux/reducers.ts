
import { Store, createStore, applyMiddleware, compose , Dispatch, Action, AnyAction, combineReducers} from 'redux'
import { dnbRemoteSearchReducer } from './dnb/dnbRemoteSearch/reducer';
import { processReducer } from './process/reducer';
import { ApplicationState} from './applicationState'
import { aadReducer } from './aad/reducer';
import { dnbDetailsReducer} from './dnb/dnbDetail/reducer';
export interface ConnectedReduxProps<A extends Action = AnyAction> {
  dispatch: Dispatch<A>
}

export const rootReducer = combineReducers<ApplicationState>({
  dnbRemoteSearch: dnbRemoteSearchReducer,
  dnbDetail: dnbDetailsReducer,
  process: processReducer,
  aad: aadReducer
});
