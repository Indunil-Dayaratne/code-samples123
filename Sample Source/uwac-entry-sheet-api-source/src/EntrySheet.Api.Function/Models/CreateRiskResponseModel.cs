using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Models
{
    [ExcludeFromCodeCoverage]
    public class CreateRiskResponseModel
    {
        public RiskValidationModel RiskValidationModel { get; set; }
        public string MessageId { get; set; }
    }
}