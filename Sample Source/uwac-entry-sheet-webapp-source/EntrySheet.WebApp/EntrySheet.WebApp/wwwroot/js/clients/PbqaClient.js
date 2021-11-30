function pbqaClient(config, blade) {

    return {
        getContractExceptionCodes: getContractExceptionCodes
    };
    function getContractExceptionCodes(placingType, groupClass,access_token) {
        return riskEntrySheet.utils.azureAjaxWithToken({
            clientId: config.pbqaApi.clientId,
            scope: config.pbqaApi.scope,
            type: "GET",
            url: `${config.pbqaApi.baseUrl}/questions/eclipse/${placingType}/${groupClass}`,
            data: null,
            access_token: access_token,
            errorMessage: "Failed to get contract exception codes."
        });
    }


}