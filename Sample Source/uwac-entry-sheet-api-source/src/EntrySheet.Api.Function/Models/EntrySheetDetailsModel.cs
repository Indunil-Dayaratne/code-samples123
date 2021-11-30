using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using Newtonsoft.Json;

namespace EntrySheet.Api.Function.Models
{
    [ExcludeFromCodeCoverage]
    public class EntrySheetDetailsModel
    {
        [JsonProperty(PropertyName = "id")]
        public string Id { get; set; }
        [JsonProperty(PropertyName = "britPolicyId")]
        public int BritPolicyId { get; set; }
        public string EPlacing { get; set; }
        public bool Completed { get; set; }
        public DateTime LastUpdatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public string UserName { get; set; }
        public List<ContractSectionModel> ContractSection { get; set; } = new List<ContractSectionModel>();
        public List<PremiumRatingModel> PremiumRatings { get; set; } = new List<PremiumRatingModel>();
        public List<PolicyLineModel> PolicyLines { get; set; } = new List<PolicyLineModel>();
        public List<AdditionalDetailModel> AdditionalDetails { get; set; } = new List<AdditionalDetailModel>();
        public List<PolicyInformationModel> RelatedPoliciesDetails { get; set; } = new List<PolicyInformationModel>();

        protected bool Equals(EntrySheetDetailsModel other)
        {
            return BritPolicyId == other.BritPolicyId &&
                   Completed == other.Completed && LastUpdatedOn.Equals(other.LastUpdatedOn) && string.Equals(EPlacing, other.EPlacing) &&
                   string.Equals(LastUpdatedBy, other.LastUpdatedBy);
        }

        public override bool Equals(object obj)
        {
            if (ReferenceEquals(null, obj)) return false;
            if (ReferenceEquals(this, obj)) return true;
            if (obj.GetType() != this.GetType()) return false;
            return Equals((EntrySheetDetailsModel) obj);
        }

        public override int GetHashCode()
        {
            unchecked
            {
                var hashCode = BritPolicyId;
                hashCode = (hashCode * 397) ^ (EPlacing != null ? EPlacing.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ Completed.GetHashCode();
                hashCode = (hashCode * 397) ^ LastUpdatedOn.GetHashCode();
                hashCode = (hashCode * 397) ^ (LastUpdatedBy != null ? LastUpdatedBy.GetHashCode() : 0);
                return hashCode;
            }
        }
    }
}
