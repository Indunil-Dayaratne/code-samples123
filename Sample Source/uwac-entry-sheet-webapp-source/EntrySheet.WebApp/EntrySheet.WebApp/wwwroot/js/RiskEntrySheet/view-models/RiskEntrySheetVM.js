var riskEntrySheet = riskEntrySheet || {};
riskEntrySheet.promises = [];
riskEntrySheet.currentUser = {};
riskEntrySheet.pbqaAccessToken = null;
riskEntrySheet.britCacheAccessToken = null;
riskEntrySheet.isReadOnlyAccess = false;

function EntrySheetDataViewModel() {
    var self = this;
    self.id = 0;
    self.britPolicyId = 0;
    self.customerType = ko.observable("");
    self.programRef = ko.observable("");
    self.ePlacing = ko.observable("");
    self.policyReference = ko.observable("");
    self.insured = ko.observable({});
    self.reinsured = ko.observable({});
    self.coverholder = ko.observable({});
    self.conductRating = ko.observable("");
    self.completed = ko.observable(false);
    self.additionalDetails = new Array();
    self.contractSection = new Array();
    self.premiumRatings = new Array();
    self.policyLines = new Array();
    self.lastUpdatedBy = "";
    self.userName = "";
    self.uniqueMarketRef = null;
    self.companyLeader = null;
    self.lloydsLeader = null;
    self.placingType = null;
    self.instalmentPeriod = null;
    self.isRiskEntrySheetLocked = ko.observable(false);
    self.relatedPoliciesDetails = new Array();
}
riskEntrySheet.EntrySheetDetailsViewModel = function (config, blade, model) {
    var self = this;
    var riskEntrySheetSvc = riskEntrySheetClient(config, blade);
    var britCacheService = britCacheClient(config);
    var hubRiskEntryConnection;

    self.regularExpressionForPeriod = new RegExp("^(?=.*?[0-9])[0-9]+[DdMmWwQqYy]$");

    self.sectionViewModel = new riskEntrySheet.PolicySectionViewModel(config, blade);
    self.additionalDetailsViewModel = new riskEntrySheet.AdditionalDetailsViewModel(config, blade);
    self.policyLinesViewModel = new riskEntrySheet.PolicyLinesViewModel(config, blade);
    self.premiumRatingsViewModel = new riskEntrySheet.PremiumRatingsViewModel(config, blade);

    self.validationErrors = ko.observableArray([]);

    self.groupClassUW = [];
    self.policy = ko.observable();
    self.conductRatingList = ko.observableArray([]);
    self.customerTypeList = ko.observableArray([]);
    self.ePlacingList = ko.observableArray([]);
    self.entrySheetcompleted = ko.observable(false);
    self.isRiskEntrySheetLocked = ko.observable(false);
    self.policyUpdateNotifications = ko.observableArray([]);

    self.initialise = async function () {

        blade.setLoading("Loading");
        blade.setCloseHandler(closeRiskEntryDetails);

        let access_token = await acquireMsalSilentToken(config.pbqaApi.clientId, [config.pbqaApi.scope]);
        riskEntrySheet.pbqaAccessToken = access_token;
        access_token = await acquireMsalSilentToken(config.britCacheClientId, [config.britCacheScope]);
        riskEntrySheet.britCacheAccessToken = access_token;

        $(document).on('focus',
            '.required',
            function () {
                if ($(this).is(":visible")) {
                    $(this).parent().find('label.field-validation-error').remove();
                }
            });

        $(document)
            .on('click',
                '.required',
                function () {
                    if ($(this).is(":visible")) {
                        $(this).parent().find('label.field-validation-error').remove();
                    }
                });
        $(document)
            .on('focusout',
                '.required',
                function () {
                    if ($(this).is(":visible")) {
                        $(this).parent().find('label.field-validation-error').remove();
                    }
                });

        $(document)
            .on('keydown',
                '.required',
                function () {
                    if ($(this).is(":visible")) {
                        $(this).parent().find('label.field-validation-error').remove();
                    }
                });



        blade.modifyButton('CreateEntrySheet', createEntrySheet, '/Content/images/icons/Save.png', 'Save', false);
        blade.modifyButton("PolicyNotes", openPolicyNotes, "/Content/images/icons/Reports.png", "View Underwriting Notes");
        blade.modifyButton('DMSBlade', openDMSBlade, '/Content/images/icons/DMS.png', 'View DMS Documents');


        blade.setTitles("Risk Entry Sheet")
        var policyReference = model.PolicyReference ? model.PolicyReference : "";
        var isUserRoleAllowed = false;
        var userName = getUserName();
        riskEntrySheet.currentUser = getNTUserId().toLowerCase();

        var entrySheetBritPolicyId = model.BritPolicyId ? model.BritPolicyId : 0;
        var policyInceptionDate = "";

        ko.applyBindings(entrySheetvm, blade.content.find("#frmRiskEntrySheet")[0]);
        self.policy(new EntrySheetDataViewModel());
        self.policy().lastUpdatedBy = riskEntrySheet.currentUser;
        self.policy().userName = getUserName();

        addCustomValidations();
        let ePlacingPromise = $.Deferred();
        let deferEPlacingDetails = riskEntrySheetSvc.getEPlacingList();
        riskEntrySheet.promises.push(ePlacingPromise);
        deferEPlacingDetails.done(function (data) {
            data.push("");
            data.sort();
            self.ePlacingList(data);
            ePlacingPromise.resolve();
        });

        blade.setLoading("Loading");

        let policyRiskDetails = await riskEntrySheetSvc.getRiskEntrySheetDetails(entrySheetBritPolicyId);

        if (policyRiskDetails) {
            if (policyRiskDetails.additionalDetails) {
                policyInceptionDate = policyRiskDetails.additionalDetails[0].inceptionDate;
            }
        }
        else {
            blade.flashErrorMessage("Unable to fetch risk entry details for selected policy.");
            return;
        }

        let policyInfo = policyRiskDetails.relatedPoliciesDetails.filter(item => item.britPolicyId == entrySheetBritPolicyId)[0];

        let britCacheData = $.Deferred();
        riskEntrySheet.promises.push(britCacheData);

        $.when(britCacheService.getBusinessCodes("CustomerType", policyInceptionDate, riskEntrySheet.britCacheAccessToken, riskEntrySheet.britCacheAccessToken),
            britCacheService.getBusinessCodes("Market", policyInceptionDate, riskEntrySheet.britCacheAccessToken)
        ).done(function (deferCustomerTypes, deferConductRating) {

            if (deferCustomerTypes && deferCustomerTypes.length > 0) {
                let dataList = deferCustomerTypes.map(function (businessCode) { return businessCode.Value });
                dataList.push("");
                dataList.sort();
                self.customerTypeList(dataList);
            }
            else {
                blade.flashErrorMessage("Unable to fetch customer types from britcache.")
            }
            if (deferConductRating && deferConductRating.length > 0) {
                let dataList = deferConductRating.map(function (businessCode) { return businessCode.Value });
                dataList.push("");
                dataList.sort();
                self.conductRatingList(dataList);
            }
            else {
                blade.flashErrorMessage("Unable to fetch conduct ratings from britcache.")
            }
            if (policyInfo && policyInfo.customerType) {
                self.policy().customerType(policyInfo.customerType ? policyInfo.customerType : "");
            }
            if (policyInfo && policyInfo.conductRating) {
                self.policy().conductRating(policyInfo.conductRating);
            }
            britCacheData.resolve();
        });

        if (policyRiskDetails) {
            if (policyRiskDetails && policyRiskDetails.additionalDetails && policyRiskDetails.additionalDetails.length > 0) {
                var policyInceptionDate = policyRiskDetails.additionalDetails[0].inceptionDate;
            }
            self.policy().relatedPoliciesDetails = policyRiskDetails.relatedPoliciesDetails.filter(item => item.britPolicyId != entrySheetBritPolicyId);
            self.policy().policyReference(policyReference);
            self.policy().id = policyRiskDetails.id;
            self.policy().britPolicyId = entrySheetBritPolicyId;
            if (policyInfo) {
                self.policy().programRef(policyInfo.programRef);
                self.policy().coverholder({ partyName: policyInfo.coverholder.partyName ? policyInfo.coverholder.partyName : "" });
                self.policy().insured({ partyName: policyInfo.insured.partyName ? policyInfo.insured.partyName : "" });
                self.policy().reinsured({ partyName: policyInfo.reinsured.partyName ? policyInfo.reinsured.partyName : "" });
                self.policy().uniqueMarketRef = policyInfo.uniqueMarketRef;
                self.policy().companyLeader = policyInfo.companyLeader;
                self.policy().lloydsLeader = policyInfo.lloydsLeader;
                self.policy().placingType = policyInfo.placingType;
                self.policy().instalmentPeriod = policyInfo.instalmentPeriod;
            }
            self.policy().ePlacing(policyRiskDetails.ePlacing);
            self.policy().completed(policyRiskDetails.completed);
            self.entrySheetcompleted(self.policy().completed());
            displayPbqa(policyRiskDetails, policyReference);
            var riskEntrySheetHeader = self.policy().coverholder().partyName ? self.policy().coverholder().partyName :
                (self.policy().insured().partyName ? self.policy().insured().partyName : self.policy().reinsured().partyName);
            var placingType = policyRiskDetails.additionalDetails ? (policyRiskDetails.additionalDetails[0].placingType ? policyRiskDetails.additionalDetails[0].placingType : "") : "";
            var riskEntrySheetSubTitle = `${riskEntrySheetHeader} | ${policyReference} | ${placingType}`;
            blade.setTitles("Risk Entry Sheet", riskEntrySheetSubTitle);
            if (policyRiskDetails && policyRiskDetails.contractSection && policyRiskDetails.contractSection.length > 0) {
                //map Policy Contract section details to javascript object
                ko.applyBindings(self.sectionViewModel, blade.content.find("#divSections")[0]);
                ko.applyBindings(self.sectionViewModel, blade.content.find("#BrokerContactModalRiskEntry")[0]);
                self.sectionViewModel.initialise(policyRiskDetails.contractSection, policyInceptionDate);
            }
            if (policyRiskDetails && policyRiskDetails.additionalDetails && policyRiskDetails.additionalDetails.length > 0) {
                //Bind additionalDetails View Model 
                ko.applyBindings(self.additionalDetailsViewModel, blade.content.find("#divAdditionalDetails")[0]);
                self.additionalDetailsViewModel.initialise(policyRiskDetails.additionalDetails, policyInceptionDate);
            }
            if (policyRiskDetails && policyRiskDetails.premiumRatings && policyRiskDetails.premiumRatings.length > 0) {
                //Bind premium Ratings View Model 
                ko.applyBindings(self.premiumRatingsViewModel, blade.content.find("#divPremiumAndRatingDetails")[0]);
                self.premiumRatingsViewModel.initialise(policyRiskDetails.premiumRatings);
            }

            if (policyRiskDetails && policyRiskDetails.policyLines && policyRiskDetails.policyLines.length > 0) {
                //Bind lines View Model 
                ko.applyBindings(self.policyLinesViewModel, blade.content.find("#divLinesDetails")[0]);
                self.policyLinesViewModel.initialise(policyRiskDetails.policyLines, policyInceptionDate);
            }

            if (policyRiskDetails) {
                //Bind System Status
                self.systemStatusViewModel = new riskEntrySheet.SystemStatusesViewModel(config, blade);
                ko.applyBindings(self.systemStatusViewModel, blade.content.find("#divPolicySystemsStatus")[0]);
                self.systemStatusViewModel.initialise(entrySheetBritPolicyId, policyReference);
            }
            Promise.all(riskEntrySheet.promises).then(function () {
                blade.setLoading(false);
                let linesCount = self.policyLinesViewModel.lines().filter(x => x.lineStatus() !== "Signed");
                
                
                blade.content.find('#frmRiskEntrySheet').validate();
                $(".numeric").rules("add", {
                    validateDecimalFormat: true,
                    messages: {
                        validateDecimalFormat: "Please enter valid numeric value."
                    }
                });
                $(".periodValidation").rules("add", {
                    validatePeriodFormat: true,
                    messages: {
                        validatePeriodFormat: "Period should be formatted as period length - period type."
                    }
                });
                blade.hasChanged = true;
                if (!model.Role || model.Role !== "Write") {
                    riskEntrySheet.isReadOnlyAccess = true;
                }
                else if (!(linesCount.length === 0 && self.policy().completed())) {
                    blade.enableButton('CreateEntrySheet', true);
                }

                if (!riskEntrySheet.isReadOnlyAccess) {
                    let sectionDetail = policyRiskDetails.contractSection.filter(item => item.policyRef === self.policy().policyReference());
                    self.policy().isRiskEntrySheetLocked(sectionDetail[0].isRiskEntrySheetLocked);
                    self.isRiskEntrySheetLocked(self.policy().isRiskEntrySheetLocked);
                }
                else {
                    self.policy().isRiskEntrySheetLocked(true);
                    self.isRiskEntrySheetLocked(true);
                    var form = blade.content.find("#frmRiskEntrySheet")[0];
                    var elements = Array.from(form.elements).filter(item => !(item.classList.contains("always-on")));    
                    for (var i = 0, len = elements.length; i < len; ++i) {
                        elements[i].disabled = true;
                    }
                    blade.hasChanged = false;
                }
            });

            openSignalRFeed();
        }
        else {
            blade.setLoading(false);
            blade.flashErrorMessage("Failed to get entry sheet details for the selected policy.");
        }
    }

    function displayPbqa(riskPolicyDetails, policyReference) {
        let display = false;
        let policy = riskPolicyDetails.additionalDetails.filter(item => item.policyRef === policyReference)[0];

        if (policy) {

            if (policy.proupClass && policy.groupClass.startsWith("BGSU")) {
                display = true;
            }
            else if (config.pbqaPlacingTypes.contains(policy.placingType)) {
                display = true;
            }

            if (display) {
                blade.modifyButton('PBQA', openPbqa, '/Content/images/icons/Quality.png', 'View Pre-Bind QA Checklist');
            }
        }
    }

    function openPbqa() {
        page.show(`${blade.path}/PBQA(uwSystem='eclipse')`);
    };

    function openPolicyNotes() {
        page.show(`${blade.path}/Notes(uwSystem='eclipse')`);
    };
    function openDMSBlade() {
        page.show(`${blade.path}/DMS(policyRef='${self.policy().policyReference()}')`);
    }

    function createEntrySheet() {
        var validator = blade.content.find("#frmRiskEntrySheet").validate();
        console.log("Validator",validator);
        var errors = validator.errorList;
        console.log("Errors",errors);

        blade.content.find('label.field-validation-error').remove();
        let isRiskEntrySheetValid;
        if (blade.content.find('#frmRiskEntrySheet').valid()) {
            isRiskEntrySheetValid = true;
        }
        if (isRiskEntrySheetValid) {
            blade.content.find('#frmRiskEntrySheet').submit();
        }
    }

    self.saveEntrySheet = function () {
        blade.setLoading("Risk Entry Sheet Details validation is in progress, Please wait");
        blade.enableButton("CreateEntrySheet", false);
        //Clear of previous validation errors if any 
        self.validationErrors(null);

        var entrySheetDataModel = new EntrySheetDataViewModel();
        entrySheetDataModel = mapFinalRiskEntrySheetDetailsForSave(entrySheetDataModel);
        console.log(entrySheetDataModel);
        let saveResponse = riskEntrySheetSvc.saveRiskEntrySheet(entrySheetDataModel);
        saveResponse.done(function (data) {
            //Display Validations if any
            if (data == undefined || data == null) {
                blade.flashErrorMessage("Failed to send policy risk entry data to eclipse.");
            }
            else {
                if (data && !data.placingValidationSuccessful && data.placingValidationDetails) {
                    blade.setLoading(false);
                    //Display Validation messages
                    let validationErrors = [];
                    $.each(data.placingValidationDetails, function (index, errorItem) {
                        if (errorItem.validationDetails) {
                            $.each(errorItem.validationDetails.reasons, function (index, reason) {
                                validationErrors.push({
                                    reason: `${errorItem.policyReference} - ${reason}`
                                });
                            });
                        }
                    });
                    self.validationErrors(validationErrors);
                    blade.section.find('.fxs-scrollbar-default-hover').scrollTop(0);
                    let linesCount = self.policyLinesViewModel.lines().filter(x => x.lineStatus() !== "Signed");
                    if (!(linesCount.length === 0 && self.policy().completed())) {
                        blade.enableButton('CreateEntrySheet', true);
                    }
                }
                else {

                    $.each(data.createRiskRequestSubmissionDetails, function (index, createRiskRequestSubmissionDetailsModel) {
                        self.policyUpdateNotifications().push({
                            correlationId: createRiskRequestSubmissionDetailsModel.correlationId,
                            policyReference: createRiskRequestSubmissionDetailsModel.policyReference,
                            notificationArrived: false,
                            updateSuccessful: false,
                            notificationStatus: ""
                        });
                    });

                    blade.setLoading("Saving Risk Entry Sheet Details is in progress,you may navigate away from this page and monitor notifications for update.");
                    setTimeout(function () {
                        blade.setLoading(false);
                    }, 10000);
                    blade.resetChangeTracker();
                }
            }
            
            //Refresh the Risk-Entry Sheet Details (get confirmed)
        });
    }

    function openSignalRFeed() {
        acquireMsalSilentToken(config.notificationSvcClientId, [config.notificationSvcScope]).then(function (access_token) {
            hubRiskEntryConnection = new signalR.HubConnectionBuilder()
                .withUrl(`${config.notificationSvcBaseUrl}`, { accessTokenFactory: () => access_token }, { transport: signalR.HttpTransportType.LongPolling })
                .withAutomaticReconnect()
                .configureLogging(signalR.LogLevel.Information)
                .build();

            hubRiskEntryConnection.start().then(function () {
                console.log("SignalR - Risk Entry - Connection to the notification listener started... ");
            });

            hubRiskEntryConnection.on('newMessage', newMessage => {
                if (newMessage != null) {
                    console.log("new Notification(s) = " + newMessage);
                    newMessage = JSON.parse(newMessage);
                    newMessage.forEach(function (newNotification) {
                        if (newNotification.Subscriber.contains(getUserName())) {
                            if (newNotification.NotificationStatus != "In Progress") {

                                if (self.policyUpdateNotifications().length > 0) {

                                    let policyUpdateNotification = self.policyUpdateNotifications().find(x => x.correlationId === newNotification.CorelationID);

                                    if (policyUpdateNotification != undefined) {

                                        policyUpdateNotification.notificationArrived = true;
                                        policyUpdateNotification.notificationStatus = newNotification.NotificationStatus;

                                        if (newNotification.NotificationStatus === "Complete") {
                                            policyUpdateNotification.updateSuccessful = true;
                                        }
                                    }

                                    if (self.policyUpdateNotifications().every(y => y.notificationArrived === true)) {

                                        blade.setLoading(false);

                                        if (self.policyUpdateNotifications().every(y => y.updateSuccessful === true)) {
                                            blade.flashSuccessMessage("Policy updates - Complete, please view the notification tab for further details.");
                                        } else {
                                            blade.flashErrorMessage("Policy update - Failed, please view the notification tab for further details.");
                                        }

                                        self.policyUpdateNotifications().splice(0, self.policyUpdateNotifications().length);
                                    }
                                }
                            }
                        }
                    });
                }
            });

            hubRiskEntryConnection.onclose(() => console.log("SignalR - Risk Entry - Connection to the notification listener closed... "));
        });
    }

    function closeRiskEntryDetails() {
        console.log("*** stop SignalR polling on risk entry details");
        if (hubRiskEntryConnection != undefined) {
            hubRiskEntryConnection.stop();
        }
        page.show(bladeUI.context.path);
    }

    function mapFinalRiskEntrySheetDetailsForSave(entrySheetDataModel) {
        //Map sections 
        //entrySheetDataModel.policySections = [];
        $.each(self.sectionViewModel.policySections(), function (index, section) {
            entrySheetDataModel.contractSection.push({
                policySectionId: section.policySectionId,
                britPolicyId: section.britPolicyId,
                brokerName: section.broker(),
                contactName: section.brokerContact(),
                brokerCode: section.brokerCode(),
                lloydsBrokerId: section.lloydsBrokerId(),
                brokerPseud: section.brokerPseud(),
                brokerContactId: section.brokerContactId(),
                subClass: section.subClass(),
                groupClass: section.groupClass(),
                industryCode: section.industryCode(),
                limitCcy: section.limitCcy(),
                limit: section.limit(),
                contractCoverageId: section.contractCoverageId(),
                subLimit: section.subLimit(),
                biSubLimitBasis: section.biSubLimitBasis(),
                biSubLimitCcy: section.biSubLimitCcy(),
                biSubLimit: section.biSubLimit(),
                limitBasis: section.limitBasis(),
                excess: section.excess(),
                deductible: section.deductible(),
                cyberExposure: section.cyberExposure(),
                innerAGG: section.innerAGG(),
                adrLevel: section.adrLevel(),
                syndicate: section.syndicate(),
                classType: section.classType(),
                producingTeam: section.producingTeam(),
                isMainSection: section.isMainSection,
                customerType: section.customerType,
                programRef: section.programRef,
                reinsured: section.reinsured ? { partyName: section.reinsured.partyName } : { partyName: "" },
                coverholder: section.coverholder ? { partyName: section.coverholder.partyName } : { partyName: "" },
                insured: section.insured ? { partyName: section.insured.partyName } : { partyName: "" },
                conductRating: section.conductRating(),
                contractPeriodStartDate: section.contractPeriodStartDate(),
                yoa: section.yoa(),
                uwInitials: section.uwInitials(),
                majorClass: section.majorClass(),
                minorClass: section.minorClass(),
                subClass: section.subClass(),
                policyRef: section.policyRef(),
                territoryIdAssured: section.territoryIdAssured,
                territoryId: section.territoryId,
                overridingCommission: section.overridingCommission,
                otherDeductions: section.otherDeductions,
                profitCommission: section.profitCommission,
                coverOperatingBasis: section.coverOperatingBasis
            });
        });
        //Map Premium & Ratings 
        $.each(self.premiumRatingsViewModel.premiumRatingsDetails(), function (index, detail) {
            entrySheetDataModel.premiumRatings.push({
                policyPremiumRatingId: detail.policyPremiumRatingId(),
                policyRef: detail.policyRef(),
                premiumCcy: detail.premiumCcy(),
                reportingCcy: detail.reportingCcy(),
                writtenPremium: detail.writtenPremium(),
                techPrice: detail.techPrice(),
                modelPrice: detail.modelPrice(),
                plr: detail.plr(),
                changeInLDA: detail.changeInLDA(),
                changeInCoverage: detail.changeInCoverage(),
                changeInOther: detail.changeInOther(),
                riskAdjustedRateChange: detail.riskAdjustedRateChange(),
                baseAmount: detail.baseAmount(),
                brokerage: detail.brokerage(),
                brokerageRateType: detail.brokerageRateType,
                premiumType: detail.premiumType,
                initialToT: detail.initialToT,
                paymentDate: detail.paymentDate,
                numberOfInstallment: detail.numberOfInstallment
            });
        });
        //Map Additional details
        $.each(self.additionalDetailsViewModel.additionalDetails(), function (index, detail) {
            entrySheetDataModel.additionalDetails.push({
                policyAdditionalDetailId: detail.policyAdditionalDetailId(),
                policyRef: detail.policyRef(),
                placingType: detail.placingType(),
                groupClass: detail.groupClass(),
                period: detail.period(),
                timeDurationPeriodType: detail.periodType(),
                timeDurationValue: detail.periodLength(),
                expiryDate: detail.expiryDate(),
                inceptionDate: detail.inceptionDate(),
                contractCertain: detail.contractCertain() == 'Yes' ? true : false,
                contractCertainCode: detail.contractCertainCode(),
                contractCertainDate: detail.contractCertainDate(),
                riskRating: detail.riskRating(),
                aggRiskData: detail.aggRiskData(),
                insuranceLevel: detail.insuranceLevel(),
            });
        });
        //Map Lines details
        $.each(self.policyLinesViewModel.lines(), function (index, lineDetail) {
            entrySheetDataModel.policyLines.push({
                policyLineId: lineDetail.policyLineId(),
                lbs: lineDetail.lbs(),
                section: lineDetail.lineSection(),
                entity: lineDetail.entity(),
                lineStatus: lineDetail.lineStatus(),
                wlInd: lineDetail.wlIndicator(),
                writtenLine: lineDetail.writtenLine(),
                estSign: lineDetail.estSign(),
                wo: lineDetail.wo(),
                order: lineDetail.order(),
                riCode: lineDetail.riCode(),
                exposure: lineDetail.exposure(),
                gnwp: lineDetail.gnwp(),
                policyRef: self.policy().programRef() + lineDetail.lineSection(),
                statusReason: lineDetail.statusReason(),
                quoteDate: lineDetail.quoteDate(),
                quoteDays: lineDetail.quoteDays() == null ? 0 : lineDetail.quoteDays() == "" ? 0 : lineDetail.quoteDays(),
                quoteId: lineDetail.quoteId(),
                riskAllocationCode: lineDetail.riskAllocationCode,
                writtenDateTime: lineDetail.writtenDateTime
            });
        });
        //Map Related Policy Details
        $.each(self.policy().relatedPoliciesDetails, function (index, relatedPolicy) {
            entrySheetDataModel.relatedPoliciesDetails.push({
                britPolicyId: relatedPolicy.britPolicyId,
                customerType: relatedPolicy.customerType,
                programRef: relatedPolicy.programRef,
                insured: {
                    partyName: relatedPolicy.insured ? relatedPolicy.insured.partyName : ""
                },
                reinsured: {
                    partyName: relatedPolicy.reinsured ? relatedPolicy.reinsured.partyName : ""
                },
                coverholder: {
                    partyName: relatedPolicy.coverholder ? relatedPolicy.coverholder.partyName : ""
                },
                conductRating: relatedPolicy.conductRating,
                uniqueMarketRef: relatedPolicy.uniqueMarketRef,
                companyLeader: relatedPolicy.companyLeader,
                lloydsLeader: relatedPolicy.lloydsLeader,
                placingType: relatedPolicy.placingType,
                instalmentPeriod: relatedPolicy.instalmentPeriod
            });
        });
        entrySheetDataModel.relatedPoliciesDetails.push({
            britPolicyId: self.policy().britPolicyId,
            customerType: self.policy().customerType(),
            programRef: self.policy().programRef(),
            insured: {
                partyName: self.policy().insured() ? self.policy().insured().partyName : ""
            },
            reinsured: {
                partyName: self.policy().reinsured() ? self.policy().reinsured().partyName : ""
            },
            coverholder: {
                partyName: self.policy().coverholder() ? self.policy().coverholder().partyName : ""
            },
            conductRating: self.policy().conductRating(),
            uniqueMarketRef: self.policy().uniqueMarketRef,
            companyLeader: self.policy().companyLeader,
            lloydsLeader: self.policy().lloydsLeader,
            placingType: self.policy().placingType,
            instalmentPeriod : self.policy().instalmentPeriod
        });

        //Map Policy Details
        entrySheetDataModel.id = self.policy().id;
        entrySheetDataModel.britPolicyId = self.policy().britPolicyId;

        entrySheetDataModel.ePlacing = self.policy().ePlacing();
        entrySheetDataModel.policyReference = self.policy().policyReference();
       
        entrySheetDataModel.completed = self.entrySheetcompleted();
        entrySheetDataModel.lastUpdatedBy = self.policy().lastUpdatedBy;
        entrySheetDataModel.userName = getUserName();

        return entrySheetDataModel;
    }

    self.getPromises = function(){
        returnriskEntrySheet.promises();
    }

    function addCustomValidations() {
        jQuery.validator.addMethod("validatePeriodFormat", function (value, element) {
            blade.content.find('label[for=' + element.id + '].field-validation-error').remove();
            return this.optional(element) || self.regularExpressionForPeriod.test(value);
        }, 'Period should be formatted as period length - period type.');

        jQuery.validator.addMethod("validateDecimalFormat", function (value, element) {
            blade.content.find('label[for=' + element.id + '].field-validation-error').remove();
            var regEx = /^([1-9]\d{0,2}(,?\d{3})*|0)(\.\d{0,4})?$/;
            return this.optional(element) || regEx.test(value);
        }, 'Please enter a valid numeric value.');
    }
};