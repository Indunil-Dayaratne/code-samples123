import * as React from 'react'
import { Redirect, Route, Switch ,} from 'react-router-dom';

import DnbListApplication from './dnb/dnbList';
import DnbDetailsApplication from './dnb/dnbDetail';
import error from '../layouts/error';
const Applications = ({ match }) => (
  <Switch>
      <Route
        path={`${match.url}/dnb/:dunsnumber`}
        component={DnbDetailsApplication}
      />
      <Route path={`${match.url}/dnb`} component={DnbListApplication} />

      <Route path={`/error`} component={error} />
  </Switch>
);
export default Applications;
