using AutoMapper;
using Brit.Risk.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using EntrySheet.Api.Function.Mappers;
using EntrySheet.Api.Function.Models;
using EntrySheet.Api.Function.Services;

namespace EntrySheet.Api.Function.Hydration
{
    public class EntrySheetDetailsHydrator: IEntrySheetDetailsHydrator
    {
        private readonly IMapper _mapper;
        private readonly ISyndicateDataRetriever _syndicateDataRetriever;

        public EntrySheetDetailsHydrator(IMapper mapper, ISyndicateDataRetriever syndicateDataRetriever)
        {
            _mapper = mapper;
            _syndicateDataRetriever = syndicateDataRetriever;
        }

        public EntrySheetDetailsModel Execute(EntrySheetDetailsModel entrySheetDetailsModel, Placing placingForSelectedPolicy, IEnumerable<Placing> placingList, List<PolicyItem> policyItems)
        {
            var programRef = policyItems?.FirstOrDefault(item => item.BritPolicyId.Equals(entrySheetDetailsModel.BritPolicyId))?.ProgramRef;

            if (placingList == null)
            {
                return entrySheetDetailsModel;
            }

            foreach (var placing in placingList.OrderBy(x=>x.ContractSections.First().SectionReference))
            {
                var contractSection = placing.ContractSections.First();

                var policyItem = policyItems?.FirstOrDefault(item => item.PolicyReference.Equals(contractSection.SectionReference));
                PopulatePolicyInformation(entrySheetDetailsModel, placing, programRef, policyItem?.BritPolicyId ?? 0);

                PopulateSections(entrySheetDetailsModel, placing, contractSection, policyItem);

                PopulatePremiumRatings(entrySheetDetailsModel, placing, contractSection);

                PopulatePolicyLines(entrySheetDetailsModel, contractSection, placing);

                PopulateAdditionalDetails(entrySheetDetailsModel, placing, contractSection, policyItem);
            }

            return entrySheetDetailsModel;
        }

        private void PopulateAdditionalDetails(EntrySheetDetailsModel entrySheetDetailsModel, Placing placing, ContractSection contractSection,PolicyItem policyItem)
        {
            var additionalDetailModel = FindOrCreatePolicyRefModelInCollection(entrySheetDetailsModel.AdditionalDetails, contractSection.SectionReference);
            _mapper.Map(placing, additionalDetailModel);

            if (string.IsNullOrEmpty(additionalDetailModel.RiskRating))
            {
                additionalDetailModel.RiskRating = null;
            }

            if (string.IsNullOrEmpty(additionalDetailModel.InsuranceLevel))
            {
                additionalDetailModel.InsuranceLevel = null;
            }
            if (policyItem != null)
            {
                if (string.IsNullOrEmpty(additionalDetailModel.PlacingType))
                {
                    additionalDetailModel.PlacingType = policyItem.PlacingType;
                }
                if (string.IsNullOrEmpty(additionalDetailModel.GroupClass))
                {
                    additionalDetailModel.GroupClass = policyItem.GroupClass;
                }
            }
        }

        private void PopulatePremiumRatings(EntrySheetDetailsModel entrySheetDetailsModel, Placing placing, ContractSection contractSection)
        {
            var premiumRatingModel = FindOrCreatePolicyRefModelInCollection(entrySheetDetailsModel.PremiumRatings, contractSection.SectionReference);
            _mapper.Map(placing, premiumRatingModel);
        }

        private void PopulateSections(EntrySheetDetailsModel entrySheetDetailsModel, Placing placing, ContractSection contractSection,PolicyItem policyItem)
        {
            var contractSectionModel = FindOrCreatePolicyRefModelInCollection(entrySheetDetailsModel.ContractSection, contractSection.SectionReference);
            _mapper.Map(placing, contractSectionModel);
            if(policyItem !=null && !string.IsNullOrEmpty(policyItem.GroupClass))
            {
                contractSectionModel.GroupClass = policyItem.GroupClass;
            }

            if(policyItem != null)
            {
                contractSectionModel.BritPolicyId = policyItem.BritPolicyId;
            }

            if (policyItem != null)
            {
                var policyInfo = entrySheetDetailsModel.RelatedPoliciesDetails.First(item => item.BritPolicyId == policyItem.BritPolicyId);
                contractSectionModel.ProgramRef = policyInfo.ProgramRef;
                contractSectionModel.ConductRating = policyInfo.ConductRating;
                contractSectionModel.Insured = policyInfo.Insured;
                contractSectionModel.Reinsured = policyInfo.Reinsured;
                contractSectionModel.Coverholder = policyInfo.Coverholder;
                contractSectionModel.CustomerType = policyInfo.CustomerType;
            }
        }

