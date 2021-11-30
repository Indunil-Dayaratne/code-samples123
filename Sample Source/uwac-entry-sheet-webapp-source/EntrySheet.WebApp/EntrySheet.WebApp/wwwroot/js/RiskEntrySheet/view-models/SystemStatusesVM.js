var riskEntrySheet = riskEntrySheet || {};

riskEntrySheet.SystemStatusesViewModel = function(config,blade) {
    var self = this;
    self.modalData = ko.observable();
    self.britPolicyId = ko.observable(0);
    self.selectedPolicy = ko.observable({});
    self.ignisRaterData = ko.observable();

    self.selectedPolicy({
        SystemStatus: []
    });

    var britCacheService = britCacheClient(config);

    self.initialise = function (britPolicyId, policyReference) {
        self.britPolicyId(britPolicyId);
        let policyIds = [britPolicyId];
        var result = {};
        var britCacheData = $.Deferred();
        riskEntrySheet.promises.push(britCacheData);

        $.when(britCacheService.itemsPoliciesForSystem(result, policyIds, false, 'Britflow_Query', 'Query/query'),
            britCacheService.itemsPoliciesForSystem(result, policyIds, false, 'Britflow_CMT', 'CMT/CMT'),
            britCacheService.itemsPoliciesForSystem(result, policyIds, false, 'Britflow_TPU', 'TPU/TPU'),
            britCacheService.itemsPoliciesForSystem(result, policyIds, false, 'Britflow_PRC', 'Pricing/Pricing'),
            britCacheService.itemsPoliciesForSystem(result, policyIds, false, 'DWF_Batch', 'DWF/dwf'),
            britCacheService.itemsPoliciesForSystem(result, policyIds, false, 'CDP_CDP', 'CDP/cdp'),
            britCacheService.itemsPoliciesForSystem(result, policyIds, false, 'Britflow_Referral', 'Referral/Referral'),
            britCacheService.itemsPoliciesForSystem(result, policyIds, false, 'BUAA_Request', 'UWAuthorities/buaarequest'),
            britCacheService.itemsPoliciesForSystem(result, policyIds, false, 'Ignis_Enquiry', 'Ignis/enquiries'))
            .done(function () {
                riskEntrySheet.utils.setStatusColour(result.Britflow_TPU, "TPUStatus", "Resources");
                riskEntrySheet.utils.setStatusColour(result.Britflow_PRC, "PricingStatus", "Resource");
                riskEntrySheet.utils.setStatusColour(result.Britflow_Referral, "Status", "Resources");
                riskEntrySheet.utils.setStatusColour(result.Britflow_CMT, "CMTStatus", "Resources");
                riskEntrySheet.utils.setCDPStatusColour(result.CDP_CDP, "Status", "Owner");
                riskEntrySheet.utils.setStatusColour(result.DWF_Batch, 'Status', 'AssignedTo');
                formatIgnisEnquiryData(result);
                riskEntrySheet.utils.setQueryStatusColour(result.Britflow_Query, "QueryStatus", "Resources");
                riskEntrySheet.utils.setBUAAStatusColour(result.BUAA_Request, 'Status', 'AssignedTo');
                var obj = {
                    SystemStatus: result,
                    UWSystem: 'Eclipse',
                    BritPolicyId: britPolicyId,
                    Reference: policyReference
                };
                self.selectedPolicy(obj);
                setTimeout(function () {
                    britCacheData.resolve();
                    //Resolve the promises for loading 
                }, 2000);

            });

        systemModalUIChanges();
    }
    function formatIgnisEnquiryData(data) {
        if (data.Ignis_Enquiry != undefined) {
                data.Ignis_Enquiry.Title = "Add Enquiry";
                data.Ignis_Enquiry.IgnisHtml = "<span class='glyphicon glyphicon-plus'></span>";

                if (data.Ignis_Enquiry != undefined && data.Ignis_Enquiry.items != undefined && data.Ignis_Enquiry.items.length > 0) {
                    if (data.Ignis_Enquiry.items.length > 1) {
                        data.Ignis_Enquiry.Title = 'Mutliple Enquiries Found';
                        data.Ignis_Enquiry.IgnisHtml = "<span class='glyphicon glyphicon-plus'></span>";
                    } else {
                        var firstItem = data.Ignis_Enquiry.items[0];
                        var spanClassHtml = "";
                        switch (firstItem.EnquiryStatus) {
                            case 'In Progress':
                                spanClassHtml = " <span class='glyphicon glyphicon-cog'></span>";
                                break;
                            case 'No Pricing Record':
                                spanClassHtml = "<span class='glyphicon glyphicon-plus'></span>";
                                break;
                            case 'Complete':
                                spanClassHtml = " <span class='glyphicon glyphicon-ok text-success'></span>";
                                break;
                            default:
                                spanClassHtml = "<span class='glyphicon glyphicon-plus'></span>";
                                break;
                        }

                        data.Ignis_Enquiry.Title = firstItem.EnquiryStatus;
                        data.Ignis_Enquiry.IgnisHtml = spanClassHtml;
                    }
                }
            } else {
                if (data.Ignis_Enquiry != undefined && data.Ignis_Enquiry.items != undefined && data.Ignis_Enquiry.items.length > 0) {
                    var firstItem = data.Ignis_Enquiry.items[0];
                    var spanClassHtml = "";
                    switch (firstItem.EnquiryStatus) {
                        case 'In Progress':
                            spanClassHtml = " <span class='glyphicon glyphicon-cog'></span>";
                            break;
                        case 'No Pricing Record':
                            spanClassHtml = "<span class='glyphicon glyphicon-question-sign'></span>";
                            break;
                        case 'Complete':
                            spanClassHtml = " <span class='glyphicon glyphicon-ok text-success'></span>";
                            break;
                        default:
                            spanClassHtml = "<span class='glyphicon glyphicon-question-sign'></span>";
                            break;
                    }

                    data.Ignis_Enquiry.Title = firstItem.EnquiryStatus;
                    data.Ignis_Enquiry.IgnisHtml = spanClassHtml;
                }
            }
    }

    self.openPeerReviewRisksBlade = function (data) {
        page.show(`${blade.path}/ReviewRisksV2(britPolicyIds='${self.selectedPolicy().BritPolicyId}')`);
    }

    self.openBUAABlade = function (data) {
        if (data != undefined && data.Id != undefined && data.Type == 1) {
            page.show(`${blade.path}/AlertDetails(alertId=${data.Id})`);
        } else if (data != undefined && data.Id != undefined && data.Type == 2) {
            page.show(`${blade.path}/ExceptionRequestDetail(requestId=${data.Id})`);
        } else {
            page.show(`${blade.path}/ExceptionRequestPPLNew(uwSystem='${self.selectedPolicy().UWSystem}',britPolicyId=${self.selectedPolicy().BritPolicyId})`);
        }
        var modalPopupName = getModalPopupName('BUAA');
        $('#' + modalPopupName).modal('hide');
    }

    self.createNewSystemStatusItem = function (itemType) {
        britPolicyId = self.selectedPolicy().BritPolicyId;
        switch (itemType) {
            case 'CMT':
                self.openCMTBlade(undefined, britPolicyId);
                break;
            case 'TPU':
                self.openTPUBlade(undefined, britPolicyId);
                break;
            case 'PRC':
                self.openPRCBlade(undefined, britPolicyId);
                break;
            case 'Referral':
                self.openReferralBlade(undefined, britPolicyId);
                break;
            case 'Query':
                self.openQueryBlade(undefined, britPolicyId);
                break;
            case 'CDP':
                self.openCDPBlade(undefined, britPolicyId);
                break
            case 'UWNotes':
                self.openUnderwritingNotes(undefined, britPolicyId);
                break;
            case 'PBQA':
                self.openPbqa(undefined, britPolicyId);
                break;
        }
    }

    self.openQueryBlade = function (data, britPolicyId) {
        if (data != undefined && data.Id != undefined) {
            page.show(`${blade.path}/QueryDetail(queryId=${data.Id})`);
        } else {

            page.show(`${blade.path}/QueryNew(britPolicyId=${britPolicyId},uwSystem='${self.selectedPolicy().UWSystem}')`);
        }
        var modalPopupName = getModalPopupName('Query');
        $('#' + modalPopupName).modal('hide');
    }

    self.openTPUBlade = function (data, britPolicyId) {
        if (data != undefined && data.Id != undefined) {
            page.show(`${blade.path}/TPUDetail(tpuId=${data.Id})`);
        } else {
            page.show(`${blade.path}/TPUNew(britPolicyId=${britPolicyId},uwSystem='${self.selectedPolicy().UWSystem}')`);
        }
        var modalPopupName = getModalPopupName('TPU');
        $('#' + modalPopupName).modal('hide');
    }
    self.openCDPBlade = function openCDPBlade(data, britPolicyId) {

        if (data != undefined && data.Id != undefined) {
            page.show(`${blade.path}/CDPDetail(cdpId=${data.Id})`);
        } else {
            page.show(`${blade.path}/CDPNew(britPolicyId=${britPolicyId},uwSystem='${self.selectedPolicy().UWSystem}')`);
        }
        var modalPopupName = getModalPopupName('CDP');
        $('#' + modalPopupName).modal('hide');
    }

    self.openCMTBlade = function (data, britPolicyId) {
        if (data != undefined && data.Id != undefined) {
            page.show(`${blade.path}/CMTDetail(cmtId=${data.Id})`);
        } else {
            page.show(`${blade.path}/CMTNew(britPolicyId=${britPolicyId})`);
        }
        var modalPopupName = getModalPopupName('CMT');
        $('#' + modalPopupName).modal('hide');
    }
    self.openDWFBlade = function (data) {
        var modalPopupName = getModalPopupName('DWF');
        $('#' + modalPopupName).modal('hide');
        page.show(`${blade.path}/DWFDetail(batchId=${data.BatchId})`);
    }

    self.openReferralBlade = function (data, britPolicyId) {
        if (data != undefined && data.Id != undefined) {
            page.show(`${blade.path}/ReferralDetail(referralId=${data.Id})`);
        } else {
            page.show(`${blade.path}/ReferralNew(britPolicyId=${britPolicyId},uwSystem='${self.selectedPolicy().UWSystem}')`);
        }
        var modalPopupName = getModalPopupName('Referral');
        $('#' + modalPopupName).modal('hide');
    }

    self.openPRCBlade = function (data, britPolicyId) {
        if (data != undefined && data.Id != undefined) {
            page.show(`${blade.path}/PRCDetail(pricingId=${data.Id})`);
        } else {
            page.show(`${blade.path}/PRCNew(britPolicyId=${britPolicyId},uwSystem='${self.selectedPolicy().UWSystem}')`);
        }
        var modalPopupName = getModalPopupName('PRC');
        $('#' + modalPopupName).modal('hide');
    }

    self.showItemsDialog = function (itemType) {
        self.modalData(undefined);
        var modalPopupName = getModalPopupName(itemType);
        var object = {};
        object["ReferenceLabel"] = "Policy Ref: ";
        object["PolicyReference"] = self.selectedPolicy().Reference;
        switch (itemType) {
            case 'CMT':
                object[itemType] = self.selectedPolicy().SystemStatus.Britflow_CMT.items;
                object["Colour"] = self.selectedPolicy().SystemStatus.Britflow_CMT.colour;
                break;
            case 'TPU':
                object[itemType] = self.selectedPolicy().SystemStatus.Britflow_TPU.items;
                object["Colour"] = self.selectedPolicy().SystemStatus.Britflow_TPU.colour;
                break;
            case 'DWF':
                object[itemType] = self.selectedPolicy().SystemStatus.DWF_Batch.items;
                object["Colour"] = self.selectedPolicy().SystemStatus.DWF_Batch.colour;
                break;
            case 'PRC':
                object[itemType] = self.selectedPolicy().SystemStatus.Britflow_PRC.items;
                object["Colour"] = self.selectedPolicy().SystemStatus.Britflow_PRC.colour;
                break;
            case "Referral":
                object[itemType] = self.selectedPolicy().SystemStatus.Britflow_Referral.items;
                object["Colour"] = self.selectedPolicy().SystemStatus.Britflow_Referral.colour;
                break;
            case "CDP":
                object[itemType] = self.selectedPolicy().SystemStatus.CDP_CDP.items;
                object["Colour"] = self.selectedPolicy().SystemStatus.CDP_CDP.colour;
                break;
            case "BUAA":
                object[itemType] = self.selectedPolicy().SystemStatus.BUAA_Request.items;
                object["Colour"] = self.selectedPolicy().SystemStatus.BUAA_Request.colour;
                break;
            case 'Epeer':
                var selectedItem = self.selectedPolicy().SystemStatus.EPeer_Program.items[0];
                var epeerData = {
                    "ReviewStatus": selectedItem.ReviewStatus,
                    "LastUpd": selectedItem.LastUpd,
                    "ReviewedBy": selectedItem.ReviewedBy,
                    "ProgramId": selectedItem.ProgramId
                };
                object["Epeer"] = epeerData;
                break;
            case "Ignis_Enquiry":
                object[itemType] = self.selectedPolicy().SystemStatus.Ignis_Enquiry.items;
                break;
            case 'Query':
            default:
                var queries = self.selectedPolicy().SystemStatus.Britflow_Query.items;
                for (var i = 0; i < queries.length; i++) {
                    queries[i].QueryGroup = queries[i].QueryGroup == undefined ? '' : queries[i].QueryGroup;
                    queries[i].QueryType = queries[i].QueryType == undefined ? '' : queries[i].QueryType;
                }
                object[itemType] = queries;
                object["Colour"] = self.selectedPolicy().SystemStatus.Britflow_Query.colour;
                break;
        }
        self.modalData(object);
        setTimeout(function () {
            $('#' + modalPopupName).modal('show');
        }, 1000);

    }

    function getModalPopupName(itemType) {
        switch (itemType) {
            case 'CMT':
                return "EntrySheetCMTModal";
            case 'TPU':
                return "EntrySheetTPUModal";
            case 'DWF':
                return "EntrySheetDWFModal";
            case 'PRC':
                return "EntrySheetPricingModal";
            case "Referral":
                return "EntrySheetReferralModal";
            case "CDP":
                return "EntrySheetCDPModal";
            case "BUAA":
                return "EntrySheetBUAAModal";
            case "Epeer":
                return "EntrySheetEPeerModal";
            case "Ignis_Enquiry":
                return "EntrySheetIgnisModel";
            case 'Query':
            default:
                return "EntrySheetQueryModal";
        }
    }

    self.openModal = function (itemType) {
        var modalPopupName = getModalPopupName(itemType);
        $('#' + modalPopupName).modal('hide');
        page.show(`${blade.path}/Grid${itemType}(britPolicyId=${self.selectedPolicy().BritPolicyId},uwSystem='${self.selectedPolicy().UWSystem}')`);
    }
    self.ModifiedFormatted = function (date) {
        return date ? moment(date).format('DD-MMM-YYYY') : null;
    }
    self.FormatResources = function (resources) {
        var str = "";
        if (resources.length > 0) {
            for (var i = 0; i < resources.length; i++) {
                str += resources[i].Title;
            }
        } else if (resources != undefined) {
            str = resources.Title != undefined ? resources.Title : "";
        }
        return str;
    }

    self.getIgnisRedirectUrl = function () {
        var britPolicyId = self.selectedPolicy().BritPolicyId;
        var ignis_item;
        var enquiryId;
        var enquiryStatus;
        var raterModelId;

        if (self.selectedPolicy().SystemStatus.Ignis_Enquiry != undefined && self.selectedPolicy().SystemStatus.Ignis_Enquiry != undefined && self.selectedPolicy().SystemStatus.Ignis_Enquiry.items != undefined
            && self.selectedPolicy().SystemStatus.Ignis_Enquiry.items.length > 0) {
            ignis_item = self.selectedPolicy().SystemStatus.Ignis_Enquiry.items[0];
            enquiryId = ignis_item.EnquiryId;
            enquiryStatus = ignis_item.EnquiryStatus;
            raterModelId = ignis_item.RaterModelId;
        }

        var currentUser = getUserName();
        let response = britCacheService.getIgnisRoles(currentUser);
            response.done(function (data) {
                if (data != null && data != undefined && data.length > 0) {
                    var raterModelDetails = data.filter(function (item) {
                        return item.RaterModelId == raterModelId;
                    });
                    if (raterModelDetails.length > 0 &&
                        (raterModelDetails[0].Role == "Underwriter" ||
                            raterModelDetails[0].Role == "TPU" ||
                            raterModelDetails[0].Role == "ReadOnly")
                    ) {
                        if (enquiryStatus == "Mutliple Enquiries" || enquiryStatus == "In Progress") {
                            showIgnisDialog(data, britPolicyId, enquiryId);
                            return;
                        } else if (ignis_item == undefined) {
                            score = "New";
                            enquiryId = "";
                            showIgnisRaterModelDialog(data);
                            return;
                        } else if (enquiryStatus == "Complete") {
                            score = "View";
                            self.createNewIgnisEnquiry(raterModelDetails[0].RaterModelId, score, enquiryId);
                            return;
                        } else {
                            score = "View";
                            return;
                        }
                    } else if (enquiryStatus == "Mutliple Enquiries") {
                        showIgnisDialog(data, britPolicyId, enquiryId);
                        return;
                    }
                    else if (ignis_item == undefined) {
                        score = "New";
                        enquiryId = "";
                        showIgnisRaterModelDialog(data);
                        return;
                    } else {
                        var content = 'Unable to open Ignis Enquiry. You do not have access to this Pricing Model.';
                        blade.flashErrorMessage(content);
                    }
                }
                else {
                    blade.setLoading(false);
                    var content = 'You do not have access on Ignis. Please contact the Service Desk.';
                    blade.flashErrorMessage(content);
                    console.log(content);
                    return;
                }
            })

    }

    self.createNewIgnisEnquiry = function (raterModelId, score, enquiryId) {
        score = score === 3 ? "New" : (score === "View" ? "View" : "");
        enquiryId = enquiryId ? enquiryId : "";
        blade.content.find("#EntrySheetIgnisRaterModel").modal('hide');
        var policyData = {
            enquiryId: enquiryId,
            environment: config.ignisApi.environmentName,
            Ops: score == "" ? JSON.stringify(score) : score,
            ratermodelid: raterModelId
        }
        var ignisUrl = config.ignisApi.baseUrl + "/GetIgnisEnquiry";
        blade.setLoading('Loading Ignis Pricing Model. Please do not click on the excel.');

        $.ajax({
            crossDomain: true,
            type: "GET",
            xhrFields: {
                withCredentials: true
            },
            url: ignisUrl,
            data: policyData,
            dataType: 'json',
            success: function (response) {
                blade.setLoading(false);
                response = response.Message ? response.Message.toString() : response;
                if (response.includes("Request to open Ignis Enquiry Queued-In For Enquiry ID")) {
                    var content = 'Pricing Model for Ignis Enquiry - ' + enquiryId + ' loaded successfully.';
                    blade.flashSuccessMessage(content);
                }
                else if (response.includes("Invalid Inputs")) {
                    var content = 'Unable to open Ignis Enquiry. Data invalid for Ignis Enquiry - ' + enquiryId;
                    blade.flashErrorMessage(content);
                }
                else if (response.includes("Add-IN Service Down")) {
                    var content = 'Error while launching Ignis Add- In, please try again.If the problem persists please contact the Service Desk';
                    blade.flashErrorMessage(content);
                }
                else {
                    blade.flashErrorMessage(response);
                }
                console.log("Response for Ignis Enquiry -" + enquiryId + " : " + response);
            },
            error: function (xhr, ajaxOptions, thrownError) {
                blade.setLoading(false);
                var content =
                    'Unable to open Ignis Enquiry, please try again. If the problem persists please contact the Service Desk.';
                blade.flashErrorMessage(content);
                console.log("Error occurred while fetching Pricing Model for Ignis Enquiry - " +
                    enquiryId +
                    " : " +
                    thrownError);
            }
        });
    }

    function showIgnisDialog(raterModelData, britPolicyId, enquiryId) {
        self.selectedPolicy().SystemStatus.Ignis_Enquiry.items.forEach(enquiry => {
            enquiry.RaterModelDetails = raterModelData.filter(function (item) {
                return item.RaterModelId === enquiry.RaterModelId;
            });
            if (enquiry.RaterModelDetails.length > 0) {
                var tempRater = enquiry.RaterModelDetails[0];

                if (tempRater.Role === "Underwriter" || tempRater.Role === "TPU") {
                    enquiry.EditPermission = ko.observable(true);
                    enquiry.ViewPermission = ko.observable(true);
                } else if (tempRater.Role === "ReadOnly") {
                    enquiry.EditPermission = ko.observable(false);
                    enquiry.ViewPermission = ko.observable(true);
                } else {
                    enquiry.EditPermission = ko.observable(false);
                    enquiry.ViewPermission = ko.observable(false);
                }

            } else {
                enquiry.EditPermission = ko.observable(false);
                enquiry.ViewPermission = ko.observable(false);

            }

        });
        self.showItemsDialog("Ignis_Enquiry");
    }

    self.selectIgnisMenu = function (data, score) {
        if (data != undefined && data.RaterModelDetails != undefined && data.RaterModelDetails[0] != undefined) {
            var enquiryId = data.EnquiryId;
            blade.content.find("#EntrySheetIgnisModel").modal('hide');

            score = score == 2 ? "Edit" : "View";

            blade.setLoading('Loading Pricing Model for Ignis Enquiry - ' + enquiryId + '. Please do not click on the excel.');
            var policyData = {
                enquiryId: enquiryId,
                environment: config.ignisApi.environmentName,
                Ops: score,
                ratermodelid: data.RaterModelDetails[0].RaterModelId
            }
            var ignisUrl = config.ignisApi.baseUrl + "/GetIgnisEnquiry";
            $.ajax({
                crossDomain: true,
                type: "GET",
                xhrFields: {
                    withCredentials: true
                },
                url: ignisUrl,
                data: policyData,
                dataType: 'json',
                success: function (response) {
                    blade.setLoading(false);
                    response = response.Message ? response.Message.toString() : response;
                    if (response.includes("Request to open Ignis Enquiry Queued-In For Enquiry ID")) {
                        var content = 'Pricing Model for Ignis Enquiry - ' + enquiryId + ' loaded successfully.';
                        blade.flashSuccessMessage(content);
                    }

                    else if (response.includes("Invalid Inputs")) {
                        var content = 'Unable to open Ignis Enquiry. Data invalid for Ignis Enquiry - ' + enquiryId;
                        blade.flashErrorMessage(content);
                    }
                    else if (response.includes("Add-IN Service Down")) {
                        var content = 'Error while launching Ignis Add- In, please try again.If the problem persists please contact the Service Desk';
                        blade.flashErrorMessage(content);
                    }
                    else {
                        blade.flashErrorMessage(response);
                    }
                    console.log("Response for Ignis Enquiry -" + enquiryId + " : " + response);
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    blade.setLoading(false);
                    var content = 'Unable to open Ignis Enquiry, please try again. If the problem persists please contact the Service Desk.';
                    blade.flashErrorMessage(content);
                    console.log("Error occurred while fetching Pricing Model for Ignis Enquiry - " + enquiryId + " : " + thrownError);
                }
            });

        }
    }

    function showIgnisRaterModelDialog(data) {
        var dialogData = data.filter(function (item) {
            return (item.Role === "Underwriter" || item.Role === "TPU");
        });
        self.ignisRaterData(dialogData);
        blade.content.find("#EntrySheetIgnisRaterModel").modal({ show: true });
    }


    function systemModalUIChanges() {
        $(document).ready(function () {
            $(document)
                .on('show.bs.modal', '.modal', function () {
                    blade.content.find('#riskEntryDiv').addClass('blur-filter');
                    $('body').click(function (event) {
                        if (bladeUI.context.path.includes("RiskEntrySheet") && !$(event.target).closest('.modal-dialog,.js-open-modal').length && !$(event.target).is('.modal-dialog,.js-open-modal')) {
                            $(".modal").modal('hide');
                        }
                    });
                })
                .on('hidden.bs.modal', '.modal', function () {
                    blade.content.find('#riskEntryDiv').removeClass('blur-filter');
                })

        });
    }
}
