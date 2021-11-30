var riskEntrySheet = riskEntrySheet || {};

riskEntrySheet.PolicyLinesViewModel = function (config, blade) {
    var self = this;
    var britCacheService = britCacheClient(config);
    self.lineStatuses = ko.observableArray([]);
    self.lines = ko.observableArray([]);
    self.statusReasons = ko.observableArray([]);
    self.quoteStatusReasonList = ko.observableArray([]);
    self.reinsCodeList = ko.observableArray([]);
    self.wholePartOrderList = ko.observableArray([]);
    self.percentageAmountIndList = ko.observableArray([]);
    self.isQuoteStatusAvailable = ko.observable(false);
    self.isNTUStatusAvailable = ko.observable(false);
    self.allLinesSigned = ko.observable(false);

    self.allSections = [];
    self.nonSignedSections = [];

    self.initialise = function (policyLines, policyInceptionDate) {
        blade.setLoading("Loading");
        let policyLineStatues = config.lineStatusLst.split(',');
        policyLineStatues.push("");
        policyLineStatues.sort();
        self.lineStatuses(policyLineStatues);
        let britCacheData = $.Deferred();
        riskEntrySheet.promises.push(britCacheData);
        //hide Quote Field Headers 
        blade.content.find("#statusReason").hide();
        blade.content.find("#quoteDate").hide();
        blade.content.find("#quoteDays").hide();
        blade.content.find('#deletePolicyLineRskSht').hide();

        $.when(britCacheService.getBusinessCodes("QuoteStatusReason", policyInceptionDate, riskEntrySheet.britCacheAccessToken),
            britCacheService.getBusinessCodes("ReinsCode", policyInceptionDate, riskEntrySheet.britCacheAccessToken),
            britCacheService.getBusinessCodes("WholePartOrder", policyInceptionDate, riskEntrySheet.britCacheAccessToken),
            britCacheService.getBusinessCodes("PercentageAmountInd", policyInceptionDate, riskEntrySheet.britCacheAccessToken)
        ).done(function (deferQuoteStatusReason, deferReinsCode, deferWholePartOrder, deferPercentageAmountInd) {

            if (deferQuoteStatusReason && deferQuoteStatusReason.length > 0) {
                let dataList = deferQuoteStatusReason.map(function (businessCode) { return businessCode.Value + "-" + businessCode.Description });
                dataList.push("");
                dataList.sort();
                self.quoteStatusReasonList(dataList);
            }
            else {
                blade.flashErrorMessage("Unable to fetch quote status reasons from britcache.")
            }
            if (deferReinsCode && deferReinsCode.length > 0) {
                let dataList = deferReinsCode.map(function (businessCode) { return { code: businessCode.Value, description: businessCode.Value + "-" + businessCode.Description } });
                dataList.push({ code: "", description: "" });
                dataList.sort(riskEntrySheet.utils.compareValues("code"));
                self.reinsCodeList(dataList);
            }
            else {
                blade.flashErrorMessage("Unable to fetch RI Codes from britcache.")
            }
            if (deferWholePartOrder && deferWholePartOrder.length > 0) {
                let dataList = deferWholePartOrder.map(function (businessCode) { return businessCode.Value })
                dataList.push("");
                dataList.sort();
                self.wholePartOrderList(dataList);
                dataList = deferPercentageAmountInd.map(function (businessCode) { return businessCode.Value });
                dataList.push("");
                dataList.sort();
                self.percentageAmountIndList(dataList);
            }
            else {
                blade.flashErrorMessage("Unable to fetch Percentage amount indicator from britcache.")
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
            self.mapLineDetails(policyLines);
        });
    }

   
    self.mapLineDetails = function (policyLines) {
        let promise = $.Deferred();
        riskEntrySheet.promises.push(promise);
     
        //Check for duplicates 
        $.each(policyLines, function (index, line) {
            let sectionsCount = self.allSections.filter(item => item === line.section);
            if (sectionsCount.length == 0) {
                self.allSections.push(line.section);
            }
            if (sectionsCount.length == 0 && !line.isRiskEntrySheetLocked) {
                self.nonSignedSections.push(line.section);
            }
        });
        self.nonSignedSections.push("");
        self.nonSignedSections.sort();

        self.lines([]);
        var deferrds = [];
        $.each(policyLines, function (index, lines) {
            deferrds.push(self.addLineRow(index));
        });

        blade.content.find('#deletePolicyLineRskSht').hide();
        

        $.when.apply($, deferrds).then(function () {
            $.each(policyLines, async function (index, line) {
                var row = self.lines()[index];
                if (line.isRiskEntrySheetLocked) {
                    row.lineSections(self.allSections);
                }
                else {
                    row.lineSections(self.nonSignedSections);
                }
                row.policyLineId(line.policyLineId);
                row.lbs(line.lbs);
                row.lineSection(line.section);
                row.entity(line.entity);
                row.lineStatus(line.lineStatus);
                row.wlIndicator(line.wlInd);
                row.writtenLine(line.writtenLine);
                row.estSign(line.estSign);
                row.wo(line.wo);
                row.order(line.order);
                row.riCode(line.riCode);
                row.exposure(line.exposure);
                row.gnwp(line.gnwp);
                row.policyRef(line.policyRef);
                row.statusReason(line.statusReason);
                row.riskAllocationCode = line.riskAllocationCode;
                row.writtenDateTime = line.writtenDateTime;
                if (line.quoteDate) {
                    row.quoteDate(convertJSONDate(line.quoteDate, "dd-MMM-yyyy"));
                }
                row.quoteDays(line.quoteDays);
                row.quoteId(line.quoteId);
                if (line.lineStatus === 'Quote') {
                    row.isQuoteStatus(true);
                    self.isQuoteStatusAvailable(true);
                }
                if (line.lineStatus === 'NTU' || line.lineStatus === 'Decline') {
                    row.isNTUStatus(true);
                    self.isNTUStatusAvailable(true);
                }
                row.isNewPolicyLine(false);

                if (riskEntrySheet.isReadOnlyAccess) {
                    row.isRiskEntrySheetLocked(true);
                }
                else {
                    row.isRiskEntrySheetLocked ( line.isRiskEntrySheetLocked);
                }

                displayQuoteFields(index);
            })

            //Check if all lines are signed 
            let isSigned = policyLines.every(function (item) {
                return item.isRiskEntrySheetLocked==true;
            });
            if (isSigned) {
                self.allLinesSigned(true);
            }

            promise.resolve();
        });
    }

    self.addLineRow = function(index=-1)
    {
        self.lines.push(
            {
                isRiskEntrySheetLocked: ko.observable(false),
                policyLineId : ko.observable(0),
                lbs : ko.observable(false),
                lineSection : ko.observable(""),
                entity : ko.observable(""),
                lineStatus: ko.observable(""),
                isQuoteStatus: ko.observable(false),
                isNTUStatus: ko.observable(false),
                wlIndicator : ko.observable(""),
                writtenLine : ko.observable(0),
                estSign : ko.observable(0),
                wo: ko.observable(""),
                order : ko.observable(0),
                riCode : ko.observable(""),
                exposure : ko.observable(0),
                gnwp  : ko.observable(0),
                policyRef: ko.observable(""),
                statusReason: ko.observable(""),
                quoteDate: ko.observable(null),
                quoteDays: ko.observable(0),
                isNewPolicyLine: ko.observable(true),
                quoteId: ko.observable(0),
                lineSections: ko.observableArray([]),
                riskAllocationCode: null,
                writtenDateTime : null,

            });

        if (index == -1) {
            index = self.lines() ? self.lines().length - 1 : 0;
            self.lines()[index].lineSections(self.nonSignedSections);
        }
        initialiseInceptionDatePicker("quoteDate" + index, index);
        blade.content.find('#deletePolicyLineRskSht').show();
    }

    function initialiseInceptionDatePicker(elementid,index) {
        let currentYear = new Date().getFullYear();
        let startYearDate = currentYear - 2;
        let endYearDate = currentYear + 1;
        blade.content.find(`#${elementid}`).datepicker({
            dateFormat: 'dd-M-yy',
            closeText: 'Clear',
            changeYear: true,
            changeMonth: true,
            showOn: 'focus',
            showButtonPanel: true,
            yearRange: startYearDate + ":" + endYearDate,
            minDate: new Date(startYearDate, 0, 1),
            maxDate: new Date(endYearDate, 11, 31),
            onSelect: function () {
                var dateElement = blade.content.find(`#${elementid}`);
                dateElement.parent().find('label.field-validation-error').remove();
                if (dateElement.datepicker("getDate") == null) {
                    self.lines()[index].quoteDate("");
                }
                else {
                    self.lines()[index].quoteDate(convertJSONDate(dateElement.datepicker("getDate"), "dd-MMM-yyyy"));
                }
            },
            onClose: function () {
                var event = arguments.callee.caller.caller.arguments[0];
                if ($(event.delegateTarget).hasClass('ui-datepicker-close')) {
                    var dateElement = blade.content.find(`#${elementid}`);
                    dateElement.val('');
                    dateElement.parent().find('label.field-validation-error').remove();
                }
            }
        });
    }

    self.removeLine = function (index) {
        if (self.lines().length > 1) {
            let lstLines = self.lines();
            lstLines.splice(index, 1);
            self.lines(lstLines);
        } else {
            blade.flashErrorMessage("Risk entry should have at least one line");
        }
        var ifAnyNewAddedLine = self.lines().filter(item => item.isNewPolicyLine==true);
        if (ifAnyNewAddedLine && ifAnyNewAddedLine.length > 0) {
            blade.content.find('#deletePolicyLineRskSht').show();
        }
        else {
            blade.content.find('#deletePolicyLineRskSht').hide();
        }
    }
    self.lineStatusChanged = function (index) {
        if (event != undefined && event.target != undefined) {
            if (index > -1) {
                let lineDetail = self.lines()[index];

                self.lines()[index].isNTUStatus(false);
                self.lines()[index].isQuoteStatus(false);
                self.lines()[index].statusReason("");
                self.lines()[index].quoteDate(null);
                self.lines()[index].quoteDays(0);

                if (lineDetail.lineStatus() === 'Quote') {
                    self.lines()[index].isQuoteStatus(true);
                }
                else if (lineDetail.lineStatus() === 'NTU' || lineDetail.lineStatus() === 'Decline') {
                    self.lines()[index].isNTUStatus(true);
                }
            }
            displayQuoteFields(index);
        }
    }
    
          
    function displayQuoteFields(index) {
        //Check if any status is NTU Or Quote
        let match = ko.utils.arrayFirst(self.lines(), function (item) {
            return item.isQuoteStatus() == true;
        });
        if (match && match.isQuoteStatus()) {
            self.isQuoteStatusAvailable(true);
        }
        else {
            self.isQuoteStatusAvailable(false);
        }
        match = ko.utils.arrayFirst(self.lines(), function (item) {
            return item.isNTUStatus() == true;
        });
        if (match && match.isNTUStatus()) {
            self.isNTUStatusAvailable(true);
        }
        else {
            self.isNTUStatusAvailable(false);
        }

        if (self.isQuoteStatusAvailable()) {

            blade.content.find("#quoteDate").show();
            blade.content.find("#quoteDays").show();
            blade.content.find("#quoteDate" + index).addClass("field-recommended required");
            blade.content.find("#txtQuoteDays" + index).addClass("field-recommended required");
        }
        else if (!self.isQuoteStatusAvailable()) {
            blade.content.find("#quoteDate").hide();
            blade.content.find("#quoteDays").hide();
            blade.content.find("#quoteDate" + index).removeClass("field-recommended required");
            blade.content.find("#txtQuoteDays" + index).removeClass("field-recommended required");
        }
        if (self.isNTUStatusAvailable()) {
            blade.content.find("#statusReason").show();
            blade.content.find("#selStatusReason" + index).addClass("field-recommended required");
        }
        else if (!self.isNTUStatusAvailable()) {
            blade.content.find("#statusReason").hide();
            blade.content.find("#selStatusReason" + index).removeClass("field-recommended required");
        }
    }
    

    self.copyFieldValue = function (index, fieldName) {
        var field = blade.content.find(`#${fieldName + index}`);
        var fieldVaue = field.val();
        var rowLength = self.lines().length;
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