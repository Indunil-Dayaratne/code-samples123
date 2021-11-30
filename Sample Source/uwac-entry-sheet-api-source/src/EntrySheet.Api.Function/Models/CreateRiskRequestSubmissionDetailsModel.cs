using System;
using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Models
{
    [ExcludeFromCodeCoverage]
    public class CreateRiskRequestSubmissionDetailsModel
    {
        public CreateRiskResponseModel CreateRiskResponse { get; set; }
        public string PolicyReference { get; set; }
        public Guid CorrelationId { get; set; }
    }
}