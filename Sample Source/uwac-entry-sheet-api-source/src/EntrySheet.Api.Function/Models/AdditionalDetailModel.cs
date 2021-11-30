using System;
using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Models
{
    [ExcludeFromCodeCoverage]
    public class AdditionalDetailModel : IPolicyRefModel
    {
        public string PolicyAdditionalDetailId { get; set; }
        public string PolicyRef { get; set; }
        public string Period { get; set; }
        public DateTime? InceptionDate { get; set; }
        public DateTime? ExpiryDate { get; set; }
        public bool? ContractCertain { get; set; }
        public string ContractCertainCode { get; set; }
        public DateTime? ContractCertainDate { get; set; }
        public string RiskRating { get; set; }
        public string AggRiskData { get; set; }
        public string InsuranceLevel { get; set; }
        public string GroupClass { get; set; }
        public string PlacingType { get; set; }
        public uint TimeDurationValue { get; set; }
        public string TimeDurationPeriodType { get; set; }
        public bool IsRiskEntrySheetLocked { get; set; }

        protected bool Equals(AdditionalDetailModel other)
        {
            return string.Equals(PolicyAdditionalDetailId, other.PolicyAdditionalDetailId) &&
                   string.Equals(PolicyRef, other.PolicyRef) && string.Equals(Period, other.Period) &&
                   InceptionDate.Equals(other.InceptionDate) && ExpiryDate.Equals(other.ExpiryDate) &&
                   ContractCertain == other.ContractCertain &&
                   string.Equals(ContractCertainCode, other.ContractCertainCode) &&
                   ContractCertainDate.Equals(other.ContractCertainDate) &&
                   string.Equals(RiskRating, other.RiskRating) && string.Equals(AggRiskData?.Trim(), other.AggRiskData?.Trim()) &&
                   string.Equals(InsuranceLevel, other.InsuranceLevel) && string.Equals(GroupClass, other.GroupClass) &&
                   string.Equals(PlacingType, other.PlacingType) && TimeDurationValue == other.TimeDurationValue &&
                   string.Equals(TimeDurationPeriodType, other.TimeDurationPeriodType) && IsRiskEntrySheetLocked == other.IsRiskEntrySheetLocked;
        }

        public override bool Equals(object obj)
        {
            if (ReferenceEquals(null, obj)) return false;
            if (ReferenceEquals(this, obj)) return true;
            if (obj.GetType() != this.GetType()) return false;
            return Equals((AdditionalDetailModel) obj);
        }

        public override int GetHashCode()
        {
            unchecked
            {
                var hashCode = (PolicyAdditionalDetailId != null ? PolicyAdditionalDetailId.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (PolicyRef != null ? PolicyRef.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (Period != null ? Period.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ InceptionDate.GetHashCode();
                hashCode = (hashCode * 397) ^ ExpiryDate.GetHashCode();
                hashCode = (hashCode * 397) ^ ContractCertain.GetHashCode();
                hashCode = (hashCode * 397) ^ (ContractCertainCode != null ? ContractCertainCode.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ ContractCertainDate.GetHashCode();
                hashCode = (hashCode * 397) ^ (RiskRating != null ? RiskRating.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (AggRiskData != null ? AggRiskData.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (InsuranceLevel != null ? InsuranceLevel.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (GroupClass != null ? GroupClass.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (PlacingType != null ? PlacingType.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (int) TimeDurationValue;
                hashCode = (hashCode * 397) ^ (TimeDurationPeriodType != null ? TimeDurationPeriodType.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ IsRiskEntrySheetLocked.GetHashCode();
                return hashCode;
            }
        }
    }
}
