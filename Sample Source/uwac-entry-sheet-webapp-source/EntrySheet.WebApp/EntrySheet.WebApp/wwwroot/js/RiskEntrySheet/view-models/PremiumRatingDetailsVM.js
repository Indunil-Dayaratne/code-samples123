var riskEntrySheet = riskEntrySheet || {};

riskEntrySheet.PremiumRatingsViewModel = function (config, blade) {
    var self = this;
    var riskEntryClient = riskEntrySheetClient(config, blade);

    self.premiumRatingsDetails = ko.observableArray([]);
    self.reportingCcyLst = ko.observableArray([]);

    self.initialise = async function (premiumRatingsDetails) {

        let ccyList = await riskEntryClient.getReportingCcyList();

        if (ccyList && ccyList.length > 0) {
            ccyList.push("");
            ccyList.sort();
            self.reportingCcyLst(ccyList);
        }
        else {
            blade.flashErrorMessage("Unable to fetch Currencies from britcache.")
        }

        self.mapPremiumRatings(premiumRatingsDetails);
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

    }

    self.mapPremiumRatings = function (premiumRatingsDetails) {
        var promise = $.Deferred();
        riskEntrySheet.promises.push(promise);
        self.premiumRatingsDetails([]);
        var deferrds = [];
        $.each(premiumRatingsDetails, function (index, org) {
            deferrds.push(self.addPremiumRatingRow());
        });
        $.when.apply($, deferrds).then(function () {
            $.each(premiumRatingsDetails, async function (index, detail) {
                var row = self.premiumRatingsDetails()[index];
                row.policyPremiumRatingId(detail.policyPremiumRatingId);
                row.policyRef(detail.policyRef);
                row.premiumCcy(detail.premiumCcy);
                row.reportingCcy(detail.reportingCcy);
                row.writtenPremium(detail.writtenPremium);
                row.techPrice(detail.techPrice);
                row.modelPrice(detail.modelPrice);
                row.plr(detail.plr);
                row.changeInLDA(detail.changeInLDA);
                row.changeInCoverage(detail.changeInCoverage);
                row.changeInOther(detail.changeInOther);
                row.riskAdjustedRateChange(detail.riskAdjustedRateChange);
                row.baseAmount(detail.baseAmount);
                row.brokerage(detail.brokerage);
                row.premiumType = detail.premiumType;
                row.initialToT = detail.initialToT;
                row.paymentDate = detail.paymentDate;
                row.numberOfInstallment = detail.numberOfInstallment;
                row.brokerageRateType = detail.brokerageRateType;
                if (riskEntrySheet.isReadOnlyAccess) {
                    row.isRiskEntrySheetLocked(true);
                }
                else {
                    row.isRiskEntrySheetLocked(detail.isRiskEntrySheetLocked);
                }
            });
            promise.resolve();
        });
    }

    self.addPremiumRatingRow = function () {
        self.premiumRatingsDetails.push({
            isRiskEntrySheetLocked: ko.observable(false),
            policyPremiumRatingId: ko.observable(0),
            policyRef: ko.observable(""),
            premiumCcy: ko.observable(""),
            reportingCcy: ko.observable(""),
            writtenPremium: ko.observable(0),
            techPrice: ko.observable(0),
            modelPrice: ko.observable(0),
            plr: ko.observable(0),
            changeInLDA: ko.observable(0),
            changeInCoverage: ko.observable(0),
            changeInOther: ko.observable(0),
            riskAdjustedRateChange: ko.observable(0),
            baseAmount: ko.observable(0),
            brokerage: ko.observable(0),
            brokerageRateType: null,
            premiumType: null,
            initialToT: 0,
            paymentDate: null,
            numberOfInstallment: 0
        });
    }
    self.setTwoNumberDecimal = function (el) {
        let fixedVal = parseFloat(el()).toFixed(2);
        el(fixedVal);
    };

    self.copyFieldValue = function (index, fieldName) {
        var field = blade.content.find(`#${fieldName + index}`);
        var fieldVaue = field.val();
        var rowLength = self.premiumRatingsDetails().length;
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