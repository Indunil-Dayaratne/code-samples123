import * as Msal from 'msal';
import * as defaultValues from '../constants/defaultValues'

export default class MsalService {
  app : any;
  applicationConfig: any;

  loginCallback = (errorDesc, token, error, tokenType) => {
    console.log("user state " + token);
  }

  constructor() {
    let PROD_REDIRECT_URI = defaultValues.defaultUrl;
    let redirectUri = window.location.origin;
    if (window.location.hostname !== 'localhost') {
      redirectUri = PROD_REDIRECT_URI;
    }

    this.app = new Msal.UserAgentApplication(
      defaultValues.azureAadClientID,
      defaultValues.azureAadAuthorityUrl,
      this.loginCallback,
      {
        redirectUri: defaultValues.azureAadRedirectUrl,
        cacheLocation: 'localStorage'
      }
    );
  }
  login = () => {
    return this.app.loginRedirect(defaultValues.azureAadScope);
  };
  logout = () => {
    this.app.logout();
  };
  getToken = (scope: []) => {
    return this.app.acquireTokenSilent(scope).then(
      accessToken => {
        return accessToken;
      },
      error => {
        return this.app
          .acquireTokenPopup(this.applicationConfig.graphScopes)
          .then(
            accessToken => {
              return accessToken;
            },
            err => {
              console.error(err);
            }
          );
      }
    );
  };
}
