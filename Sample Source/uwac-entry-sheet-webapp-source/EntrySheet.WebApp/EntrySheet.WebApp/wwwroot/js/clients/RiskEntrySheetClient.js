function riskEntrySheetClient(config, blade) {

    return {
        getRiskEntrySheetDetails: getRiskEntrySheetDetails,
        getEPlacingList: getEPlacingList,
        getReportingCcyList: getReportingCcyList,
        getIndustryCodes: getIndustryCodes,
        getRiskRatings: getRiskRatings,
        saveRiskEntrySheet: saveRiskEntrySheet
    };

    function getRiskEntrySheetDetails(britPolicyId) {
        return riskEntrySheet.utils.azureAjax({
            clientId: config.entrySheetApi.clientId,
            scope: config.entrySheetApi.scope,
            type: "GET",
            url: `${config.entrySheetApi.baseUrl}/entrysheet/policy/${britPolicyId}`,
            data: null,
            errorMessage: "Unable to fetch policy risk details."
        });
    }
    function getEPlacingList() {
        return riskEntrySheet.utils.azureAjax({
            clientId: config.entrySheetApi.clientId,
            scope: config.entrySheetApi.scope,
            type: "GET",
            url: `${config.entrySheetApi.baseUrl}/EntrySheet/ePlacing`,
            data: null,
            errorMessage: "Unable to fetch e-placing details."
        });
    }

    function getIndustryCodes() {
        return riskEntrySheet.utils.azureAjax({
                clientId: config.entrySheetApi.clientId,
                scope: config.entrySheetApi.scope,
                type: "GET",
            url: `${ config.entrySheetApi.baseUrl}/EntrySheet/industryCodes`,
                data: null,
                errorMessage: "Unable to fetch Industry codes."
            });
        }
    function getReportingCcyList() {
        return riskEntrySheet.utils.azureAjax({
            clientId: config.entrySheetApi.clientId,
            scope: config.entrySheetApi.scope,
            type: "GET",
            url: `${config.entrySheetApi.baseUrl}/EntrySheet/currencies`,
            data: null,
            errorMessage: "Unable to fetch currency details."
        });
    }

    function getRiskRatings() {
        return riskEntrySheet.utils.azureAjax({
            clientId: config.entrySheetApi.clientId,
            scope: config.entrySheetApi.scope,
            type: "GET",
            url: `${config.entrySheetApi.baseUrl}/EntrySheet/riskratings`,
            data: null,
            errorMessage: "Unable to fetch risk ratings."
        });
    }

    function saveRiskEntrySheet(entrySheetModel) {
        return riskEntrySheet.utils.azureAjax({
            clientId: config.entrySheetApi.clientId,
            scope: config.entrySheetApi.scope,
            type: "POST",
            url: `${config.entrySheetApi.baseUrl}/entrysheet/policy`,
            data: entrySheetModel,
            errorMessage: "Unable to save policy risk details."
        });
    }
}