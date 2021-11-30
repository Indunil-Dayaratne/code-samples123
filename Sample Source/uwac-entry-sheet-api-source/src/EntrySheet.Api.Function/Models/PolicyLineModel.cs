using System;
using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Models
{
    [ExcludeFromCodeCoverage]
    public class PolicyLineModel: IPolicyRefModel
    {
        public string PolicyLineId { get; set; }
        public bool LBS { get; set; }
        public string Section { get; set; }
        public string Entity { get; set; }
        public string LineStatus { get; set; }
        public string WLInd { get; set; }
        public decimal WrittenLine { get; set; }
        public decimal EstSign { get; set; }
        public string WO { get; set; }
        public decimal Order { get; set; }
        public string RICode { get; set; }
        public decimal Exposure { get; set; }
        public decimal GNWP { get; set; }
        public string PolicyRef { get; set; }

        public string StatusReason { get; set; }
        public double QuoteDays { get; set; }
        public DateTime? QuoteDate { get; set; }
        public string QuoteId { get; set; }
        public DateTime? QuoteEndDate { get; set; }
        public bool IsRiskEntrySheetLocked { get; set; }

        public string RiskAllocationCode { get; set; }
        public DateTime? WrittenDateTime { get; set; }
        protected bool Equals(PolicyLineModel other)
        {
            return string.Equals(PolicyLineId, other.PolicyLineId) && LBS == other.LBS &&
                   string.Equals(Section, other.Section) && string.Equals(Entity, other.Entity) &&
                   string.Equals(LineStatus, other.LineStatus) && string.Equals(WLInd, other.WLInd) &&
                   WrittenLine == other.WrittenLine && EstSign == other.EstSign && string.Equals(WO, other.WO)  && Order == other.Order &&
                   string.Equals(RICode, other.RICode) && Math.Round(Exposure) == Math.Round(other.Exposure) && Math.Round(GNWP) == Math.Round(other.GNWP) &&
                   string.Equals(PolicyRef, other.PolicyRef) && string.Equals(StatusReason, other.StatusReason) &&
                   string.Equals(RiskAllocationCode , other.RiskAllocationCode) &&
                   WrittenDateTime == other.WrittenDateTime &&
                   QuoteDays.Equals(other.QuoteDays) && QuoteDate.Equals(other.QuoteDate) && IsRiskEntrySheetLocked == other.IsRiskEntrySheetLocked;
        }

        public override bool Equals(object obj)
        {
            if (ReferenceEquals(null, obj)) return false;
            if (ReferenceEquals(this, obj)) return true;
            if (obj.GetType() != this.GetType()) return false;
            return Equals((PolicyLineModel) obj);
        }

        public override int GetHashCode()
        {
            unchecked
            {
                var hashCode = (PolicyLineId != null ? PolicyLineId.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ LBS.GetHashCode();
                hashCode = (hashCode * 397) ^ (Section != null ? Section.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (Entity != null ? Entity.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (LineStatus != null ? LineStatus.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (WLInd != null ? WLInd.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ WrittenLine.GetHashCode();
                hashCode = (hashCode * 397) ^ EstSign.GetHashCode();
                hashCode = (hashCode * 397) ^ (WO != null ? WO.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ Order.GetHashCode();
                hashCode = (hashCode * 397) ^ (RICode != null ? RICode.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ Exposure.GetHashCode();
                hashCode = (hashCode * 397) ^ GNWP.GetHashCode();
                hashCode = (hashCode * 397) ^ (PolicyRef != null ? PolicyRef.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (StatusReason != null ? StatusReason.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (RiskAllocationCode != null ? RiskAllocationCode.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ QuoteDays.GetHashCode();
                hashCode = (hashCode * 397) ^ QuoteDate.GetHashCode();
                hashCode = (hashCode * 397) ^ IsRiskEntrySheetLocked.GetHashCode();
                hashCode = (hashCode * 397) ^ (WrittenDateTime != null ? WrittenDateTime.GetHashCode() : 0);
                return hashCode;
            }
        }
    }
}
