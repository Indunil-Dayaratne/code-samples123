using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Models
{
    [ExcludeFromCodeCoverage]
    public class PolicyItem
    {
        public PolicyItem(int britPolicyId, string policyReference, string placingType, string groupClass,string programmeRef)
        {
            BritPolicyId = britPolicyId;
            PolicyReference = policyReference;
            GroupClass = groupClass;
            PlacingType = placingType;
            ProgramRef = programmeRef;
        }

        public int BritPolicyId { get; }
        public string PolicyReference { get; }
        public string PlacingType { get; }
        public string GroupClass { get; }
        public string ProgramRef { get; set; }
    }
}
