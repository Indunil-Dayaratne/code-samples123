using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Models
{
    [ExcludeFromCodeCoverage]
    public class RiskValidationModel
    {
        public bool IsValid { get; set; }
        public IEnumerable<string> Reasons { get; set; } = new List<string>();
    }
}