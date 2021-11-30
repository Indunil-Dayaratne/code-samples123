import * as Msal from 'msal';

export default class AuthService {

  constructor() {
    let PROD_REDIRECT_URI = config.redirecturl;
    let redirectUri = window.location.origin;
    if (window.location.hostname !== '127.0.0.1') {
      redirectUri = PROD_REDIRECT_URI;
    }

    this.applicationConfig = {
      auth: {
        clientId: config.clientid,
        authority: config.authority,
        scopes: [config.clientid],
        redirectUri: config.redirecturl
      },
      cache: {
        cacheLocation: 'localStorage',
        storeAuthStateInCookie: false
      }
    };

    this.app = new Msal.UserAgentApplication(this.applicationConfig);
    this.app.handleRedirectCallback(this.handleRedirectCallback);
    this.getToken = this.getToken.bind(this);
    this.loginRedirect = this.loginRedirect.bind(this);
  }

  handleRedirectCallback(error, repsonse) {
  }

  // Core Functionality
  loginPopup() {
    return this.app.loginPopup(config.scopes).then(
      idToken => {
        const user = this.app.getUser();
        if (user) {
          return user;
        } else {
          return null;
        }
      },
      () => {
        return null;
      }
    );
  }

  loginRedirect() {
    this.app.loginRedirect(this.applicationConfig.auth.scopes);
  }

  logout() {
    this.app._user = null
    this.app.logout()
  }

  getToken() {
    return this.app.acquireTokenSilent({scopes: [this.applicationConfig.auth.clientId]})
    .then(
      accessToken => {
        return accessToken
      },
      error => {
        return this.app
          .acquireTokenPopup({scopes: [this.applicationConfig.auth.clientId]})
          .then(
            accessToken => {
              return accessToken
            },
            err => {
              console.error(err)
            }
          )
      }
    )
  }

  getGraphUserInfo(token) {
    const headers = new Headers({ Authorization: `Bearer ${token}` });
    const options = {
      headers
    };
    return fetch(`${this.graphUrl}`, options)
      .then(response => response.json())
      .catch(response => {
        throw new Error(response.text());
      });
  }

  // Utility
  getUser() {
    return this.app.getAccount();
  }
}
