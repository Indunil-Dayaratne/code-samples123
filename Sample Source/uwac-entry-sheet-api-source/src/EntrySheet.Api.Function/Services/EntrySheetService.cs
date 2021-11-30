using System;
using Brit.Risk.Entities;
using EntrySheet.Api.Function.Hydration;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Brit.BritCacheEntities.Models.Eclipse;
using EntrySheet.Api.Function.Clients;
using EntrySheet.Api.Function.Models;
using EntrySheet.Api.Function.Repositories;

namespace EntrySheet.Api.Function.Services
{
    public class EntrySheetService: IEntrySheetService
    {
        private readonly IBritCacheClient _britCacheClient;
        private readonly IEclipseRiskApiClient _eclipseRiskApiClient;
        private readonly IEntrySheetDetailsHydrator _hydrator;
        private readonly IEntrySheetDetailsRepository _entrySheetDetailsRepository;
        private readonly IEclipseRiskValidationApiClient _eclipseRiskValidationApiClient;
        private readonly IPlacingHydrator _placingHydrator;

        public EntrySheetService(IBritCacheClient britCacheClient,
            IEclipseRiskApiClient eclipseRiskApiClient,
            IEntrySheetDetailsHydrator entrySheetDetailsHydrator, 
            IEntrySheetDetailsRepository entrySheetDetailsRepository, 
            IEclipseRiskValidationApiClient eclipseRiskValidationApiClient, 
            IPlacingHydrator placingHydrator)
        {
            _britCacheClient = britCacheClient;
            _eclipseRiskApiClient = eclipseRiskApiClient;
            _hydrator = entrySheetDetailsHydrator;
            _entrySheetDetailsRepository = entrySheetDetailsRepository;
            _eclipseRiskValidationApiClient = eclipseRiskValidationApiClient;
            _placingHydrator = placingHydrator;
        }

        public async Task<EntrySheetDetailsModel> GetEntrySheetDetailsAsync(int britPolicyId)
        {
            var policies = await _britCacheClient.GetEclipsePoliciesAsync(new []{ britPolicyId });
            var policyItems = GetPolicyItems(policies);
             if (!policyItems.Any())
            {
                return null;
            }
            var mergedEntrySheetDetailsModel = await GetEntrySheetDetailsModelAsync(policyItems, britPolicyId);

            return mergedEntrySheetDetailsModel;
        }

        public async Task<SaveEntrySheetResponseModel> SaveEntrySheetDetailsAsync(
            SaveEntrySheetRequestModel saveEntrySheetRequest)
        {
            if (saveEntrySheetRequest == null)
            {
                throw new ArgumentNullException(nameof(saveEntrySheetRequest));
            }

            var saveEntrySheetResponseModel = new SaveEntrySheetResponseModel();

            var placings = _placingHydrator.Execute(saveEntrySheetRequest.EntrySheetDetails, saveEntrySheetRequest.SaveRequestApiUri);

            await ValidateGpmDetailsAsync(placings, saveEntrySheetResponseModel);

            if (!saveEntrySheetResponseModel.PlacingValidationSuccessful)
            {
                return saveEntrySheetResponseModel;
            }

            var savedEntrySheetDetails = await SavedEntrySheetDetailsAsync(saveEntrySheetRequest, saveEntrySheetResponseModel);

            await SaveGpmDetailsAsync(placings, savedEntrySheetDetails, saveEntrySheetResponseModel);

            return saveEntrySheetResponseModel;
        }

        private async Task SaveGpmDetailsAsync(List<Placing> placings, EntrySheetDetailsModel savedEntrySheetDetails,
            SaveEntrySheetResponseModel saveEntrySheetResponseModel)
        {
            foreach (var placing in placings)
            {
                var policyReference = placing.ContractSections.First().SectionReference;
                var riskMapperModel = new RiskMapperModel
                {
                    CorelationId = Guid.NewGuid(),
                    Placing = placing,
                    UserName = savedEntrySheetDetails.UserName,
                    Metadata = new Dictionary<string, string> { { "PolicyReference", policyReference } }
                };
                var createRiskResponse = await _eclipseRiskApiClient.SubmitCreateRiskRequestAsync(riskMapperModel, policyReference); 

                saveEntrySheetResponseModel.CreateRiskSubmissionsSuccessful =
                    !string.IsNullOrEmpty(createRiskResponse.MessageId);
                var submissionDetailsModel = new CreateRiskRequestSubmissionDetailsModel
                {
                    CreateRiskResponse = createRiskResponse, 
                    PolicyReference = policyReference,
                    CorrelationId = riskMapperModel.CorelationId
                };

                saveEntrySheetResponseModel.CreateRiskRequestSubmissionDetails.Add(submissionDetailsModel);
            }
        }

