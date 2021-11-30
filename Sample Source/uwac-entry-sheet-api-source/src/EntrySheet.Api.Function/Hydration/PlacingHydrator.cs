using System;
using System.Collections.Generic;
using System.Linq;
using Brit.Risk.Entities;
using EntrySheet.Api.Function.Mappers;
using EntrySheet.Api.Function.Models;

namespace EntrySheet.Api.Function.Hydration
{
    public class PlacingHydrator : IPlacingHydrator
    {
        private const int maxDecimalPlaces = 2;
        public List<Placing> Execute(EntrySheetDetailsModel entrySheetDetailsModel, string saveRequestApiUri)
        {
            var placings = new List<Placing>();
            var placingFactory = new PlacingFactory();

            foreach (var contractSectionModel in entrySheetDetailsModel.ContractSection)
            {
                var placing = placingFactory.BuildEmptyPlacing();

                placing.WebApplication.UserId = entrySheetDetailsModel.LastUpdatedBy;
                placing.WebApplication.Url = saveRequestApiUri;
               
                PopulatePlacingFromEntrySheetDetailsModel(entrySheetDetailsModel, placing,contractSectionModel.BritPolicyId);
                
                PopulatePlacingFromContractSectionModel(contractSectionModel, placing);
                PopulatePlacingFromPremiumRatingModel(entrySheetDetailsModel.PremiumRatings.First(x => x.PolicyRef == contractSectionModel.PolicyRef), placing);
                PopulatePlacingFromAdditionalDetails(entrySheetDetailsModel.AdditionalDetails.First(x => x.PolicyRef == contractSectionModel.PolicyRef), placing);

                foreach (var policyLineModel in entrySheetDetailsModel.PolicyLines.Where(x => x.PolicyRef == contractSectionModel.PolicyRef))
                {
                    var contractSection = placing.ContractSections.First();
                    var contractMarket = placingFactory.BuildEmptyContractMarket();
                    PopulateContractMarketFromPolicyLineModel(policyLineModel, contractMarket);
                    contractSection.ContractMarkets.Add(contractMarket);
                    PopulatePlacingFromPolicyLineModel(placing, policyLineModel);
                }

                placings.Add(placing);
            }

            return placings;
        }

        private void PopulatePlacingFromPolicyLineModel(Placing placing, PolicyLineModel policyLineModel)
        {
            if (policyLineModel.LineStatus.Equals("Quote", StringComparison.OrdinalIgnoreCase) && policyLineModel.QuoteDate.HasValue && policyLineModel.QuoteDays > 0)
            {
                placing.QuoteRequestedByDate = policyLineModel.QuoteDate;
                placing.QuoteValidUntilDate = policyLineModel.QuoteDate.Value.AddDays(policyLineModel.QuoteDays);
                placing.BritAttributes.PasSystemQuoteId = policyLineModel.QuoteId == "0" ? null : policyLineModel.QuoteId;
            }
        }

        private void PopulateContractMarketFromPolicyLineModel(PolicyLineModel policyLineModel, ContractMarket contractMarket)
        {
            contractMarket.BritAttributes.PasSystemPolicyLineId = policyLineModel.PolicyLineId=="0" ? null : policyLineModel.PolicyLineId;
            contractMarket.Insurer.Party.Id = policyLineModel.Entity;
            contractMarket.MarketAddressedIndicator = true;
            contractMarket.LineTransactionFunction = policyLineModel.LineStatus;
            contractMarket.BritAttributes.InsurerWrittenLineIndicator = policyLineModel.WLInd;
            contractMarket.InsurerSharePercentage.Rate.Value = MappingHelper.GetInsurerSharePercentage(policyLineModel.WLInd, policyLineModel.WrittenLine);
            contractMarket.InsurerSharePercentage.Rate.RateUnit = MappingHelper.GetInsurerSharePercentage(policyLineModel.WLInd, policyLineModel.WrittenLine) > 0 ? "Percentage" : string.Empty;
            contractMarket.InsurerShareLimitAmount.Amt.Value = MappingHelper.GetInsurerShareLimitAmount(policyLineModel.WLInd, policyLineModel.WrittenLine);
            contractMarket.BritAttributes.ReInsuranceCode = string.IsNullOrEmpty(policyLineModel.RICode) ? null : policyLineModel.RICode;
            contractMarket.BritAttributes.Exposure.Amt.Value = policyLineModel.Exposure;
            contractMarket.InsurerShareNetPremiumAmount.Amt.Value = policyLineModel.GNWP;
            contractMarket.BritAttributes.WholePartOrder = MappingHelper.GetWholePartOrderFullName(policyLineModel.WO);
            contractMarket.BritAttributes.EstimatedSigningDownPercentage.Rate.Value = RoundToTwoDecimalPlaces(policyLineModel.EstSign);
            contractMarket.BritAttributes.EstimatedSigningDownPercentage.Rate.RateUnit = "Percentage";
            contractMarket.BritAttributes.OrderPercentage.Rate.Value = RoundToTwoDecimalPlaces(policyLineModel.Order);
            contractMarket.BritAttributes.OrderPercentage.Rate.RateUnit = "Percentage";
            contractMarket.PremiumRegulatoryAllocationSchemes.First().Allocations.First().AllocationCode = policyLineModel.RiskAllocationCode;
            contractMarket.WrittenDateTime = policyLineModel.WrittenDateTime;
        }

