import { Store, createStore, applyMiddleware} from 'redux'
import createSagaMiddleware from 'redux-saga';
import { History} from 'history'
import { composeWithDevTools } from 'redux-devtools-extension';
import { ApplicationState } from './applicationState'
import { rootSaga } from './saga'
import { rootReducer} from './reducers'

export function configureStore(initialState: ApplicationState) : Store<ApplicationState> {

    // create composing function
    const composeEnhancers = composeWithDevTools({})
    const sagaMiddleware = createSagaMiddleware()

    const store = createStore(
      rootReducer,
      initialState,
      composeEnhancers(applyMiddleware(sagaMiddleware))
    );

    sagaMiddleware.run(rootSaga);

    if (module.hot) {
        // Enable Webpack hot module replacement for reducers
        module.hot.accept('./reducers', () => {
            const nextRootReducer = require('./reducers');
            store.replaceReducer(nextRootReducer);
        });
    }

    return store;
}
