var riskEntrySheet = riskEntrySheet || {};

riskEntrySheet.PolicySectionViewModel = function (config, blade) {
    var self = this;
    self.policySections = ko.observableArray([]);
    self.industryCodes = ko.observableArray([]);
    self.subLimitsList = ko.observableArray([]);
    self.adrLevelList = ko.observableArray([]);
    self.limitBasisList = ko.observableArray([]);
    self.cyberExposureList = ko.observableArray([]);
    self.brokerContactModalData = ko.observable({});

    var riskEntrySheetSvc = riskEntrySheetClient(config, blade);
    var britCacheService = britCacheClient(config);
    var groupClassesForBISubLimit = [];
    self.initialise = async function (sections, inceptionDate) {

        groupClassesForBISubLimit = riskEntrySheetConfig.enableBISubLimitForGroupClass.split(',');

        let britCacheData = $.Deferred();
        riskEntrySheet.promises.push(britCacheData);
        $.when(britCacheService.getBusinessCodes("LimitXSBasis", inceptionDate, riskEntrySheet.britCacheAccessToken),
            britCacheService.getPerilGroup("ADR", inceptionDate, riskEntrySheet.britCacheAccessToken),
            britCacheService.getPerilGroup("Cyber", inceptionDate, riskEntrySheet.britCacheAccessToken),
            riskEntrySheetSvc.getIndustryCodes()
        ).done(function (limitBasisResponse, adrLevelResponse, cyberExposureResponse, industryCodeResponse) {

            if (limitBasisResponse && limitBasisResponse.length > 0) {
                let subLimits = limitBasisResponse.filter(function (businessCode) {
                    return businessCode.Value.startsWith("BI");
                }).map(function (businessCode) {
                    return businessCode.Value;
                });
                subLimits.push("");
                subLimits.sort();
                self.subLimitsList(subLimits);


                let limitBasisList =
                    limitBasisResponse.map(function (limitBasis) {
                        return limitBasis.Value;
                    });
                limitBasisList = limitBasisList.filter(function(e) {
                        return String(e).trim();
                    });    
                limitBasisList.push("");
                limitBasisList.sort();

                self.limitBasisList(limitBasisList);
            }
            else {
                blade.flashErrorMessage("Unable to fetch limit basis from britcache.")
            }

            if (adrLevelResponse && adrLevelResponse.length > 0) {
                let adrLevelList = adrLevelResponse.map(function (perilGroup) {
                    return { Name: perilGroup.Name, PerilGroupId: perilGroup.PerilGroupId }
                })
                adrLevelList.push({ Name: "", PerilGroupId: "" });
                adrLevelList = adrLevelList.sort(riskEntrySheet.utils.compareValues("Name"));
                self.adrLevelList(adrLevelList);
            }
            else {
                blade.flashErrorMessage("Unable to fetch adr levels from britcache.")
            }

            if (cyberExposureResponse && cyberExposureResponse.length > 0) {
                let cyberExposureList = cyberExposureResponse.map(function (perilGroup) {
                    return { Name: perilGroup.Name, PerilGroupId: perilGroup.PerilGroupId }
                });
                cyberExposureList.push({ Name: "", PerilGroupId: "" });
                cyberExposureList = cyberExposureList.sort(riskEntrySheet.utils.compareValues("Name"));
                self.cyberExposureList(cyberExposureList);
            }
            else {
                blade.flashErrorMessage("Unable to fetch cyber exposures from britcache.")
            }

            if (industryCodeResponse && industryCodeResponse.length > 0) {
                let industryCodes = industryCodeResponse.map(function (industryCode) {
                    return { Code: industryCode.code, Name: industryCode.name, DisplayName: industryCode.code + " - " + industryCode.name };
                });
                industryCodes.push({ Code: "", Name: "", DisplayName: "" });
                industryCodes.sort(riskEntrySheet.utils.compareValues("Code"));
                self.industryCodes(industryCodes);
            }
            else {
                blade.flashErrorMessage("Unable to fetch industry codes from britcache.")
            }
            britCacheData.resolve();
        });

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

        britCacheData.done(function () {
            self.mapPolicyContractSectionDetails(sections);
        });
    }

    self.mapPolicyContractSectionDetails = function (contractSection) {
        var promise = $.Deferred();
        riskEntrySheet.promises.push(promise);
        self.policySections([]);
        var deferrds = [];
        $.each(contractSection, function (index, org) {
            deferrds.push(self.addPolicySectionRow());
        });
        $.when.apply($, deferrds).then(function () {
            $.each(contractSection, async function (index, section) {
                var row = self.policySections()[index];
                row.policySectionId = section.policySectionId;
                row.britPolicyId = section.britPolicyId;
                row.broker(section.brokerName);
                row.brokerContact(section.contactName);
                row.brokerCode(section.brokerCode);
                row.lloydsBrokerId(section.lloydsBrokerId);
                row.brokerPseud(section.brokerPseud);
                row.brokerContactId(section.brokerContactId);
                row.subClass(section.subClass);
                row.groupClass(section.groupClass);
                row.industryCode(section.industryCode);
                row.limitCcy(section.limitCcy);
                row.limit(section.limit);
                row.contractCoverageId(section.contractCoverageId);
                row.subLimit(section.subLimit);
                row.biSubLimitBasis(section.biSubLimitBasis);
                row.biSubLimitCcy(section.biSubLimitCcy);
                row.biSubLimit(section.biSubLimit);
                row.limitBasis(section.limitBasis);
                row.excess(section.excess);
                row.deductible(section.deductible);
                row.cyberExposure(section.cyberExposure);
                row.innerAGG(section.innerAGG);
                row.adrLevel(section.adrLevel);
                row.syndicate(section.syndicate);
                row.classType(section.classType);
                row.producingTeam(section.producingTeam);
                row.isMainSection = section.isMainSection;
                row.customerType = section.customerType;
                row.programRef = section.programRef;
                row.reinsured = section.reinsured ? { partyName: section.reinsured.partyName } : { partyName: "" };
                row.coverholder = section.coverholder ? { partyName: section.coverholder.partyName } : { partyName: "" };
                row.insured = section.insured ? { partyName: section.insured.partyName } : { partyName: "" };
                row.conductRating(section.conductRating);
                row.contractPeriodStartDate(section.contractPeriodStartDate);
                row.territoryIdAssured = section.territoryIdAssured;
                row.territoryId = section.territoryId;
                row.overridingCommission = section.overridingCommission;
                row.otherDeductions = section.otherDeductions;
                row.profitCommission = section.profitCommission;
                row.coverOperatingBasis = section.coverOperatingBasis;
                row.yoa(section.yoa);
                if (groupClassesForBISubLimit.indexOf(row.groupClass()) > -1) {
                    row.enableBISubLimit(true);
                }
                ////Get underwriters Data 

                let uwList = await self.getunderwriters(section);
                row.underwriters(uwList);
                row.uwInitials(section.uwInitials);
                //// Get MajorClass
                await self.underWriterChanged(index);
                row.majorClass(section.majorClass);

                self.majorClassChanged(index);
                row.minorClass(section.minorClass);
                self.minorClassChanged(index);
                row.subClass(section.subClass);

                row.policyRef(section.policyRef);
                blade.content.find('#searchBroker_autocomplete' + index).autocomplete({
                    source: bindbrokerData,
                    delay: 350,
                    minLength: 3,
                    select: function (event, ui) {
                        //Remove field validation
                        let elementId = $(this).prop("id");
                        let index = getRowId(elementId, "searchBroker_autocomplete");
                        clearBrokerContact(index);
                        self.policySections()[index].broker(ui.item.value);
                        self.policySections()[index].brokerCode(ui.item.brokerCode);
                        self.policySections()[index].lloydsBrokerId(ui.item.lloydsBrokerId);
                        self.policySections()[index].brokerPseud(ui.item.brokerPseud);
                    },
                    change: function (event, ui) {
                        let elementId = $(this).prop("id");
                        let index = getRowId(elementId, "searchBroker_autocomplete");
                        clearBrokerContact(index);
                        if (ui == null || ui.item === null) {
                            self.policySections()[index].broker(null);
                            self.policySections()[index].brokerCode(null)
                            self.policySections()[index].lloydsBrokerId(null);
                            self.policySections()[index].brokerPseud(null);
                            $(this).val("");
                        }
                    }
                });

                blade.content.find('#searchBrokerContact_autocomplete' + index).autocomplete({
                    source: async function (request, response) {
                        let elementId = $(this.element).prop("id");
                        let index = getRowId(elementId, "searchBrokerContact_autocomplete");
                        var brokerContactData = await britCacheService.getBrokerContact(request.term, self.policySections()[index].lloydsBrokerId());
                        blade.content.find('.ui-autocomplete-loading').removeClass("ui-autocomplete-loading");
                        if (brokerContactData == null) {
                            response([{ label: 'No results found', value: '-1' }]);
                        }
                        else {
                            response($.map(brokerContactData, function (el) {
                                if (el) {
                                    return {
                                        label: el.BrokerContactName,
                                        brokerContactName: el.BrokerContactName,
                                        individualID: el.IndividualID
                                    }
                                }
                            }));
                        }
                    },
                    delay: 350,
                    minLength: 1,
                    select: function (event, ui) {
                        let elementId = $(this).prop("id");
                        let index = getRowId(elementId, "searchBrokerContact_autocomplete");
                        self.policySections()[index].brokerContact(ui.item.brokerContactName);
                        self.policySections()[index].brokerContactId(ui.item.individualID);
                    },
                    change: function (event, ui) {
                        let elementId = $(this).prop("id");
                        let index = getRowId(elementId, "searchBrokerContact_autocomplete");
                        let brokerElement = $(this);
                        $.when(
                            brokerElement.focusout()).then(function () {
                                let IndId = self.policySections()[index].brokerContactId();

                                if ((IndId == 0 || IndId == undefined)
                                    && brokerElement.val() != "" && brokerElement.val() != undefined && self.policySections()[index].broker()) {
                                    if (self.policySections()[index].lloydsBrokerId() != 0 && self.policySections()[index].lloydsBrokerId() != undefined) {
                                        showBrokerEntryPopUp(brokerElement.val(), index)
                                    } else {
                                        clearBrokerContactSearch();
                                    }
                                }
                                else if (brokerElement.val() == "" || brokerElement.val() == undefined) {
                                    clearBrokerContactSearch();
                                }
                            });
                    }
                }).keyup(function () {
                        if ($(this).val() != "" && self.policySections()[index].brokerContact() != $(this).val().trim()) {
                            self.policySections()[index].brokerContactId(0);
                        }
                });

                if (riskEntrySheet.isReadOnlyAccess) {
                    row.isRiskEntrySheetLocked(true);
                }
                else {
                    row.isRiskEntrySheetLocked(section.isRiskEntrySheetLocked);
                    if (section.isRiskEntrySheetLocked) {
                        row.enableBISubLimit(false);
                    }
                }

            });
            promise.resolve();
        });
    }

    function clearBrokerContact(index) {
        self.policySections()[index].brokerContact(null);
        self.policySections()[index].brokerContactId(null);
        blade.content.find('#searchBrokerContact_autocomplete' + index).val("");
    }
    self.addPolicySectionRow = function () {
        self.policySections.push({
            isRiskEntrySheetLocked: ko.observable(false),
            policySectionId: 0,
            britPolicyId:0,
            policyRef: ko.observable(""),
            uwInitials: ko.observable(""),
            broker: ko.observable(""),
            brokerContact: ko.observable(""),
            brokerCode: ko.observable(""),
            lloydsBrokerId: ko.observable(""),
            brokerPseud: ko.observable(""),
            brokerContactId: ko.observable(""),
            classType: ko.observable(""),
            majorClass: ko.observable(""),
            minorClass: ko.observable(""),
            subClass: ko.observable(""),
            groupClass: ko.observable(""),
            enableBISubLimit: ko.observable(false),
            industryCode: ko.observable(""),
            limitCcy: ko.observable(""),
            limitBasis: ko.observable(""),
            contractCoverageId: ko.observable(""),
            subLimit: ko.observable(""),
            biSubLimitBasis: ko.observable(""),
            biSubLimitCcy: ko.observable(""),
            biSubLimit: ko.observable(""),
            excess: ko.observable(""),
            limit: ko.observable(""),
            deductible: ko.observable(""),
            innerAGG: ko.observable(""),
            adrLevel: ko.observable(""),
            cyberExposure: ko.observable(""),
            yoa: ko.observable(""),
            syndicate: ko.observable(""),
            producingTeam: ko.observable(""),
            isMainSection: false,
            customerType: "",
            programRef: "",
            reinsured: {},
            coverholder: {},
            insured: {},
            conductRating: ko.observable(""),
            contractPeriodStartDate: ko.observable(),
            statRefCodes : [],
            underwriters: ko.observableArray([]),
            majorClasses: ko.observableArray([]),
            minorClasses: ko.observableArray([]),
            subClasses: ko.observableArray([]),
            territoryIdAssured : null,
            territoryId :null,
            overridingCommission  : 0.00,
            otherDeductions :0.00,
            profitCommission: 0.00,
            coverOperatingBasis : null
        });
    }

    self.getunderwriters = async function (record) {
        let underwriters = [];
        let uwList = await britCacheService.getUWList(record);
        underwriters.push("");
        if (uwList.length > 0) {
            $.each(uwList, function (i, item) {
                if (item.UWInitials != null) {
                    item.UWName = item.UWInitials + ' - ' + item.UWName;
                    underwriters.push(item);
                }
            });
            underwriters = underwriters.sort(riskEntrySheet.utils.compareValues('UWInitials'));
        }
        return underwriters;
    }

    self.getMajorClass = function (majorClassesList) {

        let majorClassLst = [];
        if (majorClassesList.length > 0) {
            let uniqueMajorClass = [...new Set(majorClassesList.map(function (d) { return d.MajorClassValue; }))];
            let item1 = {};
            item1["MajorClassValue"] = "";
            item1["MajorClassDescription"] = "";
            item1["MajorClassLabel"] = "";
            majorClassLst.push(item1);
            $.each(uniqueMajorClass, function (index, item) {
                if (majorClassesList.some(({ MajorClassValue }) => MajorClassValue == item)) {
                    item1 = {};
                    item1["MajorClassValue"] = majorClassesList.find(({ MajorClassValue }) => MajorClassValue == item).MajorClassValue;
                    item1["MajorClassDescription"] = majorClassesList.find(({ MajorClassValue }) => MajorClassValue == item).MajorClassDescription;
                    item1["MajorClassLabel"] = item1.MajorClassValue + ' - ' + item1.MajorClassDescription;
                    if (item1 && item1["MajorClassValue"]) {
                        majorClassLst.push(item1);
                    }
                }
            });

            majorClassLst = majorClassLst.sort(riskEntrySheet.utils.compareValues('MajorClassValue'));
            return majorClassLst;
        }
    }

    self.getMinorClass = function (minorClassesList, record) {
        let minorClassLst = [];
        if (minorClassesList.length > 0) {

            minorClassesList = minorClassesList.filter(item => item.MajorClassValue === record.majorClass());

            let uniqueMinorClass = [...new Set(minorClassesList.map(function (d) { return d.MinorClassValue; }))];
            item1 = {};
            item1["MinorClassValue"] = "";
            item1["MinorClassDescription"] = "";
            item1["MinorClassLabel"] = "";
            minorClassLst.push(item1);
            $.each(uniqueMinorClass, function (index, item) {
                if (minorClassesList.some(({ MinorClassValue }) => MinorClassValue == item)) {
                    item1 = {};
                    item1["MinorClassValue"] = minorClassesList.find(({ MinorClassValue }) => MinorClassValue == item).MinorClassValue;
                    item1["MinorClassDescription"] = minorClassesList.find(({ MinorClassValue }) => MinorClassValue == item).MinorClassDescription;
                    item1["MinorClassLabel"] = item1.MinorClassValue + ' - ' + item1.MinorClassDescription;
                    if (item1 && item1["MinorClassValue"]) {
                        minorClassLst.push(item1);
                    }
                }
            });
            minorClassLst = minorClassLst.sort(riskEntrySheet.utils.compareValues('MinorClassValue'));
            return minorClassLst;
        }
    }

    self.getsubClasses = function (subClasses, record) {
        let subClassLst = [];
        if (subClasses.length > 0) {

            subClasses = subClasses.filter(item => item.MajorClassValue === record.majorClass() && item.MinorClassValue === record.minorClass());
            let uniqueSubClasses = [...new Set(subClasses.map(function (d) { return d.ClassValue; }))];
            let item1 = {};
            item1["ClassValue"] = "";
            item1["ClassDescription"] = "";
            item1["ClassLabel"] = "";
            subClassLst.push(item1);
            $.each(uniqueSubClasses, function (i, item) {
                if (subClasses.some(({ ClassValue }) => ClassValue == item)) {
                    item1 = {};
                    item1["ClassValue"] = subClasses.find(({ ClassValue }) => ClassValue == item).ClassValue;
                    item1["ClassDescription"] = subClasses.find(({ ClassValue }) => ClassValue == item).ClassDescription;
                    item1["ClassLabel"] = item1.ClassValue + ' - ' + item1.ClassDescription;
                    subClassLst.push(item1);
                }
            });
        }
        subClassLst = subClassLst.sort(riskEntrySheet.utils.compareValues('ClassValue'));
        return subClassLst;
    }

    self.underWriterChanged = async function (index) {
        if (event != undefined && event.target != undefined) {
            self.policySections()[index].majorClass("");
            self.policySections()[index].minorClass("");
            self.policySections()[index].subClass("");
            self.policySections()[index].statRefCodes = null;
            if (index > -1 && self.policySections()[index].uwInitials() && self.policySections()[index].uwInitials() != "") {
                let section = {
                    uwInitials: self.policySections()[index].uwInitials(),
                    yoa: self.policySections()[index].yoa(),
                    syndicate: self.policySections()[index].syndicate(),
                    producingTeam: self.policySections()[index].producingTeam(),
                    classType: self.policySections()[index].classType(),
                };
                let statRefs = await britCacheService.getMajorAndMinorClasses(section);
                self.policySections()[index].statRefCodes = statRefs;
                self.policySections()[index].majorClasses(self.getMajorClass(statRefs));
            }
        }
    }

    self.majorClassChanged = function (index) {
        if (event != undefined && event.target != undefined) {
            if (index > -1) {

                let section = self.policySections()[index];
                let statRefs = section.statRefCodes;
                if (section && section.majorClass()) {

                    var data = self.getMinorClass(statRefs, section);
                    self.policySections()[index].minorClasses(data);
                    self.policySections()[index].minorClass(section.minorClass);
                }
            }
        }
    }

    self.minorClassChanged = function (index) {
        if (event != undefined && event.target != undefined) {
            if (index > -1) {

                let section = self.policySections()[index];
                let statRefs = section.statRefCodes;
                if (section && section.minorClass()) {
                    var data = self.getsubClasses(statRefs, section);
                    self.policySections()[index].subClasses(data);
                    self.policySections()[index].subClass(section.subClass());
                }
            }
        }
    }



    function getRowId(elementId, elementNamePfx) {
        var rowId = elementId.replace(elementNamePfx, "");
        return rowId;
    }

    async function bindbrokerData(request, response) {

        var brokerData = await britCacheService.getBrokerData(request.term);
        blade.content.find('.ui-autocomplete-loading').removeClass("ui-autocomplete-loading");
        if (brokerData == null) {
            response([{ label: 'No results found', value: '-1' }]);
        }
        else {
            response($.map(brokerData, function (el) {
                if (el) {
                    return {
                        label: el.BrokerPseud + ' - ' + el.BrokerCode + ' - ' + el.BrokerName,
                        lloydsBrokerId: el.LloydsBrokerId,
                        brokerCode: el.BrokerCode,
                        value: el.BrokerName,
                        bureauInd: el.BureauInd,
                        brokerPseud: el.BrokerPseud
                    }
                }
            }));
        }
    }

    self.cancelBrokerContactEntry = function (rowId) {
        blade.content.find('#searchBrokerContact_autocomplete' + rowId).val("");
        self.policySections()[rowId].brokerContact("");
        self.policySections()[rowId].brokerContactId(null);
    }
    function showBrokerEntryPopUp(brokerContactName, rowId) {
        self.brokerContactModalData({
            brokerContact: brokerContactName,
            rowId: rowId
        });
        blade.content.find('#BrokerContactModalRiskEntry').modal({ show: true }, {backdrop: 'static', keyboard: false});
    }

    self.saveBrokerContactName = function (rowId) {
        blade.content.find('#BrokerContactModalRiskEntry').modal({ show: false });
    }

    self.copyFieldValue = function (index, fieldName) {
        var field = blade.content.find(`#${fieldName + index}`);
        var fieldVaue = field.val();
        var rowLength = self.policySections().length;
        if (fieldVaue !== "") {
            for (var i = 0; i < rowLength; i++) {
                var toBeCopiedField = blade.content.find(`#${fieldName + i}`);
                if (toBeCopiedField.val() == "" && i > index) {
                    if (!(toBeCopiedField.prop('disabled'))) {
                        var events = jQuery(toBeCopiedField).data('events');
                        console.log(events);
                        if (events.change.length > 0) {
                            toBeCopiedField.val(fieldVaue).trigger('change');
                            toBeCopiedField.val(fieldVaue).trigger('click');
                        }
                        else {
                            toBeCopiedField.val(fieldVaue);
                        }
                    }
                }
            }
        }
    }
}
