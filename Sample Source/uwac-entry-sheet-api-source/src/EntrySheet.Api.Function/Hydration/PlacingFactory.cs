using System.Collections.Generic;
using Brit.Risk.Entities;

namespace EntrySheet.Api.Function.Hydration
{
    public class PlacingFactory
    {
        public Placing BuildEmptyPlacing()
        {
            var contractSection = BuildEmptyContractSection();

            var placing = new Placing
            {
                Insurer = new AnyParty { Contact = new Contact { BritAttributes = new BritContact() } },
                Broker = new AnyParty { Party = new Party(), Contact = new Contact() },
                ContractSections = new List<ContractSection> { contractSection },
                Contract = new Contract(),
                Insured = new AnyParty { Party = new Party() },
                Reinsurer = new AnyParty { Party = new Party() },
                CoverHolder = new AnyParty { Party = new Party() },
                BritAttributes = new BritPlacing(),
                WebApplication = new WebApplication()
            };

            return placing;
        }

        public ContractMarket BuildEmptyContractMarket()
        {
            var contractMarket = new ContractMarket
            {
                BritAttributes = new BritContractMarket
                {
                    EstimatedSigningDownPercentage = new AnyRate { Rate = new Rate() },
                    Exposure = new AnyAmt { Amt = new Amt() },
                    OrderPercentage = new AnyRate { Rate = new Rate()}

                },
                Insurer = new AnyParty { Party = new Party() },
                InsurerSharePercentage = new AnyRate { Rate = new Rate() },
                InsurerShareLimitAmount = new AnyAmt { Amt = new Amt() },
                InsurerShareNetPremiumAmount = new AnyAmt { Amt = new Amt() },
                PremiumRegulatoryAllocationSchemes = new List<PremiumRegulatoryAllocationScheme> { new PremiumRegulatoryAllocationScheme { Allocations = new List<Allocation> { new Allocation()} } }
            };

            return contractMarket;
        }

        private ContractSection BuildEmptyContractSection()
        {
            var premium = BuildEmptyPremium();

            var lossExcessPolicyContractDeductible = new ContractDeductible
            {
                DeductibleType = "loss_excess_policy",
                DeductibleAmount = new AnyAmt { Amt = new Amt() }
            };

            var retentionContractDeductible = new ContractDeductible
            {
                DeductibleType = "retention",
                DeductibleAmount = new AnyAmt { Amt = new Amt() }
            };

            var topContractCoverage = new ContractCoverage
            {
                BritAttributes = new BritContractCoverage { IsTopCoverage = true },
                CoverageAmount = new AnyAmt { Amt = new Amt() }
            };

            var contractSection = new ContractSection
            {
                BritAttributes = new BritContractSection(),
                OrderPercentage = new AnyRate { Rate = new Rate() },
                ContractSectionClasses = new List<ContractSectionClass> { new ContractSectionClass() },
                ContractCoverages = new List<ContractCoverage> { topContractCoverage },
                ContractDeductibles = new List<ContractDeductible>
                {
                    lossExcessPolicyContractDeductible, retentionContractDeductible
                }
            };
            contractSection.BritAttributes.InnerAgg = new AnyAmt { Amt = new Amt() };
            contractSection.ContractPeriod = new ContractPeriod { TimeDuration = new TimeDuration() };
            contractSection.FSAClientClassifications = new List<FSAClientClassification>
            {
                new FSAClientClassification()
            };
            contractSection.Premiums = new List<Premium> { premium };
            contractSection.ContractMarkets = new List<ContractMarket>();
            return contractSection;
        }

        private Premium BuildEmptyPremium()
        {
            var premium = new Premium
            {
                BritAttributes = new BritPremium(),
                PremiumAmount = new List<Amt> { new Amt() }
            };
            premium.BritAttributes.TechnicalPrice = new Amt();
            premium.BritAttributes.ModelPrice = new Amt();
            premium.BritAttributes.ProjectedLossRatio = new AnyRate { Rate = new Rate() };
            premium.BritAttributes.ChangeInLDA = new AnyRate { Rate = new Rate() };
            premium.BritAttributes.ChangeInCoverage = new AnyRate { Rate = new Rate() };
            premium.BritAttributes.ChangeInOther = new AnyRate { Rate = new Rate() };
            premium.BritAttributes.RiskAdjustedRateChange = new AnyRate { Rate = new Rate() };
            premium.TermsOfTradePeriod = new TermsOfTradePeriod { TimeDuration = new TimeDuration() };
            premium.InstalmentsTotalNbr = new AnyCount();
            return premium;
        }
    }
}