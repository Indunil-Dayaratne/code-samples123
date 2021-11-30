using System;
using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Models
{
    [ExcludeFromCodeCoverage]
    public class PolicyInformationModel
    {
        public int BritPolicyId { get; set; }
        public string CustomerType { get; set; }
        public string ProgramRef { get; set; }
        public OrganisationModel Insured { get; set; }
        public OrganisationModel Reinsured { get; set; }
        public OrganisationModel Coverholder { get; set; }
        public string ConductRating { get; set; }

        public string UniqueMarketRef { get; set; }
        public string CompanyLeader { get; set; }
        public string LloydsLeader { get; set; }
        public string PlacingType { get; set; }
        public string InstalmentPeriod { get; set; }

        protected bool Equals(PolicyInformationModel other)
        {
            return BritPolicyId == other.BritPolicyId &&
                   string.Equals(CustomerType, other.CustomerType) &&
                   string.Equals(ProgramRef, other.ProgramRef) &&
                   Equals(Insured, other.Insured) && Equals(Reinsured, other.Reinsured) &&
                   string.Equals(UniqueMarketRef , other.UniqueMarketRef) &&
                   string.Equals(CompanyLeader, other.CompanyLeader) &&
                   string.Equals(LloydsLeader, other.LloydsLeader) &&
                   string.Equals(PlacingType,other.PlacingType) &&
                   string.Equals(InstalmentPeriod,other.InstalmentPeriod) &&
                   Equals(Coverholder, other.Coverholder) && string.Equals(ConductRating, other.ConductRating);
        }

        public override bool Equals(object obj)
        {
            if (ReferenceEquals(null, obj)) return false;
            if (ReferenceEquals(this, obj)) return true;
            if (obj.GetType() != this.GetType()) return false;
            return Equals((EntrySheetDetailsModel)obj);
        }

        public override int GetHashCode()
        {
            unchecked
            {
                var hashCode = BritPolicyId;
                hashCode = (hashCode * 397) ^ (CustomerType != null ? CustomerType.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (ProgramRef != null ? ProgramRef.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (Insured != null ? Insured.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (Reinsured != null ? Reinsured.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (Coverholder != null ? Coverholder.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (ConductRating != null ? ConductRating.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (UniqueMarketRef != null ? UniqueMarketRef.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (CompanyLeader != null ? CompanyLeader.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (LloydsLeader != null ? LloydsLeader.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (InstalmentPeriod != null ? InstalmentPeriod.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (PlacingType != null ? PlacingType.GetHashCode() : 0);
                return hashCode;
            }
        }

    }

}