        private async Task ValidateGpmDetailsAsync(List<Placing> placings, SaveEntrySheetResponseModel saveEntrySheetResponseModel)
        {
            foreach (var placing in placings)
            {
                var policyReference = placing.ContractSections.First().SectionReference;
                var validationDetails = await _eclipseRiskValidationApiClient.ValidateGpmDetailsAsync(placing, policyReference);
                saveEntrySheetResponseModel.PlacingValidationSuccessful = validationDetails.IsValid;

                var validationDetailsModel = new PlacingValidationDetailsModel
                    {PolicyReference = policyReference, ValidationDetails = validationDetails};
                saveEntrySheetResponseModel.PlacingValidationDetails.Add(validationDetailsModel);
            }

            saveEntrySheetResponseModel.PlacingValidationSuccessful =
                saveEntrySheetResponseModel.PlacingValidationDetails.All(x => x.ValidationDetails.IsValid);
        }

        private async Task<EntrySheetDetailsModel> SavedEntrySheetDetailsAsync(SaveEntrySheetRequestModel saveEntrySheetRequest,
            SaveEntrySheetResponseModel saveEntrySheetResponseModel)
        {
            var savedEntrySheetDetails = saveEntrySheetRequest.EntrySheetDetails;
            var britPolicyIdForSelectedPolicy = saveEntrySheetRequest.EntrySheetDetails.BritPolicyId;

            foreach (var contractSection in saveEntrySheetRequest.EntrySheetDetails.ContractSection)
            {
                saveEntrySheetRequest.EntrySheetDetails.BritPolicyId = contractSection.BritPolicyId;
                savedEntrySheetDetails =
                    await _entrySheetDetailsRepository.SaveAsync(saveEntrySheetRequest.EntrySheetDetails);
            }

            savedEntrySheetDetails.Id = britPolicyIdForSelectedPolicy.ToString();
            savedEntrySheetDetails.BritPolicyId = britPolicyIdForSelectedPolicy;
            saveEntrySheetResponseModel.SavedEntrySheet = savedEntrySheetDetails;
            saveEntrySheetResponseModel.SaveToCosmosDbSuccessful = true;
            return savedEntrySheetDetails;
        }

        private List<PolicyItem> GetPolicyItems(IEnumerable<Policy> policies)
        {
            var policyItems = new List<PolicyItem>();

            foreach (Policy policy in policies)
            {
                policyItems.Add(new PolicyItem(policy.BritPolicyId, policy.PolicyReference,policy.PlacingType,policy.GroupClass,policy.ProgramRef));

                if (policy.RelatedPolicies != null)
                {
                    foreach (RelatedPolicy relatedPolicy in policy.RelatedPolicies)
                    {
                        policyItems.Add(new PolicyItem(relatedPolicy.RelatedBritPolicyId, relatedPolicy.RelatedPolicyRef, policy.PlacingType, policy.GroupClass, policy.ProgramRef));
                    }
                }
            }

            return policyItems;
        }

        private async Task<EntrySheetDetailsModel> GetEntrySheetDetailsModelAsync(List<PolicyItem> policyItems, int britPolicyIdForSelectedPolicy)
        {
            var placingDictionary = new Dictionary<int, Placing>();

            foreach (var policyItem in policyItems)
            {
                var placing = await _eclipseRiskApiClient.GetEclipseRiskGpmDetailsAsync(policyItem.PolicyReference);

                placingDictionary.Add(policyItem.BritPolicyId, placing);
            }

            var savedEntrySheetDetailsModel = await _entrySheetDetailsRepository.GetLatestEntrySheetDetailsAsync(britPolicyIdForSelectedPolicy);
            var entrySheetDetailsModel = savedEntrySheetDetailsModel ?? new EntrySheetDetailsModel {BritPolicyId = britPolicyIdForSelectedPolicy };
            return HydrateData(entrySheetDetailsModel, placingDictionary[britPolicyIdForSelectedPolicy], placingDictionary.Values.ToList(), policyItems);
        }

        private EntrySheetDetailsModel HydrateData(EntrySheetDetailsModel entrySheetDetailsModel, Placing placingForSelectedPolicy, List<Placing> placingList, List<PolicyItem> policyItems)
        { 
            var riskDetailsModel = _hydrator.Execute(entrySheetDetailsModel, placingForSelectedPolicy, placingList, policyItems);
            return riskDetailsModel;
        }
    }
}
