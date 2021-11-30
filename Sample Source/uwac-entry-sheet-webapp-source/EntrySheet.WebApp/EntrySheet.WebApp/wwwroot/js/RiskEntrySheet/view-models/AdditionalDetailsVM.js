var riskEntrySheet = riskEntrySheet || {};

riskEntrySheet.AdditionalDetailsViewModel = function (config, blade) {
    var self = this;
    var britCacheService = britCacheClient(config);
    var riskEntrySheetSvc = riskEntrySheetClient(config, blade);

    self.additionalDetails = ko.observableArray([]);
    self.aggRiskList = ko.observableArray([]);
    self.insuranceLevels = ko.observableArray([]);
    self.riskRatings = ko.observableArray([]);
    self.contractExceptionCodes = ko.observableArray([]);
    self.regularExpressionForPeriod = new RegExp("^(?=.*?[0-9])[0-9]+[DdMmWwQqYy]$");
    self.numberRegExp = new RegExp("[0-9]");

    self.initialise = async function (policyAdditionalDetails, policyInceptionDate) {
        blade.setLoading("Loading");
        
        let britCacheData = $.Deferred();
       riskEntrySheet.promises.push(britCacheData);

        $.when(britCacheService.getBusinessCodes("InsuranceLevel", policyInceptionDate, riskEntrySheet.britCacheAccessToken),
            riskEntrySheetSvc.getRiskRatings(),
            britCacheService.getBusinessCodes("AggRiskData", policyInceptionDate, riskEntrySheet.britCacheAccessToken),
            britCacheService.getBusinessCodes("ContractCertainExceptionCodes", policyInceptionDate, riskEntrySheet.britCacheAccessToken)
        ).done(function (deferInsuranceLevel, deferRiskRating, deferAggRiskData,deferContractExceptionCode) {

            if (deferRiskRating && deferRiskRating.length > 0) {
                let dataRisks = deferRiskRating.map(function (riskRating) {
                    return {
                        code: riskRating, description: riskRating
                    }
                });
                dataRisks.push({ code: "", description: "" });
                dataRisks.sort(riskEntrySheet.utils.compareValues('code'));
                self.riskRatings(dataRisks);
            }
            else {
                blade.flashErrorMessage("Unable to fetch risk ratings.")
            }

            if (deferInsuranceLevel && deferInsuranceLevel.length > 0) {
                let dataInsLevels = deferInsuranceLevel.map(function (businessCode) {
                    return {
                        code: businessCode.Value, description: businessCode.Value + "-" + businessCode.Description
                    }
                });
                dataInsLevels.push({ code: "", description: "" });
                self.insuranceLevels(dataInsLevels);
                let dataAggRisks = deferAggRiskData.map(function (businessCode) { return businessCode.Value });
                dataAggRisks.push("");
                self.aggRiskList(dataAggRisks);
            }
            else {
                blade.flashErrorMessage("Unable to Insurance levels.")
            }

            if (deferContractExceptionCode && deferContractExceptionCode.length > 0) {
                let exceptionCodes = deferContractExceptionCode.map(function (businessCode) {
                    return {
                        code: businessCode.Value, description: businessCode.Value + "-" + businessCode.Description
                    }
                });
                exceptionCodes.push({ code: "", description: "" });
                exceptionCodes.sort(riskEntrySheet.utils.compareValues('code'));
                self.contractExceptionCodes(exceptionCodes);
            }
            else {
                blade.flashErrorMessage("Unable to fetch Contract Exception Codes.")
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
            self.mapAdditionalDetails(policyAdditionalDetails);
        });
        
}

   

    self.mapAdditionalDetails = function (policyAdditionalDetails) {
        var promise = $.Deferred();
       riskEntrySheet.promises.push(promise);
        self.additionalDetails([]);
        var deferrds = [];
        $.each(policyAdditionalDetails, function (index, org) {
            deferrds.push(self.addRowOfAdditionalDetails());
        });
        $.when.apply($, deferrds).then(function () {
            $.each(policyAdditionalDetails, async function (index, detail) {
                initialiseInceptionDatePicker("inceptionDate" + index,index);
                initialiseInceptionDatePicker("contractCertainDate" + index, index);
                var row = self.additionalDetails()[index];
                row.policyAdditionalDetailId(detail.policyAdditionalDetailId);
                row.policyRef(detail.policyRef);
                row.placingType(detail.placingType);
                row.groupClass(detail.groupClass);
                row.period(detail.timeDurationValue + detail.timeDurationPeriodType);
                row.periodType(detail.timeDurationPeriodType);
                row.periodLength(detail.timeDurationValue);
                row.expiryDate(detail.expiryDate);
                if (detail.inceptionDate) {
                    row.inceptionDate(convertJSONDate(detail.inceptionDate, "dd-MMM-yyyy"));
                }
                row.riskRating(detail.riskRating);
                row.aggRiskData(detail.aggRiskData);
                row.insuranceLevel(detail.insuranceLevel);
                let ccValue = detail.contractCertain == null ? "" : detail.contractCertain ==true ? 'Yes' : 'No';
                row.contractCertain(ccValue);
                blade.content.find('#selContractCertain' + index).change();
                row.contractCertainCode(detail.contractCertainCode);
                if (detail.contractCertainDate) {
                    row.contractCertainDate(convertJSONDate(detail.contractCertainDate, "dd-MMM-yyyy"));
                };
                if (riskEntrySheet.isReadOnlyAccess) {
                    row.isRiskEntrySheetLocked(true);
                }
                else {
                    row.isRiskEntrySheetLocked (detail.isRiskEntrySheetLocked);
                }
            });
        });
        promise.resolve();
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
                if (elementid.indexOf("contractCertainDate") > -1) {
                    if (dateElement.datepicker("getDate") == null) {
                        self.additionalDetails()[index].contractCertainDate("");
                    }
                    else {
                        self.additionalDetails()[index].contractCertainDate(convertJSONDate(dateElement.datepicker("getDate"), "dd-MMM-yyyy"));
                    }
                }
               
                if (elementid.indexOf("inceptionDate") > -1) {
                    if (dateElement.datepicker("getDate") == null) {
                        self.additionalDetails()[index].inceptionDate("");
                    }
                    else {
                        self.additionalDetails()[index].inceptionDate(convertJSONDate(dateElement.datepicker("getDate"), "dd-MMM-yyyy"));
                    }
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

    self.addRowOfAdditionalDetails = function () {
        self.additionalDetails.push({
            isRiskEntrySheetLocked: ko.observable(false),
            policyAdditionalDetailId: ko.observable(0),
            policyRef: ko.observable(""),
            placingType: ko.observable(""),
            periodType: ko.observable(""),
            periodLength: ko.observable(""),
            groupClass: ko.observable(""),
            inceptionDate: ko.observable(""),
            expiryDate: ko.observable(""),
            period: ko.observable(""),
            aggRiskData: ko.observable(""),
            insuranceLevel: ko.observable(""),
            contractCertainCode: ko.observable(""),
            contractCertain: ko.observable(null),
            riskRating: ko.observable(""),
            contractCertainDate: ko.observable(null)
        });
    }

    self.contractCertainChanged = function (index) {
        let detail = self.additionalDetails()[index];
        blade.content.find("#selContractCertainExceptionCode" + index).parent().find('label.field-validation-error').remove();
        blade.content.find("#selContractCertainExceptionCode" + index).removeClass('error');
        if (detail.contractCertain() === "No") {
            blade.content.find("#selContractCertainExceptionCode" + index).addClass("field-recommended required");
        }
        else {
            blade.content.find("#selContractCertainExceptionCode" + index).removeClass("field-recommended required");
        }
    }

    self.periodChanged = function (index) {
        //Validate for Regular Expression 
        let elementid = blade.content.find("#txtPeriod" + index);
        let enteredValue = elementid.val();
        if (!self.regularExpressionForPeriod.test(enteredValue)) {
        }
        else {
            //Bind the values for period length and period type
                let periodType = enteredValue.substr(enteredValue.length - 1, 1);
                let numbers = enteredValue.substr(0, enteredValue.length - 1);
                self.additionalDetails()[index].periodLength(numbers);
                self.additionalDetails()[index].periodType(periodType);
        }
    }
    

    self.copyFieldValue = function (index, fieldName) {
        var field = blade.content.find(`#${fieldName + index}`);
        var fieldVaue = field.val();
        var rowLength = self.additionalDetails().length;
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