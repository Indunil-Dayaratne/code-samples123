import * as React from 'react';
import { Route, withRouter, Switch, Redirect, RouteComponentProps } from 'react-router-dom';
import { connect } from "react-redux";
import * as defaultValues from '../constants/defaultValues'
import { loginSuccess, login } from '../redux/aad/actions'
import DnbListApplication from './applications/dnb/dnbList';
import DnbDetailsApplication from './applications/dnb/dnbDetail';
import error from '../routes/layouts/error';

import {
  clearItemState
} from '../redux/dnb/dnbDetail/actions';

import {
  Frame,
  Navigation,
  TopBar,
  Stack,
  SkeletonPage,
  Layout,
  Card,
  TextContainer,
  SkeletonBodyText,
  SkeletonDisplayText,
  Loading,
  Button,
  Page
} from '@shopify/polaris';

import { shallowEqual } from '../utils/shallowEqual';
interface IMainAppProps {
  loginSuccess,
  login,
  aad,
  dnbDetail,
  match,
  clearItemState
}

class MainApp extends React.Component<IMainAppProps & RouteComponentProps<any>,any> {
  constructor(props: any) {
    super(props);

    this.azureLogin = this.azureLogin.bind(this);

    this.state = {
      showMobileNavigation: false,
      isLoading: false,
      user:null,
      userInfo: null,
      apiCallFailed: false,
      loginFailed: false
    }
  }

  toggleState = (key) => {
    return () => {
      this.setState((prevState) => ({[key]: !prevState[key]}));
    };
  };

  azureLogin = () => {

    this.props.login({
      clientId: defaultValues.azureAadClientID,
      authorityUrl: defaultValues.azureAadAuthorityUrl,
      redirectUrl: defaultValues.azureAadRedirectUrl,
      options: {}
    });
  }

  render() {
    const { match } = this.props;
    const { loginAccessToken } = this.props.aad;

    const { isLoading, showMobileNavigation } = this.state;

    const loadingMarkup = isLoading ? <Loading /> : null;

    const loadingPageMarkup = (
      <SkeletonPage>
        <Layout>
          <Layout.Section>
            <Card sectioned>
              <TextContainer>
                <SkeletonDisplayText size="small" />
                <SkeletonBodyText lines={9} />
              </TextContainer>
            </Card>
          </Layout.Section>
        </Layout>
      </SkeletonPage>
    );

    const topBarMarkup = (
      <TopBar
        showNavigationToggle={false}
        onNavigationToggle={this.toggleState('showMobileNavigation')}
      />
    )

    const routeMarkup = (
      <Switch>
        <Route
          path={`/dnb/:dunsnumber`}
          component={DnbDetailsApplication}
        />
       <Route path={`/`} component={DnbListApplication} />
      <Route path={`/error`} component={error} />
      </Switch>
    )

    const loginMarkup = (
      <Page fullWidth title="D&B Search">
          <Button primary onClick={() => this.azureLogin() }>Login</Button>
      </Page>
    )

    const authenticatedFrame = (
      <Frame
          showMobileNavigation={showMobileNavigation}
          onNavigationDismiss={this.toggleState('showMobileNavigation')}
      > { routeMarkup } </Frame>
    )

    const unAuthenticatedFrame = (
      <Frame
          showMobileNavigation={showMobileNavigation}
          onNavigationDismiss={this.toggleState('showMobileNavigation')}
      >{ loginMarkup }</Frame>
    )

    return (
       <div> { !loginAccessToken ? unAuthenticatedFrame : authenticatedFrame } </div>
    )
  }
}

const mapStateToProps = ({ aad , dnbDetail}) => {
	return { aad, dnbDetail };
  }

export default withRouter<IMainAppProps & RouteComponentProps<{}>>(connect(mapStateToProps,{ loginSuccess ,login, clearItemState },null,{
  areStatesEqual: (next,prev) => {
    return shallowEqual(next,prev);
  }
})(MainApp) as any);