        private void PopulatePlacingFromEntrySheetDetailsModel(EntrySheetDetailsModel entrySheetDetailsModel, Placing placing,int britPolicyId)
        {
            var policyDetails = entrySheetDetailsModel.RelatedPoliciesDetails?.First(item => item.BritPolicyId == britPolicyId);
            var contractSection = placing.ContractSections.First();
            placing.Contract.InsurerReference = string.IsNullOrEmpty(policyDetails?.ProgramRef) ? null : policyDetails.ProgramRef;
            placing.BritAttributes.ConductRating = string.IsNullOrEmpty(policyDetails?.ConductRating) ? null : policyDetails.ConductRating;
            contractSection.FSAClientClassifications.First().FSAClientClass = string.IsNullOrEmpty(policyDetails?.CustomerType) ? null : policyDetails.CustomerType;
            placing.Insured.Party.Name = string.IsNullOrEmpty(policyDetails?.Insured?.PartyName) ? null : policyDetails.Insured?.PartyName;
            placing.Reinsurer.Party.Name = string.IsNullOrEmpty(policyDetails?.Reinsured?.PartyName) ? null : policyDetails.Reinsured?.PartyName;
            placing.CoverHolder.Party.Name = string.IsNullOrEmpty(policyDetails?.Coverholder?.PartyName) ? null : policyDetails.Coverholder?.PartyName;
            placing.BritAttributes.UniqueMarketRef = policyDetails?.UniqueMarketRef ?? null;
            placing.BritAttributes.LloydsLeader = policyDetails?.LloydsLeader ?? null;
            placing.BritAttributes.CompanyLeader = policyDetails?.CompanyLeader ?? null;
            placing.BritAttributes.PlacingType = policyDetails?.PlacingType;
            placing.BritAttributes.InstalmentPeriod = policyDetails?.InstalmentPeriod;
        }
           

