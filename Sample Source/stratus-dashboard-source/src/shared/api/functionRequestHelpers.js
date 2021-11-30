import Vue from 'vue';

async function getToken() {
    let token = await Vue.prototype.$AuthService.getToken();
    return token.accessToken || token.idToken.rawIdToken;
}

async function getAuthorizationHeader() {
    return {
        headers: {
            "Authorization": `Bearer ${await getToken()}`
        },
        xhrFields: {
            withCredentials: true
        }
    };
}

async function addTokenToUrlAsParameter(url) {
    const linkContainsParams = url.search(/\?/g) >= 0;
    let prefix = linkContainsParams ? '&' : '?';
    prefix += 'token=';
    const token = await getToken();
    return url + prefix + token;
}

async function navigateWithToken(url) {
    const tokenedUrl = await addTokenToUrlAsParameter(url);
    window.open(tokenedUrl,'_blank');
}

export default {
    getToken,
    getAuthorizationHeader,
    navigateWithToken,
    addTokenToUrlAsParameter
}