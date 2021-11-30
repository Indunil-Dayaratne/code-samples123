using System;
using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Models
{
    [ExcludeFromCodeCoverage]
    public class ContractSectionModel: IPolicyRefModel
    {
        public string PolicySectionId { get; set; }
        public int BritPolicyId { get; set; }
        public string PolicyRef { get; set; }
        public string UWInitials { get; set; }
        public string BrokerName { get; set; }
        public string BrokerCode { get; set; }
        public string LloydsBrokerId { get; set; }
        public string BrokerPseud { get; set; }
        public string ContactName { get; set; }
        public string BrokerContactId { get; set; }
        public string ClassType { get; set; }
        public string MinorClass { get; set; }
        public string MajorClass { get; set; }
        public string SubClass { get; set; }
        public string LimitCcy { get; set; }
        public decimal Limit { get; set; }
        public string LimitBasis { get; set; }
        public string BiSubLimitBasis { get; set; }
        public string BiSubLimitCcy { get; set; }
        public decimal BiSubLimit { get; set; }
        public string ContractCoverageId { get; set; }
        public decimal Excess { get; set; }
        public decimal Deductible { get; set; }
        public decimal InnerAGG { get; set; }
        public string ADRLevel { get; set; }
        public string CyberExposure { get; set; }
        public int YOA { get; set; }
        public string Syndicate { get; set; }
        public string ProducingTeam { get; set; }
        public bool? IsMainSection { get; set; }
        public string IndustryCode { get; set; }
        public string CustomerType { get; set; }
        public string ProgramRef { get; set; }
        public OrganisationModel Insured { get; set; }
        public OrganisationModel Reinsured { get; set; }
        public OrganisationModel Coverholder { get; set; }
        public string ConductRating { get; set; }
        public DateTime ContractPeriodStartDate { get; set; }
        public string GroupClass { get; set; }
        public bool IsRiskEntrySheetLocked { get; set; }
        //Country
        public string TerritoryIdAssured { get; set; }
        //Supra Entity
        public string TerritoryId { get; set; }
        public decimal OverridingCommission { get; set; }
        public decimal OtherDeductions { get; set; }
        public decimal ProfitCommission { get; set; }
        public string CoverOperatingBasis { get; set; }
      
        protected bool Equals(ContractSectionModel other)
        {
            return string.Equals(PolicySectionId, other.PolicySectionId) && string.Equals(PolicyRef, other.PolicyRef) &&
                   string.Equals(UWInitials, other.UWInitials) && string.Equals(BrokerName, other.BrokerName) &&
                   string.Equals(BrokerCode, other.BrokerCode) && string.Equals(LloydsBrokerId, other.LloydsBrokerId) &&
                   string.Equals(BrokerPseud, other.BrokerPseud) && string.Equals(ContactName, other.ContactName) &&
                   string.Equals(BrokerContactId, other.BrokerContactId) && string.Equals(ClassType, other.ClassType) &&
                   string.Equals(MinorClass, other.MinorClass) && string.Equals(MajorClass, other.MajorClass) &&
                   string.Equals(SubClass, other.SubClass) && string.Equals(LimitCcy, other.LimitCcy) &&
                   Limit == other.Limit && string.Equals(LimitBasis, other.LimitBasis) &&
                   string.Equals(BiSubLimitBasis, other.BiSubLimitBasis) &&
                   string.Equals(BiSubLimitCcy, other.BiSubLimitCcy) && BiSubLimit == other.BiSubLimit &&
                   Excess == other.Excess && Deductible == other.Deductible && InnerAGG == other.InnerAGG &&
                   string.Equals(ADRLevel, other.ADRLevel) && string.Equals(CyberExposure, other.CyberExposure) &&
                   YOA == other.YOA && string.Equals(Syndicate, other.Syndicate) &&
                   string.Equals(ProducingTeam, other.ProducingTeam) && IsMainSection == other.IsMainSection &&
                   string.Equals(IndustryCode, other.IndustryCode) && string.Equals(CustomerType, other.CustomerType) &&
                   string.Equals(ProgramRef, other.ProgramRef) && Equals(Insured, other.Insured) &&
                   Equals(Reinsured, other.Reinsured) && Equals(Coverholder, other.Coverholder) &&
                   string.Equals(ConductRating, other.ConductRating) &&
                   ContractPeriodStartDate.Equals(other.ContractPeriodStartDate) &&
                   TerritoryId == other.TerritoryId &&
                   TerritoryIdAssured == other.TerritoryIdAssured && 
                   OverridingCommission ==other.OverridingCommission && 
                   ProfitCommission == other.ProfitCommission && 
                   OtherDeductions == other.OtherDeductions && 
                   string.Equals(CoverOperatingBasis,other.CoverOperatingBasis) &&
                   string.Equals(GroupClass, other.GroupClass) && IsRiskEntrySheetLocked==other.IsRiskEntrySheetLocked;
        }

        public override bool Equals(object obj)
        {
            if (ReferenceEquals(null, obj)) return false;
            if (ReferenceEquals(this, obj)) return true;
            if (obj.GetType() != this.GetType()) return false;
            return Equals((ContractSectionModel) obj);
        }

        public override int GetHashCode()
        {
            unchecked
            {
                var hashCode = (PolicySectionId != null ? PolicySectionId.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (PolicyRef != null ? PolicyRef.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (UWInitials != null ? UWInitials.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (BrokerName != null ? BrokerName.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (BrokerCode != null ? BrokerCode.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (LloydsBrokerId != null ? LloydsBrokerId.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (BrokerPseud != null ? BrokerPseud.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (ContactName != null ? ContactName.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (BrokerContactId != null ? BrokerContactId.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (ClassType != null ? ClassType.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (MinorClass != null ? MinorClass.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (MajorClass != null ? MajorClass.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (SubClass != null ? SubClass.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (LimitCcy != null ? LimitCcy.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ Limit.GetHashCode();
                hashCode = (hashCode * 397) ^ (LimitBasis != null ? LimitBasis.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (BiSubLimitBasis != null ? BiSubLimitBasis.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (BiSubLimitCcy != null ? BiSubLimitCcy.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ BiSubLimit.GetHashCode();
                hashCode = (hashCode * 397) ^ Excess.GetHashCode();
                hashCode = (hashCode * 397) ^ Deductible.GetHashCode();
                hashCode = (hashCode * 397) ^ InnerAGG.GetHashCode();
                hashCode = (hashCode * 397) ^ (ADRLevel != null ? ADRLevel.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (CyberExposure != null ? CyberExposure.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ YOA;
                hashCode = (hashCode * 397) ^ (Syndicate != null ? Syndicate.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (ProducingTeam != null ? ProducingTeam.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ IsMainSection.GetHashCode();
                hashCode = (hashCode * 397) ^ (IndustryCode != null ? IndustryCode.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (CustomerType != null ? CustomerType.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (ProgramRef != null ? ProgramRef.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (Insured != null ? Insured.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (Reinsured != null ? Reinsured.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (Coverholder != null ? Coverholder.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (ConductRating != null ? ConductRating.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ ContractPeriodStartDate.GetHashCode();
                hashCode = (hashCode * 397) ^ (GroupClass != null ? GroupClass.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ IsRiskEntrySheetLocked.GetHashCode();
                hashCode = (hashCode * 397) ^ (TerritoryId!=null ? TerritoryId.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ (TerritoryIdAssured != null ? TerritoryIdAssured.GetHashCode() : 0);
                hashCode = (hashCode * 397) ^ OverridingCommission.GetHashCode();
                hashCode = (hashCode * 397) ^ ProfitCommission.GetHashCode();
                hashCode = (hashCode * 397) ^ OtherDeductions.GetHashCode();
                hashCode = (hashCode * 397) ^ (CoverOperatingBasis != null ? CoverOperatingBasis.GetHashCode() : 0);
                return hashCode;
            }
        }
    }
}