        private void PopulatePlacingFromContractSectionModel(ContractSectionModel contractSectionModel, Placing placing)
        {
            var contractSection = placing.ContractSections.First();

            contractSection.BritAttributes.PasSystemPolicyId = contractSectionModel.PolicySectionId;
            contractSection.BritAttributes.IsMainSection = contractSectionModel.IsMainSection;
            contractSection.SectionReference = contractSectionModel.PolicyRef;
            placing.Insurer.Contact.BritAttributes.Initials = contractSectionModel.UWInitials;
            placing.Broker.Party.Name = string.IsNullOrEmpty(contractSectionModel.BrokerName) ? null : contractSectionModel.BrokerName;
            placing.Broker.Contact.PersonName = string.IsNullOrEmpty(contractSectionModel.ContactName) ? null : contractSectionModel.ContactName;
            placing.BritAttributes.PasSystemBrokerId = string.IsNullOrEmpty(contractSectionModel.LloydsBrokerId) ? null : contractSectionModel.LloydsBrokerId;
            placing.Broker.Party.Id = string.IsNullOrEmpty(contractSectionModel.BrokerCode) ? null : contractSectionModel.BrokerCode;
            placing.BritAttributes.BrokerPseud = string.IsNullOrEmpty(contractSectionModel.BrokerPseud) ? null : contractSectionModel.BrokerPseud;
            placing.Broker.Contact.BritAttributes.PasSystemContactId = string.IsNullOrEmpty(contractSectionModel.BrokerContactId) ? null : contractSectionModel.BrokerContactId;
            contractSection.BritAttributes.ClassType = contractSectionModel.ClassType;
            contractSection.BritAttributes.MinorClass = contractSectionModel.MinorClass;
            contractSection.ContractSectionClasses.First().JvClassOfBusiness = contractSectionModel.MajorClass;
            contractSection.BritAttributes.SubClass = contractSectionModel.SubClass;
            contractSection.CoverOperatingBasis = contractSectionModel.CoverOperatingBasis;

            var topCoverage = MappingHelper.GetTopCoverage(placing);
            topCoverage.CoverageAmount.Amt.Ccy = string.IsNullOrEmpty(contractSectionModel.LimitCcy) ? null : contractSectionModel.LimitCcy; ;
            topCoverage.CoverageAmount.Amt.Value = contractSectionModel.Limit;
            topCoverage.CoverageBasis = string.IsNullOrEmpty(contractSectionModel.LimitBasis) ? null : contractSectionModel.LimitBasis;
            topCoverage.BritAttributes.PasSystemContractCoverageId = string.IsNullOrEmpty(contractSectionModel.ContractCoverageId) ? null : contractSectionModel.ContractCoverageId;

            if (!string.IsNullOrEmpty(contractSectionModel.BiSubLimitBasis))
            {
                var biSubLimitCoverage = new ContractCoverage
                {
                    BritAttributes = new BritContractCoverage(),
                    CoverageAmount = new AnyAmt { Amt = new Amt() },
                    CoverageBasis = string.IsNullOrEmpty(contractSectionModel.BiSubLimitBasis) ? null : contractSectionModel.BiSubLimitBasis
            };

                biSubLimitCoverage.CoverageAmount.Amt.Ccy = string.IsNullOrEmpty(contractSectionModel.BiSubLimitCcy) ? null : contractSectionModel.BiSubLimitCcy;
                biSubLimitCoverage.CoverageAmount.Amt.Value = contractSectionModel.BiSubLimit;

                contractSection.ContractCoverages.Add(biSubLimitCoverage);
            }

            if(!string.IsNullOrEmpty(contractSectionModel.CyberExposure))
            {
                topCoverage.BritAttributes.PerilCode = contractSectionModel.CyberExposure;
            }

            contractSection.ContractDeductibles
                .First(f => f.DeductibleType == "loss_excess_policy").DeductibleAmount.Amt.Value = contractSectionModel.Excess;
            contractSection.ContractDeductibles
                .First(f => f.DeductibleType == "retention").DeductibleAmount.Amt.Value = contractSectionModel.Deductible;
            contractSection.BritAttributes.InnerAgg.Amt.Value = contractSectionModel.InnerAGG;
            contractSection.BritAttributes.AdrLevel = string.IsNullOrEmpty(contractSectionModel.ADRLevel) ? null : contractSectionModel.ADRLevel;
            contractSection.ContractPeriod.StartDate = contractSectionModel.ContractPeriodStartDate;
            placing.BritAttributes.ProducingTeam = contractSectionModel.ProducingTeam;
            contractSection.UnderwritingYear = contractSectionModel.YOA;
            
            contractSection.OverridingCommission = contractSectionModel.OverridingCommission > 0 ?
                            new OverridingCommission
                            {
                                OverridingCommissionPercentage = new AnyRate
                                {
                                    Rate = new Rate {Value = contractSectionModel.OverridingCommission }
                                }
                            } : null;

            contractSection.ProfitCommission = contractSectionModel.ProfitCommission > 0 ?
                            new ProfitCommission
                            {
                                ProfitCommissionPercentage = new AnyRate
                                {
                                    Rate = new Rate { Value = contractSectionModel.ProfitCommission }
                                }
                            } : null;

            contractSection.OtherDeductions = contractSectionModel.OtherDeductions > 0 ?
                            new OtherDeductions
                            {
                                OtherDeductionsPercentage = new AnyRate
                                {
                                    Rate = new Rate { Value = contractSectionModel.OtherDeductions }
                                }
                            } : null;
            contractSection.RiskLocations = new List<RiskLocation> { new RiskLocation
                                            {
                                                Location  = new Location
                                                {
                                                    Supraentity = contractSectionModel.TerritoryId ?? null,
                                                    Country = contractSectionModel.TerritoryIdAssured ?? null
                                                }
                                            }
                                        };
        }

