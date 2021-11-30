using AutoMapper;
using Brit.Risk.Entities;
using EntrySheet.Api.Function.Hydration;
using EntrySheet.Api.Function.Mappers;
using EntrySheet.Api.Function.Models;
using EntrySheet.Api.Function.Services;
using EntrySheet.Api.Function.Tests.Utils;
using Moq;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Hydrators
{
    public class PlacingHydratorTests
    {
        private readonly string _baseFolder;
        private readonly PlacingHydrator _placingHydrator;

        public PlacingHydratorTests()
        {
            _placingHydrator = new PlacingHydrator();
            _baseFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
        }

        [Fact]
        public void Placing_Data_Gets_Populated_Successfully_From_A_Single_Section_Multi_Line_EntrySheetDetailsModel()
        {
            const string policyDataFolderPath = @".\Data\Single_Section_Multi_Line_Policy_10044A20A000";
            const string entrySheetDetailsModelDateFileName = "10044A20A000_EntrySheetDetailsModel.json";

            var expectedEntrySheetDetailsModel = LoadEntrySheetDetailsModel(policyDataFolderPath, entrySheetDetailsModelDateFileName);

            var placings = _placingHydrator.Execute(expectedEntrySheetDetailsModel, "https://entry-sheet-api-func-uks-dev.azurewebsites.net/api/EntrySheet/Policy");

            Assert.True(placings.Count == 1);

            ExecutePlacingAndEntrySheetDetailsModelDataComparison(expectedEntrySheetDetailsModel, placings);
        }

        [Fact]
        public void Placing_Data_Gets_Populated_Successfully_From_A_Single_Section_Single_Line_EntrySheetDetailsModel()
        {
            const string policyDataFolderPath = @".\Data\Single_Section_Single_Line_Policy_BB585S20A000";
            const string entrySheetDetailsModelDateFileName = "BB585S20A000_EntrySheetDetailsModel.json";

            var expectedEntrySheetDetailsModel = LoadEntrySheetDetailsModel(policyDataFolderPath, entrySheetDetailsModelDateFileName);

            var placings = _placingHydrator.Execute(expectedEntrySheetDetailsModel, "https://entry-sheet-api-func-uks-dev.azurewebsites.net/api/EntrySheet/Policy");
            Assert.True(placings.Count == 1);

            ExecutePlacingAndEntrySheetDetailsModelDataComparison(expectedEntrySheetDetailsModel, placings);
        }

        [Fact]
        public void Placing_Data_Gets_Populated_Successfully_From_A_Multi_Section_Multi_Line_EntrySheetDetailsModel()
        {
            const string policyDataFolderPath = @".\Data\Multi_Section_Multi_Line_Policy_CF040E20B000";
            const string entrySheetDetailsModelDateFileName = "CF040E20B000_EntrySheetDetailsModel.json";

            var expectedEntrySheetDetailsModel = LoadEntrySheetDetailsModel(policyDataFolderPath, entrySheetDetailsModelDateFileName);

            var placings = _placingHydrator.Execute(expectedEntrySheetDetailsModel, "https://entry-sheet-api-func-uks-dev.azurewebsites.net/api/EntrySheet/Policy");
            Assert.True(placings.Count == 2);

            var json1 = JsonConvert.SerializeObject(placings[0], Formatting.Indented, new JsonSerializerSettings { ContractResolver = new CamelCasePropertyNamesContractResolver() });
            var json2 = JsonConvert.SerializeObject(placings[1], Formatting.Indented, new JsonSerializerSettings { ContractResolver = new CamelCasePropertyNamesContractResolver() });

            ExecutePlacingAndEntrySheetDetailsModelDataComparison(expectedEntrySheetDetailsModel, placings);
        }

        [Fact]
        public async Task Validate_Existing_Saved_EntrySheet()
        {
            const string policyDataFolderPath = @".\Data\Existing_Policy_Data\Multi_Section_Multi_Line";
            const string policiesDataFileName = "1118453_BritCache_GetEclipsePoliciesAsyncResult.json";
            const string policiesDataFileNameNonPrimary = "1118454_BritCache_GetEclipsePoliciesAsyncResult.json";
            const int britPolicyId = 1118453;
            const string savedEntrySheetPath = "CF040E20B000_EntrySheetDetailsModel.json";

            var placingDictionary = new Dictionary<int, string>
            {
                {1118453,"CF040E20B000"},
                {1118454,"CF040E20C000"}
            };

            var entrySheetService = EntrySheetMock.BuildEntrySheetService(_baseFolder, policyDataFolderPath, policiesDataFileName, britPolicyId,
                placingDictionary, new Dictionary<int, string> { { 1118454, policiesDataFileNameNonPrimary } }, savedEntrySheetPath);
            var savedEntrySheetDetails = await entrySheetService.GetEntrySheetDetailsAsync(britPolicyId);

            var placings = _placingHydrator.Execute(savedEntrySheetDetails, "https://entry-sheet-api-func-uks-dev.azurewebsites.net/api/EntrySheet/Policy");
            Assert.True(placings.Count == 2);
            ExecutePlacingAndEntrySheetDetailsModelDataComparison(savedEntrySheetDetails, placings);
        }

        private EntrySheetDetailsModel LoadEntrySheetDetailsModel(string policyDataFolderPath,
            string entrySheetDetailsModelDateFileName)
        {
            var entrySheetDetailsModelFilePath =  Path.Combine(_baseFolder, policyDataFolderPath, entrySheetDetailsModelDateFileName);
            var entrySheetDetailsModelJson = File.ReadAllText(entrySheetDetailsModelFilePath);
            var expectedEntrySheetDetailsModel =  JsonConvert.DeserializeObject<EntrySheetDetailsModel>(entrySheetDetailsModelJson);
            return expectedEntrySheetDetailsModel;
        }

        public void ExecutePlacingAndEntrySheetDetailsModelDataComparison(EntrySheetDetailsModel entrySheetDetailsModel, List<Placing> placings)
        {
            foreach (var contractSectionModel in entrySheetDetailsModel.ContractSection)
            {
                var placing = placings.First(x =>
                    x.ContractSections.First().SectionReference == contractSectionModel.PolicyRef);

                ComparePlacingFieldsPopulatedFromRelatedPolicyDetailsModel(entrySheetDetailsModel, placing, contractSectionModel.BritPolicyId);
                ComparePlacingFieldsPopulatedFromContractSectionModel(contractSectionModel, placing);
                ComparePlacingFieldsPopulatedFromPremiumRatingModel(
                    entrySheetDetailsModel.PremiumRatings.First(x => x.PolicyRef == contractSectionModel.PolicyRef),
                    placing);
                ComparePlacingFieldsPopulatedFromAdditionalDetails(
                    entrySheetDetailsModel.AdditionalDetails.First(x => x.PolicyRef == contractSectionModel.PolicyRef),
                    placing);

                foreach (var policyLineModel in entrySheetDetailsModel.PolicyLines.Where(x => x.PolicyRef == contractSectionModel.PolicyRef))
                {
                    var contractMarket = placing.ContractSections.First().ContractMarkets.First(x => x.BritAttributes.PasSystemPolicyLineId == policyLineModel.PolicyLineId);
                    CompareContractMarketFieldsPopulatedFromPolicyLineModel(policyLineModel, contractMarket);
                    if (policyLineModel.LineStatus.Equals("Quote", System.StringComparison.OrdinalIgnoreCase))
                    {
                        ComparePlacingQuoteFieldsFromPolicyLineModel(policyLineModel, placing);
                    }
                }
            }
        }

        private void ComparePlacingFieldsPopulatedFromRelatedPolicyDetailsModel(EntrySheetDetailsModel entrySheetDetailsModel, Placing placing,int britPolicyId)
        {
            Assert.Equal(placing.Contract.InsurerReference, entrySheetDetailsModel.RelatedPoliciesDetails.First(item=>item.BritPolicyId== britPolicyId).ProgramRef);
            Assert.Equal(placing.BritAttributes.ConductRating, entrySheetDetailsModel.RelatedPoliciesDetails.First(item => item.BritPolicyId == britPolicyId).ConductRating);
            Assert.Equal(placing.ContractSections.First().FSAClientClassifications.First().FSAClientClass, entrySheetDetailsModel.RelatedPoliciesDetails.First(item => item.BritPolicyId == britPolicyId).CustomerType);
            Assert.Equal(placing.Insured.Party.Name, entrySheetDetailsModel.RelatedPoliciesDetails.First(item => item.BritPolicyId == britPolicyId).Insured?.PartyName);
            Assert.Equal(placing.Reinsurer.Party.Name, entrySheetDetailsModel.RelatedPoliciesDetails.First(item => item.BritPolicyId == britPolicyId).Reinsured?.PartyName);
            Assert.Equal(placing.CoverHolder.Party.Name, entrySheetDetailsModel.RelatedPoliciesDetails.First(item => item.BritPolicyId == britPolicyId).Coverholder?.PartyName);
            Assert.Equal(placing.BritAttributes.PlacingType, entrySheetDetailsModel.RelatedPoliciesDetails.First(item => item.BritPolicyId == britPolicyId).PlacingType);
            Assert.Equal(placing.BritAttributes.UniqueMarketRef, entrySheetDetailsModel.RelatedPoliciesDetails.First(item => item.BritPolicyId == britPolicyId).UniqueMarketRef);
            Assert.Equal(placing.BritAttributes.CompanyLeader, entrySheetDetailsModel.RelatedPoliciesDetails.First(item => item.BritPolicyId == britPolicyId).CompanyLeader);
            Assert.Equal(placing.BritAttributes.LloydsLeader, entrySheetDetailsModel.RelatedPoliciesDetails.First(item => item.BritPolicyId == britPolicyId).LloydsLeader);
        }

        private void CompareContractMarketFieldsPopulatedFromPolicyLineModel(PolicyLineModel policyLineModel, ContractMarket contractMarket)
        {
            Assert.Equal(contractMarket.BritAttributes.EstimatedSigningDownPercentage.Rate.Value, policyLineModel.EstSign);
            Assert.Equal(contractMarket.BritAttributes.PasSystemPolicyLineId ,policyLineModel.PolicyLineId);
            Assert.Equal(contractMarket.Insurer.Party.Id,policyLineModel.Entity);
            Assert.Equal(contractMarket.LineTransactionFunction,policyLineModel.LineStatus);
            Assert.Equal(contractMarket.BritAttributes.InsurerWrittenLineIndicator,policyLineModel.WLInd);
            Assert.Equal(contractMarket.InsurerSharePercentage.Rate.Value,MappingHelper.GetInsurerSharePercentage(policyLineModel.WLInd, policyLineModel.WrittenLine));
            Assert.Equal(contractMarket.InsurerShareLimitAmount.Amt.Value ,MappingHelper.GetInsurerShareLimitAmount(policyLineModel.WLInd, policyLineModel.WrittenLine));
            Assert.Equal(contractMarket.BritAttributes.ReInsuranceCode, policyLineModel.RICode);
            Assert.Equal(contractMarket.BritAttributes.Exposure.Amt.Value, policyLineModel.Exposure);
            Assert.Equal(contractMarket.InsurerShareNetPremiumAmount.Amt.Value,policyLineModel.GNWP);
            Assert.Equal(contractMarket.BritAttributes.WholePartOrder, MappingHelper.GetWholePartOrderFullName(policyLineModel.WO));
            Assert.Equal(contractMarket.BritAttributes.OrderPercentage.Rate.Value, policyLineModel.Order);
        }

        private void ComparePlacingFieldsPopulatedFromContractSectionModel(ContractSectionModel contractSectionModel, Placing placing)
        {
            Assert.Equal(placing.ContractSections.First().BritAttributes.PasSystemPolicyId , contractSectionModel.PolicySectionId);
            Assert.Equal(placing.ContractSections.First().BritAttributes.IsMainSection , contractSectionModel.IsMainSection);
            Assert.Equal(placing.ContractSections.First().SectionReference,contractSectionModel.PolicyRef);
            Assert.Equal(placing.Insurer.Contact.BritAttributes.Initials, contractSectionModel.UWInitials);
            Assert.Equal(placing.Broker.Party.Name, contractSectionModel.BrokerName);
            Assert.Equal(placing.Broker.Contact.PersonName, contractSectionModel.ContactName);
            Assert.Equal(placing.BritAttributes.PasSystemBrokerId, contractSectionModel.LloydsBrokerId);
            Assert.Equal(placing.Broker.Party.Id ,contractSectionModel.BrokerCode);
            Assert.Equal(placing.BritAttributes.BrokerPseud,contractSectionModel.BrokerPseud);
            Assert.Equal(placing.Broker.Contact.BritAttributes.PasSystemContactId,contractSectionModel.BrokerContactId);
            Assert.Equal(placing.ContractSections.First().BritAttributes.ClassType,contractSectionModel.ClassType);
            Assert.Equal(placing.ContractSections.First().ContractSectionClasses.First().JvClassOfBusiness,contractSectionModel.MajorClass);
            Assert.Equal(placing.ContractSections.First().BritAttributes.SubClass,contractSectionModel.SubClass);
            Assert.Equal(MappingHelper.GetTopCoverage(placing).CoverageAmount.Amt.Ccy,contractSectionModel.LimitCcy);
            Assert.Equal(MappingHelper.GetTopCoverage(placing).CoverageAmount.Amt.Value, contractSectionModel.Limit);
            Assert.Equal(MappingHelper.GetTopCoverage(placing).CoverageBasis, contractSectionModel.LimitBasis);

            if (!string.IsNullOrEmpty(contractSectionModel.BiSubLimitBasis))
            {
                Assert.Equal(MappingHelper.GetBiSubLimitCoverage(placing).CoverageBasis, contractSectionModel.BiSubLimitBasis);
                Assert.Equal(MappingHelper.GetBiSubLimitCoverage(placing).CoverageAmount.Amt.Ccy, contractSectionModel.BiSubLimitCcy);
                Assert.Equal(MappingHelper.GetBiSubLimitCoverage(placing).CoverageAmount.Amt.Value , contractSectionModel.BiSubLimit);
            }

            Assert.Equal(placing.ContractSections.First().ContractDeductibles
                .First(f => f.DeductibleType == "loss_excess_policy").DeductibleAmount.Amt.Value,contractSectionModel.Excess);
            Assert.Equal(placing.ContractSections.First().ContractDeductibles
                .First(f => f.DeductibleType == "retention").DeductibleAmount.Amt.Value,  contractSectionModel.Deductible);
            Assert.Equal(placing.ContractSections.First().BritAttributes.InnerAgg.Amt.Value, contractSectionModel.InnerAGG);
            Assert.Equal(placing.ContractSections.First().BritAttributes.AdrLevel, contractSectionModel.ADRLevel);
            Assert.Equal(placing.ContractSections.First().ContractPeriod.StartDate , contractSectionModel.ContractPeriodStartDate);
            Assert.Equal(placing.BritAttributes.ProducingTeam, contractSectionModel.ProducingTeam);
        }

        private void ComparePlacingFieldsPopulatedFromPremiumRatingModel(PremiumRatingModel premiumRatingModel, Placing placing)
        {
            Assert.Equal(placing.ContractSections.First().Premiums.First().BritAttributes.PasSystemPremiumId, premiumRatingModel.PolicyPremiumRatingId);
            Assert.Equal(placing.ContractSections.First().Premiums.First().PremiumAmount.First().Ccy, premiumRatingModel.PremiumCcy);
            Assert.Equal(placing.ContractSections.First().Premiums.First().PremiumAmount.First().Value, premiumRatingModel.WrittenPremium);
            Assert.Equal(placing.ContractSections.First().Premiums.First().BritAttributes.TechnicalPrice.Value, premiumRatingModel.TechPrice);
            Assert.Equal(placing.ContractSections.First().Premiums.First().BritAttributes.ModelPrice.Value, premiumRatingModel.ModelPrice);
            Assert.Equal(placing.ContractSections.First().Premiums.First().BritAttributes.ProjectedLossRatio.Rate.Value , premiumRatingModel.PLR);
            Assert.Equal(placing.ContractSections.First().Premiums.First().BritAttributes.ChangeInLDA.Rate.Value, premiumRatingModel.ChangeInLDA);
            Assert.Equal(placing.ContractSections.First().Premiums.First().BritAttributes.ChangeInCoverage.Rate.Value,
                premiumRatingModel.ChangeInCoverage);
            Assert.Equal(placing.ContractSections.First().Premiums.First().BritAttributes.ChangeInOther.Rate.Value,
                premiumRatingModel.ChangeInOther);
            Assert.Equal(placing.ContractSections.First().Premiums.First().BritAttributes.RiskAdjustedRateChange.Rate.Value,
                premiumRatingModel.RiskAdjustedRateChange);
            Assert.Equal(placing.ContractSections.First().BritAttributes.ReportingCcy, premiumRatingModel.ReportingCcy);
        }

        private void ComparePlacingFieldsPopulatedFromAdditionalDetails(AdditionalDetailModel additionalDetailModel, Placing placing)
        {
            Assert.Equal(placing.ContractSections.First().BritAttributes.IsContractCertain,additionalDetailModel.ContractCertain);
            Assert.Equal(placing.ContractSections.First().BritAttributes.ContractCertainExceptionCode, additionalDetailModel.ContractCertainCode);
            Assert.Equal(placing.ContractSections.First().BritAttributes.ContractCertainDate, additionalDetailModel.ContractCertainDate);
            Assert.Equal(placing.ContractSections.First().BritAttributes.RiskRating, additionalDetailModel.RiskRating);
            Assert.Equal(placing.BritAttributes.AggRiskData , additionalDetailModel.AggRiskData);
            Assert.Equal(placing.ContractSections.First().BritAttributes.InsuranceLevel, additionalDetailModel.InsuranceLevel);
            Assert.Equal(placing.ContractSections.First().ContractPeriod.StartDate, additionalDetailModel.InceptionDate.Value);
            Assert.Equal(placing.ContractSections.First().ContractPeriod.TimeDuration.Value, additionalDetailModel.TimeDurationValue);
            Assert.Equal(placing.ContractSections.First().ContractPeriod.TimeDuration.PeriodType, MappingHelper.GetPeriodTypeFullName(additionalDetailModel.TimeDurationPeriodType));
        }

        private void ComparePlacingQuoteFieldsFromPolicyLineModel(PolicyLineModel policyLineModel,Placing placing)
        {
            Assert.Equal("Quote", policyLineModel.LineStatus.ToString());
            Assert.Equal(placing.QuoteRequestedByDate, policyLineModel.QuoteDate);
            Assert.Equal(placing.QuoteValidUntilDate, policyLineModel.QuoteEndDate);
            Assert.Equal(placing.QuoteValidUntilDate, policyLineModel.QuoteDate.Value.AddDays(policyLineModel.QuoteDays));
        }
    }
}
