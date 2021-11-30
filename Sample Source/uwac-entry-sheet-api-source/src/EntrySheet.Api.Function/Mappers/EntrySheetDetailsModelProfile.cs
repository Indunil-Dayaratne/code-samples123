using AutoMapper;
using Brit.Risk.Entities;
using EntrySheet.Api.Function.Models;
using System;
using System.Linq;

namespace EntrySheet.Api.Function.Mappers
{
    public class EntrySheetDetailsModelProfile : Profile
    {
        public EntrySheetDetailsModelProfile()
        {
            CreateMap<Placing, PolicyInformationModel>()
              .ForMember(dest => dest.ProgramRef, opts => opts.MapFrom(source => source.Contract.InsurerReference))
              .ForMember(dest => dest.ConductRating, opts => opts.MapFrom(source => source.BritAttributes.ConductRating))
              .ForMember(dest => dest.Insured, opts => opts.MapFrom(source => source.Insured))
              .ForMember(dest => dest.Reinsured, opts => opts.MapFrom(source => source.Reinsurer))
              .ForMember(dest => dest.Coverholder, opts => opts.MapFrom(source => source.CoverHolder))
              .ForMember(dest => dest.LloydsLeader,opts => opts.MapFrom(source => source.BritAttributes.LloydsLeader))
              .ForMember(dest => dest.CompanyLeader, opts => opts.MapFrom(source => source.BritAttributes.CompanyLeader))
              .ForMember(dest => dest.UniqueMarketRef, opts => opts.MapFrom(source => source.BritAttributes.UniqueMarketRef))
              .ForMember(dest => dest.PlacingType,opts=> opts.MapFrom(source=>source.BritAttributes.PlacingType))
              .ForMember(dest => dest.InstalmentPeriod, opts => opts.MapFrom(source => source.BritAttributes.InstalmentPeriod))
              .ForMember(dest => dest.CustomerType, opts => opts.MapFrom(source => source.ContractSections.First().FSAClientClassifications.First().FSAClientClass));


            CreateMap<AnyParty, OrganisationModel>()
                .ForMember(dest => dest.PartyName, opts => opts.MapFrom(source => source.Party.Name));

            CreateMap<Placing, ContractSectionModel>()
                 .ForMember(dest => dest.IsRiskEntrySheetLocked,
                   opts => opts.MapFrom(source => MappingHelper.ComputeIfRiskEntryIsLocked(source)))
                .ForMember(dest => dest.PolicySectionId, opts => opts.MapFrom(source => source.ContractSections.First().BritAttributes.PasSystemPolicyId))
                .ForMember(dest => dest.IsMainSection, opts => opts.MapFrom(source => source.ContractSections.First().BritAttributes.IsMainSection))
                .ForMember(dest => dest.PolicyRef, opts => opts.MapFrom(source => source.ContractSections.First().SectionReference))
                .ForMember(dest => dest.UWInitials, opts => opts.MapFrom(source => source.Insurer.Contact.BritAttributes.Initials))
                .ForMember(dest => dest.BrokerName, opts => opts.MapFrom(source => source.Broker.Party.Name))
                .ForMember(dest => dest.ContactName, opts => opts.MapFrom(source => source.Broker.Contact.PersonName))
                .ForMember(dest => dest.LloydsBrokerId, opts => opts.MapFrom(source => source.BritAttributes.PasSystemBrokerId))
                .ForMember(dest => dest.BrokerCode, opts => opts.MapFrom(source => source.Broker.Party.Id))
                .ForMember(dest => dest.BrokerPseud, opts => opts.MapFrom(source => source.BritAttributes.BrokerPseud))
                .ForMember(dest => dest.BrokerContactId, opts => opts.MapFrom(source => source.Broker.Contact.BritAttributes.PasSystemContactId))
                .ForMember(dest => dest.ClassType, opts => opts.MapFrom(source => source.ContractSections.First().BritAttributes.ClassType))
                .ForMember(dest => dest.MajorClass, opts => opts.MapFrom(source => source.ContractSections.First().ContractSectionClasses.First().JvClassOfBusiness))
                .ForMember(dest => dest.MinorClass, opts => opts.MapFrom(source => source.ContractSections.First().BritAttributes.MinorClass))
                .ForMember(dest => dest.SubClass, opts => opts.MapFrom(source => source.ContractSections.First().BritAttributes.SubClass))
                .ForMember(dest => dest.LimitCcy, opts => opts.MapFrom(source => MappingHelper.GetTopCoverage(source).CoverageAmount.Amt.Ccy))
                .ForMember(dest => dest.Limit, opts => opts.MapFrom(source => MappingHelper.GetTopCoverage(source).CoverageAmount.Amt.Value))
                .ForMember(dest => dest.LimitBasis, opts => opts.MapFrom(source => MappingHelper.GetTopCoverage(source).CoverageBasis))
                .ForMember(dest => dest.BiSubLimitCcy, opts => opts.MapFrom(source => MappingHelper.GetBiSubLimitCcy(source)))
                .ForMember(dest => dest.BiSubLimit, opts => opts.MapFrom(source => MappingHelper.GetBiSubLimit(source)))
                .ForMember(dest => dest.BiSubLimitBasis, opts => opts.MapFrom(source => MappingHelper.GetBiSubLimitBasis(source)))
                .ForMember(dest => dest.ContractCoverageId, opts => opts.MapFrom(source => MappingHelper.GetTopCoverage(source).BritAttributes.PasSystemContractCoverageId))
                .ForMember(dest => dest.Excess, opts => opts.MapFrom(source => source.ContractSections.First()
                .ContractDeductibles.First(f => f.DeductibleType == "loss_excess_policy").DeductibleAmount.Amt.Value))
                .ForMember(dest => dest.Deductible, opts => opts.MapFrom(source => source.ContractSections.First()
                .ContractDeductibles.First(f => f.DeductibleType == "retention").DeductibleAmount.Amt.Value))
                .ForMember(dest => dest.InnerAGG, opts => opts.MapFrom(source => source.ContractSections.First().BritAttributes.InnerAgg.Amt.Value))
                .ForMember(dest => dest.ADRLevel, opts => opts.MapFrom(source => source.ContractSections.First().BritAttributes.AdrLevel))
                .ForMember(dest => dest.YOA, opts => opts.MapFrom(source => source.ContractSections.First().ContractPeriod.StartDate.Year))
                .ForMember(dest => dest.ContractPeriodStartDate, opts => opts.MapFrom(source => source.ContractSections.First().ContractPeriod.StartDate))
                .ForMember(dest => dest.Syndicate, opts => opts.MapFrom(source => source.ContractSections.First().ContractMarkets.First().Insurer.Party.Id))
                .ForMember(dest => dest.ProducingTeam, opts => opts.MapFrom(source => source.BritAttributes.ProducingTeam))
                .ForMember(dest => dest.ProgramRef, opts => opts.MapFrom(source => source.Contract.InsurerReference))
                .ForMember(dest => dest.ConductRating, opts => opts.MapFrom(source => source.BritAttributes.ConductRating))
                .ForMember(dest => dest.Insured, opts => opts.MapFrom(source => source.Insured))
                .ForMember(dest => dest.Reinsured, opts => opts.MapFrom(source => source.Reinsurer))
                .ForMember(dest => dest.Coverholder, opts => opts.MapFrom(source => source.CoverHolder))
                .ForMember(dest => dest.TerritoryId, opts => opts.MapFrom(source => source.ContractSections.First().RiskLocations.First().Location.Supraentity))
                .ForMember(dest => dest.TerritoryIdAssured, opts => opts.MapFrom(source => source.ContractSections.First().RiskLocations.First().Location.Country))
                .ForMember(dest => dest.OverridingCommission , opts => opts.MapFrom(source => source.ContractSections.First().OverridingCommission.OverridingCommissionPercentage.Rate.Value))
                .ForMember(dest => dest.OtherDeductions, opts => opts.MapFrom(source => source.ContractSections.First().OtherDeductions.OtherDeductionsPercentage.Rate.Value))
                .ForMember(dest=> dest.CoverOperatingBasis, opts => opts.MapFrom(source => source.ContractSections.First().CoverOperatingBasis))
                .ForMember(dest => dest.ProfitCommission, opts => opts.MapFrom(source => source.ContractSections.First().ProfitCommission.ProfitCommissionPercentage.Rate.Value))
                
                .ForMember(dest => dest.CustomerType, opts => opts.MapFrom(source => source.ContractSections.First().FSAClientClassifications.First().FSAClientClass));

            CreateMap<Placing, PremiumRatingModel>()
                 .ForMember(dest => dest.IsRiskEntrySheetLocked,
                  opts => opts.MapFrom(source => MappingHelper.ComputeIfRiskEntryIsLocked(source)))
                .ForMember(dest => dest.PolicyPremiumRatingId, opts => opts.MapFrom(source => source.ContractSections.First().Premiums.First().BritAttributes.PasSystemPremiumId))
                .ForMember(dest => dest.PolicyRef, opts => opts.MapFrom(source => source.ContractSections.First().SectionReference))
                .ForMember(dest => dest.PremiumCcy, opts => opts.MapFrom(source => source.ContractSections.First().Premiums.First().PremiumAmount.First().Ccy))
                .ForMember(dest => dest.ReportingCcy, opts => opts.MapFrom(source => source.ContractSections.First().BritAttributes.ReportingCcy))
                .ForMember(dest => dest.WrittenPremium, opts => opts.MapFrom(source => source.ContractSections.First().Premiums.First().PremiumAmount.First().Value))
                .ForMember(dest => dest.TechPrice, opts => opts.MapFrom(source => source.ContractSections.First().Premiums.First().BritAttributes.TechnicalPrice.Value))
                .ForMember(dest => dest.ModelPrice, opts => opts.MapFrom(source => source.ContractSections.First().Premiums.First().BritAttributes.ModelPrice.Value))
                .ForMember(dest => dest.PLR, opts => opts.MapFrom(source => source.ContractSections.First().Premiums.First().BritAttributes.ProjectedLossRatio.Rate.Value))
                .ForMember(dest => dest.ChangeInLDA, opts => opts.MapFrom(source => source.ContractSections.First().Premiums.First().BritAttributes.ChangeInLDA.Rate.Value))
                .ForMember(dest => dest.ChangeInCoverage, opts => opts.MapFrom(source => source.ContractSections.First().Premiums.First().BritAttributes.ChangeInCoverage.Rate.Value))
                .ForMember(dest => dest.ChangeInOther, opts => opts.MapFrom(source => source.ContractSections.First().Premiums.First().BritAttributes.ChangeInOther.Rate.Value))
                .ForMember(dest => dest.RiskAdjustedRateChange, opts => opts.MapFrom(source => source.ContractSections.First().Premiums.First().BritAttributes.RiskAdjustedRateChange.Rate.Value))
                .ForMember(dest => dest.Brokerage, opts => opts.MapFrom(source => MappingHelper.GetBrokerage(source.ContractSections.First())))
                .ForMember(dest => dest.BrokerageRateType, opts => opts.MapFrom(source => MappingHelper.GetBrokerageRateType(source.ContractSections.First())))
                .ForMember(dest => dest.PremiumType, opts => opts.MapFrom(source => source.ContractSections.First().Premiums.First().PremiumType))
                .ForMember(dest => dest.PaymentDate, opts => opts.MapFrom(source => source.ContractSections.First().Premiums.First().PaymentDate))
                .ForMember(dest => dest.NumberOfInstallment, opts => opts.MapFrom(source => source.ContractSections.First().Premiums.First().InstalmentsTotalNbr.Count))
                .ForMember(dest => dest.InitialToT, opts => opts.MapFrom(source => source.ContractSections.First().Premiums.First().TermsOfTradePeriod.TimeDuration.Value))
                .ForMember(dest => dest.BrokerageCcy, opts => opts.MapFrom(source => MappingHelper.GetBrokerageCcy(source.ContractSections.First())));
                              
                CreateMap<ContractMarket, PolicyLineModel>()
                //LBS
                //status reason
                .ForMember(dest => dest.PolicyLineId,
                    opts => opts.MapFrom(source => source.BritAttributes.PasSystemPolicyLineId))
                .ForMember(dest => dest.Entity,
                    opts => opts.MapFrom(source => source.Insurer.Party.Id))
                .ForMember(dest => dest.LineStatus,
                    opts => opts.MapFrom(source => source.LineTransactionFunction))
                .ForMember(dest => dest.WLInd,
                    opts => opts.MapFrom(source => source.BritAttributes.InsurerWrittenLineIndicator))
                .ForMember(dest => dest.WrittenLine,
                    opts => opts.MapFrom(source => MappingHelper.GetWrittenLineForPolicyLine(source)))
                 .ForMember(dest => dest.EstSign,
                    opts => opts.MapFrom(source =>
                        source.BritAttributes.EstimatedSigningDownPercentage.Rate.Value)) 
                .ForMember(dest => dest.RICode, opts => opts.MapFrom(source => source.BritAttributes.ReInsuranceCode))
                .ForMember(dest => dest.Exposure, opts => opts.MapFrom(source => Math.Round(source.BritAttributes.Exposure.Amt.Value)))
                .ForMember(dest => dest.WO,
                    opts => opts.MapFrom(source => MappingHelper.GetLinePercentageBasis(source.BritAttributes.WholePartOrder)))
                .ForMember(dest => dest.Order,
                    opts => opts.MapFrom(source => source.BritAttributes.OrderPercentage.Rate.Value))
                 .ForMember(dest => dest.WrittenDateTime, opts => opts.MapFrom(source => source.WrittenDateTime))
                .ForMember(dest => dest.RiskAllocationCode , opts => opts.MapFrom(source =>source.PremiumRegulatoryAllocationSchemes.First().Allocations.First().AllocationCode))
                .ForMember(dest => dest.GNWP, opts => opts.MapFrom(source => Math.Round(source.InsurerShareNetPremiumAmount.Amt.Value)));

            CreateMap<ContractSection, PolicyLineModel>()
                .ForMember(dest => dest.PolicyRef,
                    opts => opts.MapFrom(source => source.SectionReference))
                .ForMember(dest => dest.Section,
                    opts => opts.MapFrom(source =>
                        source.SectionReference
                            .Substring(source.SectionReference.Length - 4)));

            CreateMap<Placing, PolicyLineModel>()
                .ForMember(dest => dest.QuoteId,
                opts => opts.MapFrom(source => source.BritAttributes.PasSystemQuoteId))
                .ForMember(dest => dest.QuoteDate,
                opts => opts.MapFrom(source => source.QuoteRequestedByDate))
                .ForMember(dest => dest.QuoteEndDate,
                opts => opts.MapFrom(source => source.QuoteValidUntilDate))
                 .ForMember(dest => dest.IsRiskEntrySheetLocked,
                  opts => opts.MapFrom(source => MappingHelper.ComputeIfRiskEntryIsLocked(source)))
                .ForMember(dest => dest.QuoteDays,
                opts => opts.MapFrom(source => MappingHelper.GetDateDiffInDays(source.QuoteRequestedByDate, source.QuoteValidUntilDate)));
                
            CreateMap<Placing, AdditionalDetailModel>()
                 .ForMember(dest => dest.IsRiskEntrySheetLocked,
                  opts => opts.MapFrom(source => MappingHelper.ComputeIfRiskEntryIsLocked(source)))
                .ForMember(dest => dest.PolicyRef,
                    opts => opts.MapFrom(source => source.ContractSections.First().SectionReference))
                .ForMember(dest => dest.PolicyAdditionalDetailId,
                    opts => opts.MapFrom(source => source.ContractSections.First().BritAttributes.PasSystemPolicyId))
                .ForMember(dest => dest.InceptionDate,
                    opts => opts.MapFrom(source =>
                        source.ContractSections.First().ContractPeriod.StartDate))
                .ForMember(dest => dest.ExpiryDate,
                    opts => opts.MapFrom(source => MappingHelper.GetEndDate(source)))
                .ForMember(dest => dest.Period,
                    opts => opts.MapFrom(source => source.ContractSections.First().ContractPeriod.TimeDuration.Value + source.ContractSections.First().ContractPeriod.TimeDuration.PeriodType))
                .ForMember(dest => dest.TimeDurationValue,
                    opts => opts.MapFrom(source => source.ContractSections.First().ContractPeriod.TimeDuration.Value))
                .ForMember(dest => dest.TimeDurationPeriodType,
                    opts => opts.MapFrom(source => MappingHelper.GetPeriodType(source.ContractSections.First().ContractPeriod.TimeDuration.PeriodType)))
                .ForMember(dest => dest.ContractCertain,
                    opts => opts.MapFrom(source => source.ContractSections.First().BritAttributes.IsContractCertain))
                .ForMember(dest => dest.ContractCertainCode,
                    opts => opts.MapFrom(source => source.ContractSections.First().BritAttributes.ContractCertainExceptionCode))
                .ForMember(dest => dest.ContractCertainDate,
                    opts => opts.MapFrom(source => source.ContractSections.First().BritAttributes.ContractCertainDate))
                .ForMember(dest => dest.RiskRating,
                    opts => opts.MapFrom(source => source.ContractSections.First().BritAttributes.RiskRating))
                .ForMember(dest => dest.AggRiskData,
                    opts => opts.MapFrom(source => source.BritAttributes.AggRiskData.TrimEnd()))
                .ForMember(dest => dest.InsuranceLevel,
                    opts => opts.MapFrom(source => source.ContractSections.First().BritAttributes.InsuranceLevel));

        }
    }
}