        private void PopulatePlacingFromPremiumRatingModel(PremiumRatingModel premiumRatingModel, Placing placing)
        {
            var contractSection = placing.ContractSections.First();
            var premium = contractSection.Premiums.First();

            premium.BritAttributes.PasSystemPremiumId = premiumRatingModel.PolicyPremiumRatingId;
            var premiumAmount = premium.PremiumAmount.First();
            premiumAmount.Ccy = string.IsNullOrEmpty(premiumRatingModel.PremiumCcy) ? null : premiumRatingModel.PremiumCcy;
            premiumAmount.Value = premiumRatingModel.WrittenPremium;
            premium.BritAttributes.TechnicalPrice.Value = premiumRatingModel.TechPrice;
            premium.BritAttributes.ModelPrice.Value = premiumRatingModel.ModelPrice;
            premium.BritAttributes.ProjectedLossRatio.Rate.Value = RoundToTwoDecimalPlaces(premiumRatingModel.PLR);
            premium.BritAttributes.ProjectedLossRatio.Rate.RateUnit = "Percentage";
            premium.BritAttributes.ChangeInLDA.Rate.Value = premiumRatingModel.ChangeInLDA;
            premium.BritAttributes.ChangeInCoverage.Rate.Value =
                premiumRatingModel.ChangeInCoverage;
            premium.BritAttributes.ChangeInOther.Rate.Value =
                premiumRatingModel.ChangeInOther;
            premium.BritAttributes.RiskAdjustedRateChange.Rate.Value =
                premiumRatingModel.RiskAdjustedRateChange;
            contractSection.BritAttributes.ReportingCcy = string.IsNullOrEmpty(premiumRatingModel.ReportingCcy) ? null : premiumRatingModel.ReportingCcy;
            premium.PremiumType = premiumRatingModel.PremiumType;
            premium.TermsOfTradePeriod.TimeDuration.Value = premiumRatingModel.InitialToT;
            premium.PaymentDate = premiumRatingModel.PaymentDate;
            premium.InstalmentsTotalNbr.Count = premiumRatingModel.NumberOfInstallment;
            var brokerage = MappingHelper.MapBrokerage(premiumRatingModel);
            contractSection.Brokerages = brokerage !=null ? new List<Brokerage> { brokerage} :null;
        }

        private void PopulatePlacingFromAdditionalDetails(AdditionalDetailModel additionalDetailModel, Placing placing)
        {
            var contractSection = placing.ContractSections.First();

            contractSection.BritAttributes.IsContractCertain = additionalDetailModel.ContractCertain == null ? null : additionalDetailModel.ContractCertain;
            contractSection.BritAttributes.ContractCertainExceptionCode = string.IsNullOrEmpty(additionalDetailModel.ContractCertainCode) ? null : additionalDetailModel.ContractCertainCode;
            contractSection.BritAttributes.ContractCertainDate = additionalDetailModel.ContractCertainDate;
            contractSection.BritAttributes.RiskRating = string.IsNullOrEmpty(additionalDetailModel.RiskRating) ? null : additionalDetailModel.RiskRating;
            placing.BritAttributes.AggRiskData = string.IsNullOrEmpty(additionalDetailModel.AggRiskData) ? null : additionalDetailModel.AggRiskData; ;
            contractSection.BritAttributes.InsuranceLevel = string.IsNullOrEmpty(additionalDetailModel.InsuranceLevel) ? null : additionalDetailModel.InsuranceLevel; ;
            contractSection.ContractPeriod.StartDate = additionalDetailModel.InceptionDate.Value;
            contractSection.ContractPeriod.EndDate = MappingHelper.GetEndDate(additionalDetailModel.InceptionDate.Value,
                additionalDetailModel.TimeDurationValue, additionalDetailModel.TimeDurationPeriodType);
            contractSection.ContractPeriod.TimeDuration.Value = additionalDetailModel.TimeDurationValue;
            contractSection.ContractPeriod.TimeDuration.PeriodType = MappingHelper.GetPeriodTypeFullName(additionalDetailModel.TimeDurationPeriodType);
        }

        private decimal RoundToTwoDecimalPlaces(decimal value)
        {
            if (value > 0 && value.ToString().Split(".").Length == maxDecimalPlaces)
            {
                if (value.ToString().Split(".")[1].Length < maxDecimalPlaces)
                {
                    var s = string.Format("{0:0.00}", value);
                    return Convert.ToDecimal(s);
                }
                else if (value.ToString().Split(".")[1].Length > maxDecimalPlaces)
                {
                    return decimal.Round(value, maxDecimalPlaces);
                }
                else
                {
                    return value;
                }
            }
            return value;
        }
    }
}