        private void PopulatePolicyInformation(EntrySheetDetailsModel entrySheetDetailsModel, Placing placing, string programRef,int britPolicyId)
        {
            PolicyInformationModel policyInfo = null;
            if(entrySheetDetailsModel.RelatedPoliciesDetails?.Count > 0)
            {
                policyInfo = entrySheetDetailsModel.RelatedPoliciesDetails.FirstOrDefault(item => item.BritPolicyId == britPolicyId);
            }
            if (policyInfo == null)
            {
                policyInfo = new PolicyInformationModel();
                entrySheetDetailsModel.RelatedPoliciesDetails.Add(policyInfo);
            }
            _mapper.Map(placing, policyInfo);
            policyInfo.BritPolicyId = britPolicyId;
            PopulateEmptyOrganisationModelProperties(policyInfo);
            if (policyInfo != null && string.IsNullOrEmpty(policyInfo?.ProgramRef))
            {
                policyInfo.ProgramRef = programRef;
            }
        }

        private void PopulatePolicyLines(EntrySheetDetailsModel entrySheetDetailsModel, ContractSection contractSection,Placing placing)
        {
            var isRiskEntryLocked = contractSection.ContractMarkets.Any(item => item.LineTransactionFunction.Equals("Signed", StringComparison.OrdinalIgnoreCase));
            foreach (var contractMarket in contractSection.ContractMarkets)
            {
                if (_syndicateDataRetriever.GetIncludedSyndicates().Contains(contractMarket.Insurer.Party.Id))
                {
                    var policyLineModel = entrySheetDetailsModel.PolicyLines.FirstOrDefault(x =>
                        x.PolicyRef.Equals(contractSection.SectionReference, StringComparison.InvariantCultureIgnoreCase) &&
                        x.Entity.Equals(contractMarket.Insurer.Party.Id, StringComparison.InvariantCultureIgnoreCase));

                    if (policyLineModel == null)
                    {
                        policyLineModel = new PolicyLineModel();
                        entrySheetDetailsModel.PolicyLines.Add(policyLineModel);
                    }
                    _mapper.Map(contractSection, policyLineModel);
                    _mapper.Map(contractMarket, policyLineModel);
                    if(policyLineModel.LineStatus.Equals("Quote",StringComparison.OrdinalIgnoreCase))
                    {
                        _mapper.Map(placing, policyLineModel);
                    }
                    policyLineModel.IsRiskEntrySheetLocked = isRiskEntryLocked;
                }
            }
            

            RemoveDeletedPolicyLines(entrySheetDetailsModel, contractSection);
        }

        private void RemoveDeletedPolicyLines(EntrySheetDetailsModel entrySheetDetailsModel, ContractSection contractSection)
        {
            var contractMarkets = contractSection.ContractMarkets
                .Where(x => _syndicateDataRetriever.GetIncludedSyndicates().Contains(x.Insurer.Party.Id)).ToList();

            var sectionSpecificPolicyLineModels = entrySheetDetailsModel.PolicyLines.Where(x =>
                    x.PolicyRef.Equals(contractSection.SectionReference, StringComparison.InvariantCultureIgnoreCase))
                .ToList();

            if (sectionSpecificPolicyLineModels.Count > contractMarkets.Count)
            {
                var deletedPolicyLineModels = new List<PolicyLineModel>();

                foreach (var policyLine in sectionSpecificPolicyLineModels)
                {
                    var matchingContractMarketExists = contractMarkets.Any(x =>
                        x.Insurer.Party.Id.Equals(policyLine.Entity, StringComparison.InvariantCultureIgnoreCase));

                    if (!matchingContractMarketExists)
                    {
                        deletedPolicyLineModels.Add(policyLine);
                    }
                }

                deletedPolicyLineModels.ForEach(x => entrySheetDetailsModel.PolicyLines.Remove(x));
            }
        }

        private void PopulateEmptyOrganisationModelProperties(PolicyInformationModel entrySheetDetailsModel)
        {
            if (entrySheetDetailsModel.Coverholder == null)
            {
                entrySheetDetailsModel.Coverholder = new OrganisationModel();
            }

            if (entrySheetDetailsModel.Insured == null)
            {
                entrySheetDetailsModel.Insured = new OrganisationModel();
            }

            if (entrySheetDetailsModel.Reinsured == null)
            {
                entrySheetDetailsModel.Reinsured = new OrganisationModel();
            }
        }

        public static T FindOrCreatePolicyRefModelInCollection<T>(List<T> source, string policyRef) where T : IPolicyRefModel
        {
            if (source == null)
            {
                throw new ArgumentNullException(nameof(source));
            }

            var existing = source.FirstOrDefault(x => x.PolicyRef == policyRef);

            if(Equals(existing, default(T)))
            {
                existing = Activator.CreateInstance<T>();
                source.Add(existing);
            }

            return existing;
        }
    }
}
