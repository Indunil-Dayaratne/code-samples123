using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Models
{
    [ExcludeFromCodeCoverage]
    public class SaveEntrySheetResponseModel
    {
        public EntrySheetDetailsModel SavedEntrySheet { get; set; }
        public bool SaveToCosmosDbSuccessful { get; set; }
        public List<PlacingValidationDetailsModel> PlacingValidationDetails { get; set; } = new List<PlacingValidationDetailsModel>();
        public bool PlacingValidationSuccessful { get; set; }
        public bool CreateRiskSubmissionsSuccessful { get; set; }
        public List<CreateRiskRequestSubmissionDetailsModel> CreateRiskRequestSubmissionDetails { get; set; } = new List<CreateRiskRequestSubmissionDetailsModel>();
    }
}