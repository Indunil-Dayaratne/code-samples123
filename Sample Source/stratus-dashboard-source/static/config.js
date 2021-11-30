/* eslint-disable no-unused-vars */

// eslint-disable-next-line no-var
'use strict'
var config = {

    clientid: "6c83a059-c43b-46b5-a26d-846e05c54948",
    redirecturl: "http://localhost:8080/callback",
    authority: "https://login.microsoftonline.com/britinsurance.com",
    graphscopes: ["openid"],
    graphendpoint: "https://graph.microsoft.com/v1.0/me",
    appinsightsid: "6924dd9f-710d-472e-a730-2f9854552f2c",
    azureTableStore: {
      account: "stratusuksdev",
      key: "yNXeM7wPIHYeflunoflmh3vWrFHBpPcbtsfUhj4Ic5ormj9jVzNwsbg7jjM3wsVlphWFycKzCLk2ihCt2wt5+Q=="
    },
    appPrefix: "stratus",
    dateFormat: "DD-MM-YYYY HH:mm:ss",
    runDelayUntilHour: 19,
    kickStartLogicAppEndpoint: "https://prod-22.uksouth.logic.azure.com:443/workflows/06db4020ebfc4690acaf1fa112d42df0/triggers/manual/paths/invoke?api-version=2018-07-01-preview&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=v6cS4qh68dvBujDHkpiq0zH2TRhl0iELRFdZ70IXrNg",
    importEltLogicAppEndpoint: "https://prod-15.uksouth.logic.azure.com:443/workflows/9bfa37164dad41eea6a957cc1baac23c/triggers/manual/paths/invoke?api-version=2018-07-01-preview&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=PyMGWeLYYa2czFsKMBrowOVrtH3UlBewCfgLgTOiRxo",
    runClfAnalysisLogicAppEndpoint: "https://prod-15.uksouth.logic.azure.com:443/workflows/46be8c2305824dc49f0a4c7cc852210e/triggers/manual/paths/invoke?api-version=2018-07-01-preview&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=ritbJLMM93i1J8yNspOxe7DLDqAVNTgoDW9tIY7FWNA",
    runCedeAnalysisLogicAppEndpoint: "https://prod-14.uksouth.logic.azure.com:443/workflows/62c0a0bda767480ab4e2f5307ec776dc/triggers/manual/paths/invoke?api-version=2018-07-01-preview&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=DXkXNnXxXJgrC-hWmm9iuQ46RzNty3wMI5EtsLwtIwQ",
    uploadClfYeltLogicAppEndpoint: "https://prod-10.uksouth.logic.azure.com:443/workflows/fcdb13fcd78f4b3496eec9608adf7038/triggers/manual/paths/invoke?api-version=2018-07-01-preview&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=BKz5W0lUzHhc279s4zYDqt6SAv9n262od4ig9Qdo4cs",
    uploadCedeYeltLogicAppEndpoint: "https://prod-03.uksouth.logic.azure.com:443/workflows/b3a2800734254416b1a871dc3993dea2/triggers/manual/paths/invoke?api-version=2018-07-01-preview&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=ppDVX57pfwtXWN2jEbq59BO42G34hxacgQfJwh5LNsk",
    grapheneFunctionAppUrl: "https://stratus-graphene-func-test.azurewebsites.net",  
    taskFunctionAppUrl: "https://stratus-ts-func-test.azurewebsites.net",
    loadStructureFunctionEndpoint: "/api/GetNetwork",
    saveStructureFunctionEndpoint: "/api/SaveNetwork",
    runPricingCalculationFunctionEndpoint: "/api/RunNetworkCalculations",
    getNodeResultFromBlobStorage: "/api/GetNodeResultFromBlobStorage",
    downloadYeltEndpoint: "/api/DownloadYelt",
    getYeltByEventEndPoint: "/api/GetYelts",
    getEventIdsForNetworkEndPoint: "/api/GetEventIds",
    getExchangeRatesEndPoint: '/api/GetExchangeRates',
    uploadExchangeRatesEndPoint: '/api/UploadExchangeRates',
    queueStatusEndPoint: "/api/QueueStatus",
    runPricingAnalysisLogicAppEndpoint: "https://prod-22.uksouth.logic.azure.com:443/workflows/989622d0c8d942ca8038141c9362eb4c/triggers/manual/paths/invoke?api-version=2018-07-01-preview&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=QJJv0bh9hWxM6KLkKFkkwSYwjInKoxRweviJTlbP9gg",
    getEventSetsLogicAppEndpoint: "https://prod-23.uksouth.logic.azure.com:443/workflows/c3f4306e89a645a2999d59000e699023/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=rA9hhb9lyBGxf47Z897Bxjgqa3zLQl2iA1YfeMg6RHs",
    uploadSimulationSetLogicAppEndpoint: "https://prod-28.uksouth.logic.azure.com:443/workflows/b83e4d25d19b4e6caceaeb7598a5e755/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=0XuVBgDpNOjGh-8GQ_o2_hqU_WcwKAzkxR-uv_fCbUg",
    generateSimulationSetLogicAppEndpoint: "https://prod-19.uksouth.logic.azure.com:443/workflows/5974391638084bc0b05d9a1207f386f5/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=RTa238LWXcY7JKb88DGuq20IdfRBb9c6i5SeSDSxhTM",
    refreshDayDistributionsLogicAppEndpoint: "https://prod-23.uksouth.logic.azure.com:443/workflows/105dfdf1c3e04e7aac6ea0d566fd59d2/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=A50BzBQr0KlR4zhYloBxQYDIrWsOmx8ndq6lFBfO_DU",
    convertEltLogicAppEndpoint: "https://prod-00.uksouth.logic.azure.com:443/workflows/9927eba7caa947a1b8cd1378564164df/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=ho06xlGrXOySF6MfP8JDYNqrHh5bY6bnI9Ej--vDYms",
    exportToPrimeLogicAppEndpoint: "[EXPORTTOPRIME_LOGICAPP_ENDPOINT]",
    primeCatalogUrl: 'https://brit-api.analyzere.net/event_catalogs',
    primeToken: 'ZGF2aWQubWVsbDpCcml0MDEhIT8/',
    getFileLogicAppEndpoint: 'https://prod-10.uksouth.logic.azure.com:443/workflows/5bbc431f13c7470fa2ed30b55e4faa3c/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=ogoCFZNuLo3UQ2C4k0I4RCLJSIB3iFyneeGeck4USFY',
    kickstartFileLogicAppEndpoint: 'https://prod-29.uksouth.logic.azure.com:443/workflows/fd75f5a06cf94451adfdd5dda0ce72b6/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=vpj0OomtEcNNkJt4yoQmVZ5bpXuDId7rYx3k97b3_ig',
    downloadYeltLogicAppEndpoint: 'https://prod-16.uksouth.logic.azure.com:443/workflows/99b5374a23a447e8accd986991c29619/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=aghGE0cezq2RJ-3T6waLsPB6JJx67etDj9yCk5sLEuI'
  }
