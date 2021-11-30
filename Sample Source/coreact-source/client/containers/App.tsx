import * as React from 'react';

import { Redirect, Route, Switch} from 'react-router-dom';

import error from '../routes/layouts/error';

import * as MainRoute from '../routes/index'


class App extends React.Component<any> {

  render() {
    const { location, match } = this.props;

    return(
      <React.Fragment>
          <Switch>
            <Route path={`/`} component={MainRoute.default} />
            <Route path={`/error`} component={error} />
          </Switch>
      </React.Fragment>
    )
  }
}

export default App;
