export default {
  clientid: process.env.CLIENT_ID,
  redirecturl: process.env.REDIRECT_URL,
  authority: process.env.AUTHORITY,
  graphscopes: ['openid'],
  graphendpoint: 'https://graph.microsoft.com/v1.0/me',
  appinsightsid: process.env.APP_INSIGHTS_ID,
  azureTableStore: {
    account: process.env.AZ_TABLE_STORE_ACCOUNT,
    key: process.env.AZ_TABLE_STORE_KEY
  },
  appPrefix: process.env.APP_PREFIX,
  dateFormat: 'DD-MM-YYYY HH:mm:ss',
  kickStartLogicAppEndpoint: process.env.KS_LOGICAPP_ENDPOINT,
  importEltLogicAppEndpoint: process.env.IMPORTELT_LOGICAPP_ENDPOINT
}