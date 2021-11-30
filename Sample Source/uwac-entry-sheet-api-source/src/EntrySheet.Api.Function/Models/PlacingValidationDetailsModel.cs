using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Models
{
    [ExcludeFromCodeCoverage]
    public class PlacingValidationDetailsModel
    {
        public string PolicyReference { get; set; }

        public RiskValidationModel ValidationDetails { get; set; }
    }
}