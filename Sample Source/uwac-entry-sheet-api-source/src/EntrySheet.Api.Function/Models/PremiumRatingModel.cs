using System;
using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Models
{
    [ExcludeFromCodeCoverage]
    public class PremiumRatingModel: IPolicyRefModel
    {
        public string PolicyPremiumRatingId { get; set; }
        public string PolicyRef { get; set; }
        public string PremiumCcy { get; set; }
        public string ReportingCcy { get; set; }
        public decimal WrittenPremium { get; set; }
        public decimal TechPrice { get; set; }
        public decimal ModelPrice { get; set; }
        public decimal PLR { get; set; }
        public decimal ChangeInLDA { get; set; }
        public decimal ChangeInCoverage { get; set; }
        public decimal ChangeInOther { get; set; }
        public decimal RiskAdjustedRateChange { get; set; }
        public decimal BaseAmount { get; set; }
        public decimal? Brokerage { get; set; }
        public string BrokerageCcy { get; set; }
        public string BrokerageRateType { get; set; }
        public bool IsRiskEntrySheetLocked { get; set; }

        public string PremiumType { get; set; }
        public uint InitialToT { get; set; }
        public DateTime? PaymentDate { get; set; }
        public uint NumberOfInstallment { get; set; }



        protected bool Equals(PremiumRatingModel other)
        {
            return string.Equals(PolicyPremiumRatingId, other.PolicyPremiumRatingId) &&
                   string.Equals(PolicyRef, other.PolicyRef) && string.Equals(PremiumCcy, other.PremiumCcy) &&
                   string.Equals(ReportingCcy, other.ReportingCcy) && WrittenPremium == other.WrittenPremium &&
                   TechPrice == other.TechPrice && ModelPrice == other.ModelPrice && PLR == other.PLR &&
                   ChangeInLDA == other.ChangeInLDA && ChangeInCoverage == other.ChangeInCoverage &&
                   ChangeInOther == other.ChangeInOther && RiskAdjustedRateChange == other.RiskAdjustedRateChange &&
                   string.Equals(PremiumType , other.PremiumType) && 
                   InitialToT ==other.InitialToT && 
                   PaymentDate == other.PaymentDate && 
                   NumberOfInstallment == other.NumberOfInstallment &&
                 string.Equals(BrokerageRateType,other.BrokerageRateType) &&
                   BaseAmount == other.BaseAmount && Brokerage == other.Brokerage && string.Equals(BrokerageCcy, other.BrokerageCcy) 
                    && IsRiskEntrySheetLocked == other.IsRiskEntrySheetLocked;
        }

        public override bool Equals(object obj)
        {
            if (ReferenceEquals(null, obj)) return false;
            if (ReferenceEquals(this, obj)) return true;
            if (obj.GetType() != this.GetType()) return false;
            return Equals((PremiumRatingModel) obj);
        }

        public override int GetHashCode()
        {
            unchecked
            {
                var hashCode = (PolicyPremiumRatingId != null ? PolicyPremiumRatingId.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (PolicyRef != null ? PolicyRef.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (PremiumCcy != null ? PremiumCcy.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (ReportingCcy != null ? ReportingCcy.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ WrittenPremium.GetHashCode();
                hashCode = (hashCode * 397) ^ TechPrice.GetHashCode();
                hashCode = (hashCode * 397) ^ ModelPrice.GetHashCode();
                hashCode = (hashCode * 397) ^ PLR.GetHashCode();
                hashCode = (hashCode * 397) ^ ChangeInLDA.GetHashCode();
                hashCode = (hashCode * 397) ^ ChangeInCoverage.GetHashCode();
                hashCode = (hashCode * 397) ^ ChangeInOther.GetHashCode();
                hashCode = (hashCode * 397) ^ RiskAdjustedRateChange.GetHashCode();
                hashCode = (hashCode * 397) ^ BaseAmount.GetHashCode();
                hashCode = (hashCode * 397) ^ Brokerage.GetHashCode();
                hashCode = (hashCode * 397) ^ (BrokerageCcy != null ? BrokerageCcy.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (BrokerageRateType != null ? BrokerageRateType.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (PremiumType != null ? PremiumType.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ InitialToT.GetHashCode();
                hashCode = (hashCode * 397) ^ PaymentDate.GetHashCode();
                hashCode = (hashCode * 397) ^ NumberOfInstallment.GetHashCode();
                hashCode = (hashCode * 397) ^ IsRiskEntrySheetLocked.GetHashCode();
                return hashCode;
            }
        }
    }
}
