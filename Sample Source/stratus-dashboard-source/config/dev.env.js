'use strict'
const merge = require('webpack-merge')
const prodEnv = require('./prod.env')

module.exports = merge(prodEnv, {
  NODE_ENV: '"development"',
  APP_PREFIX: '"stratus"',
  CLIENT_ID: '"9e113eea-36c8-49b6-833c-ffede71410e7"',
  REDIRECT_URL: '"http://localhost:8080/callback"',
  AUTHORITY: '"https://login.microsoftonline.com/britinsurance.com"',
  DATE_FORMAT: '"DD-MM-YYYY HH:mm:ss"',
  KS_LOGICAPP_ENDPOINT: '"https://prod-22.uksouth.logic.azure.com:443/workflows/06db4020ebfc4690acaf1fa112d42df0/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=v6cS4qh68dvBujDHkpiq0zH2TRhl0iELRFdZ70IXrNg"',
  IMPORTELT_LOGICAPP_ENDPOINT: '"https://prod-15.uksouth.logic.azure.com:443/workflows/9bfa37164dad41eea6a957cc1baac23c/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=PyMGWeLYYa2czFsKMBrowOVrtH3UlBewCfgLgTOiRxo"',
  AZ_TABLE_STORE_ACCOUNT: '"stratusuksdev"',
  AZ_TABLE_STORE_KEY: '"yNXeM7wPIHYeflunoflmh3vWrFHBpPcbtsfUhj4Ic5ormj9jVzNwsbg7jjM3wsVlphWFycKzCLk2ihCt2wt5+Q=="',
  APPINSIGHTS_INSTRUMENTATIONKEY: '"6924dd9f-710d-472e-a730-2f9854552f2c"'
})
