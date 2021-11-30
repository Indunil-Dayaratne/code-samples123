using System.Linq;
using EntrySheet.Api.Function.Models;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Utils
{
    public class EntrySheetDetailsModelComparer
    {
        public void CompareModels(EntrySheetDetailsModel actualEntrySheetDetailsModel,
            EntrySheetDetailsModel expectedEntrySheetDetailsModel)
        {
            Assert.True(actualEntrySheetDetailsModel.Equals(expectedEntrySheetDetailsModel));
            Assert.True(actualEntrySheetDetailsModel.ContractSection.Count ==
                        expectedEntrySheetDetailsModel.ContractSection.Count);
            Assert.True(
                actualEntrySheetDetailsModel.PremiumRatings.Count == expectedEntrySheetDetailsModel.PremiumRatings.Count);
            Assert.True(actualEntrySheetDetailsModel.PolicyLines.Count == expectedEntrySheetDetailsModel.PolicyLines.Count);
            Assert.True(actualEntrySheetDetailsModel.AdditionalDetails.Count ==
                        expectedEntrySheetDetailsModel.AdditionalDetails.Count);

            CompareContractSectionModels(actualEntrySheetDetailsModel, expectedEntrySheetDetailsModel);

            ComparePremiumRatingModels(actualEntrySheetDetailsModel, expectedEntrySheetDetailsModel);

            ComparePolicyLineModels(actualEntrySheetDetailsModel, expectedEntrySheetDetailsModel);

            CompareAdditionalDetailModels(actualEntrySheetDetailsModel, expectedEntrySheetDetailsModel);
        }
        private void CompareAdditionalDetailModels(EntrySheetDetailsModel actualEntrySheetDetailsModel,
            EntrySheetDetailsModel expectedEntrySheetDetailsModel)
        {
            foreach (var additionalDetailModel in actualEntrySheetDetailsModel.AdditionalDetails)
            {
                var matchingAdditionalDetailModel = expectedEntrySheetDetailsModel.AdditionalDetails.FirstOrDefault(x =>
                    x.PolicyAdditionalDetailId == additionalDetailModel.PolicyAdditionalDetailId &&
                    x.PolicyRef == additionalDetailModel.PolicyRef);

                Assert.NotNull(matchingAdditionalDetailModel);
                Assert.True(additionalDetailModel.Equals(matchingAdditionalDetailModel));
            }
        }

        private void ComparePolicyLineModels(EntrySheetDetailsModel actualEntrySheetDetailsModel,
            EntrySheetDetailsModel expectedEntrySheetDetailsModel)
        {
            foreach (var policyLineModel in actualEntrySheetDetailsModel.PolicyLines)
            {
                var matchingPolicyLineModel = expectedEntrySheetDetailsModel.PolicyLines.FirstOrDefault(x =>
                    x.PolicyLineId == policyLineModel.PolicyLineId &&
                    x.PolicyRef == policyLineModel.PolicyRef);

                Assert.NotNull(matchingPolicyLineModel);
                Assert.True(policyLineModel.Equals(matchingPolicyLineModel));
            }
        }

        private void ComparePremiumRatingModels(EntrySheetDetailsModel actualEntrySheetDetailsModel, EntrySheetDetailsModel expectedEntrySheetDetailsModel)
        {
            foreach (var premiumRatingModel in actualEntrySheetDetailsModel.PremiumRatings)
            {
                var matchingPremiumRatingModel = expectedEntrySheetDetailsModel.PremiumRatings.FirstOrDefault(x =>
                    x.PolicyPremiumRatingId == premiumRatingModel.PolicyPremiumRatingId &&
                    x.PolicyRef == premiumRatingModel.PolicyRef);

                Assert.NotNull(matchingPremiumRatingModel);
                Assert.True(premiumRatingModel.Equals(matchingPremiumRatingModel));
            }
        }

        private void CompareContractSectionModels(EntrySheetDetailsModel actualEntrySheetDetailsModel,
            EntrySheetDetailsModel expectedEntrySheetDetailsModel)
        {
            foreach (var contractSectionModel in actualEntrySheetDetailsModel.ContractSection)
            {
                var matchingSectionModel = expectedEntrySheetDetailsModel.ContractSection.FirstOrDefault(x =>
                    x.PolicySectionId == contractSectionModel.PolicySectionId &&
                    x.PolicyRef == contractSectionModel.PolicyRef);

                Assert.NotNull(matchingSectionModel);
                Assert.True(contractSectionModel.Equals(matchingSectionModel));
            }
        }
    }
}