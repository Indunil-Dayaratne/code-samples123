function britCacheClient(config) {
    
    return {
        getBusinessCodes: getBusinessCodes,
        getPerilGroup: getPerilGroup,
        getResourceADName: getResourceADName,
        getResources: getResources,
        checkUserForEditPolicyRole: checkUserForEditPolicyRole,
        getUWList: getUWList,
        getMajorAndMinorClasses: getMajorAndMinorClasses,
        getBrokerData: getBrokerData,
        getSubClasses: getSubClasses,
        getBrokerContact: getBrokerContact,
        itemsPoliciesForSystem: itemsPoliciesForSystem,
        getIgnisRoles: getIgnisRoles
    };
    function getBusinessCodes(businessCodeName, policyInceptionDate,access_token) {
        return riskEntrySheet.utils.azureAjaxWithToken({
            clientId: config.britCacheClientId,
            scope: config.britCacheScope,
            type: "POST",
            url: config.britCacheBaseUrl + `Eclipse/businesscodes`,
            data: {
                Filter:
                {
                    FilterType: "BusinessCodeFilter",
                    Name: businessCodeName,
                    MaxResults: 500,
                    FilterDate: policyInceptionDate
                }
            },
            access_token: access_token,
            errorMessage: "Unable to fetch business codes from eclipse."
        });
    }

    function getPerilGroup(perilGroupName, policyInceptionDate,access_token) {
        return riskEntrySheet.utils.azureAjaxWithToken({
            clientId: config.britCacheClientId,
            scope: config.britCacheScope,
            type: "POST",
            url: config.britCacheBaseUrl + `Eclipse/perilgroups`,
            data: {
                Filter:
                {
                    FilterType: "PerilGroupFilter",
                    Name: perilGroupName,
                    FilterDate: policyInceptionDate
                }
            },
            access_token: access_token,
            errorMessage: "Unable to fetchperil groups."
        });
    }


    function isCurrentUserInList(users) {
        var result = false;

        if (users) {
            if (Array.isArray(users)) {
                result = users.some(function (user) {
                    return user.Name && user.Name.toLowerCase() ===  riskEntrySheet.currentUser;
                });
            } else {
                result = users.Name && users.Name.toLowerCase() ===  riskEntrySheet.currentUser;
            }
        }

        return result;
    }

    function isCurrentUserInListBUAA(users) {
        var result = false;
        var currentUser =  riskEntrySheet.currentUser.substr( riskEntrySheet.currentUser.indexOf("\\") + 1);
        if (users) {
            result = users && users.Name && users.Name.toLowerCase() === currentUser;
        }
        return result;
    }

    function getResourceADName(serviceInfo, assignedToProperty) {

        if (serviceInfo.items.length > 0) {
            var assignedToUserList = serviceInfo.items.map(function (buaaItem) {
                return buaaItem.AssignedTo.Name;
            });
            assignedToUserList = $.unique(assignedToUserList);
            var url = config.britCacheBaseUrl + '/AD/UserList/';
            return $.ajax({
                crossDomain: true,
                type: "POST",
                dataType: 'json',
                data: JSON.stringify(assignedToUserList),
                xhrFields: {
                    withCredentials: true
                },
                contentType: "application/json",
                url: url,
                success: function (data) {
                    if (data.length > 0) {
                        data.forEach(function (adUser) {
                            var buaaRequests = $.grep(serviceInfo.items, function (n) {
                                return n.AssignedTo.Name == adUser.UserName;
                            });
                            buaaRequests.forEach(function (item) { item.ResourceName = adUser.DisplayName });
                        });
                    }
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    console.log("BritCacheService error getting AD name for user: " + thrownError);
                }
            });
        }
    }

    function getResources() {
        var promise = new $.Deferred();
        acquireMsalSilentToken(config.britCacheClientId, [confgi.britCacheScope]).done(function (access_token) {
            $.ajax({
                crossDomain: true,
                type: "GET",
                xhrFields: {
                    withCredentials: true
                },
                contentType: "application/json; charset=UTF-8",
                accept: "application/json",
                dataType: "json",
                headers: {
                    'Authorization': 'Bearer ' + access_token
                },
                url: config.britCacheBaseUrl + 'AD/users',
                success: function (data) {
                    promise.resolve(data.filter(x => x.IsActive == 1));
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    console.log(`BritCacheService error in getting AD users : ${thrownError}`);
                }
            });
        });
        return promise;
    }

    function checkUserForEditPolicyRole(role, userName) {
        var filter = {
            Filter:
            {
                FilterType: "UserRoleFilter",
                Role: role,
                NTName: userName
            }
        };
        var promise = new $.Deferred();
        acquireMsalSilentToken(config.britCacheClientId, [config.britCacheScope]).then(function (access_token) {

            $.ajax({
                crossDomain: true,
                data: JSON.stringify(filter),
                type: "POST",
                xhrFields: {
                    withCredentials: true
                },
                contentType: "application/json; charset=UTF-8",
                accept: "application/json",
                dataType: "json",
                headers: {
                    'Authorization': 'Bearer ' + access_token
                },
                url: config.britCacheBaseUrl + 'Eclipse/userroles',
                success: function (data) {
                    promise.resolve(data);
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    console.log("BritCacheService error checking UserForEditPolicyRole result: " + thrownError);
                }
            });
        });
        return promise;
    }

    function getUWList(policyContractSection) {
    return riskEntrySheet.utils.azureAjax({
        clientId: config.britCacheClientId,
        scope: config.britCacheScope,
        type: "POST",
        url: config.britCacheBaseUrl + `Eclipse/underwriters`,
        data: {
            Filter: {
                FilterType: "UnderwriterSearchFilter",
                SearchUnderwriter: true,
                YOA: policyContractSection.yoa,
                Syndicate: policyContractSection.syndicate,
                ProducingTeam: policyContractSection.producingTeamValue,
                Class3: policyContractSection.subClass,
                MajorClass: policyContractSection.majorClass,
                MinorClass: policyContractSection.minorClass,
                ClassType: policyContractSection.classType, //(//Mapping needs from Entry-sheet-api)
                ProducingTeam: policyContractSection.producingTeam
            }
        },
        errorMessage: "Unable to fetch underwriter details."
    });
}

function getMajorAndMinorClasses(policyContractSection, getMajorClassOnly = true) {
    return riskEntrySheet.utils.azureAjax({
        clientId: config.britCacheClientId,
        scope: config.britCacheScope,
        type: "POST",
        url: config.britCacheBaseUrl + `Eclipse/underwriters`,
        data: {
            Filter: {
                FilterType: "UnderwriterSearchFilter",
                UWInitials: policyContractSection.uwInitials,
                YOA: policyContractSection.yoa,
                Syndicate: policyContractSection.syndicate,
                ProducingTeam: policyContractSection.producingTeam,
                ClassType: policyContractSection.classType,
                MajorClass: getMajorClassOnly == true ? null : policyContractSection.majorClass
            }
        },
        errorMessage: "Unable to fetch Stat Ref details."
    });
 }

function getSubClasses(policyContractSection) {
    return riskEntrySheet.utils.azureAjax({
        clientId: config.britCacheClientId,
        scope: config.britCacheScope,
        type: "POST",
        url: config.britCacheBaseUrl + `Eclipse/underwriters`,
        data: {
            Filter: {
                FilterType: "UnderwriterSearchFilter",
                UWInitials: policyContractSection.uwInitials,
                YOA: policyContractSection.yoa,
                Syndicate: policyContractSection.syndicate,
                ProducingTeam: policyContractSection.producingTeam,
                ClassType: policyContractSection.classType,
                MajorClass: policyContractSection.majorClass,
                MinorClass: policyContractSection.minorClass
            }
        },
        errorMessage: "Unable to fetch Stat Ref details."
    });
}

function getBrokerData(searchTerm) {
        return riskEntrySheet.utils.azureAjax({
            clientId: config.britCacheClientId,
            scope: config.britCacheScope,
            type: "POST",
            url: config.britCacheBaseUrl + `Eclipse/Brokers`,
            data: {
                Filter:
                {
                    FilterType: "SearchFilter",
                    IndexNames: ["BrokerName", "BrokerCode", "BrokerPseud"],
                    SearchTerm: searchTerm,
                    maxResults: 500
                }
            },
            errorMessage: "Unable to fetch broker details."
        });
    }

function getBrokerContact(searchTerm,lloydsBrokerId) {
        return riskEntrySheet.utils.azureAjax({
            clientId: config.britCacheClientId,
            scope: config.britCacheScope,
            type: "POST",
            url: config.britCacheBaseUrl + `Eclipse/BrokerContacts`,
            data: {
                Filter:
                {
                    FilterType: "ParentIdSearchFilter",
                    ParentIds: [lloydsBrokerId], //Pass Lloyd's Broker Id
                    SearchTerm: searchTerm,
                    SearchTermInField: "BrokerContactName"
                }
            },
            errorMessage: "Unable to fetch broker contact details."
        });
    }

    function itemsPoliciesForSystem(result, policyIds, isProgramme, system, url) {
        var promise = new $.Deferred();
        var filter = "";
        if (system === 'BUAA_Request') {
            filter = {
                Filter:
                {
                    FilterType: "BritPolicyId",
                    BritPolicyIds: policyIds,
                    maxResults: policyIds.length
                }
            };
        } else {
            filter = {
                Filter:
                {
                    FilterType: "ByBritPolicyId",
                    BritPolicyIds: policyIds,
                    maxResults: policyIds.length
                }
            };
        }
        let response =  riskEntrySheet.utils.azureAjax({
            clientId: config.britCacheClientId,
            scope: config.britCacheScope,
            type: "POST",
            url: config.britCacheBaseUrl + url,
            data: filter,
            errorMessage: `Unable to fetch ${system} contact details.`
        });
        response.done(function (systemPolicyDetails) {
            result[system] = { items: [] };
            systemPolicyDetails.forEach(sd => {
                sd.Items.forEach(function (item) {
                    result[system].items.push(item);
                });
            });
            promise.resolve(result);
        });
        return promise;
    }

    function getIgnisRoles(user) {

        return riskEntrySheet.utils.azureAjax({
            clientId: config.britCacheClientId,
            scope: config.britCacheScope,
            type: "POST",
            url: config.britCacheBaseUrl + `Ignis/userroles`,
            data: {
                Filter:
                {
                    FilterType: "UserRoleFilter",
                    NTName: user
                }
            },
            errorMessage: "Unable to fetch broker contact details."
        });
    }

}

