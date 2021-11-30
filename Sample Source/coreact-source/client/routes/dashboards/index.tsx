import * as React from 'react'
import { Redirect, Route, Switch } from 'react-router-dom';

import {DefaultDashboard} from './default';
import error from '../layouts/error';
const Dashboards = ({ match }) => (
  <Switch>
      <Redirect exact from={`${match.url}/`} to={`${match.url}/default`} />
      <Route path={`${match.url}/default`} component={DefaultDashboard} />
      <Route path={`/error`} component={error} />

  </Switch>
);
export default Dashboards;
