import * as React from 'react';
import { Provider } from 'react-redux';
import { Router, Route, Switch } from 'react-router-dom';
import { configureStore } from './redux/store';
import { createBrowserHistory } from 'history';

import App from './containers/App';

import { AppProvider } from '@shopify/polaris';

const theme = {
  colors: {
    topBar: {
      background: '#357997',
    },
  },

};

const history = createBrowserHistory();

export { history };

const store = configureStore(window.initialReduxState)

const MainApp = () => (
    <AppProvider theme={theme}>
      <Provider store={store}>
          <Router history={history} >
            <Route path="/" component={App} />
          </Router>
      </Provider>
    </AppProvider>
);

export default MainApp;
