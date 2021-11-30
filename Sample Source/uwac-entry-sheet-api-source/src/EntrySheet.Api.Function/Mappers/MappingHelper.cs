using System;
using System.Collections.Generic;
using System.Linq;
using Brit.Risk.Entities;
using EntrySheet.Api.Function.Models;

namespace EntrySheet.Api.Function.Mappers
{
    public static class MappingHelper
    {
        private const string DayPeriodTypeFullName = "day";
        private const string WeekPeriodTypeFullName = "week";
        private const string MonthPeriodTypeFullName = "month";
        private const string YearPeriodTypeFullName = "year";
        private const string QuarterPeriodTypeFullName = "quarter";

        private const string DayPeriodType = "D";
        private const string WeekPeriodType = "W";
        private const string MonthPeriodType = "M";
        private const string YearPeriodType = "Y";
        private const string QuarterPeriodType = "Q";

        private const string PartOfWholeLinePercentageBasis = "part_of_whole";
        private const string PartOfOrderLinePercentageBasis = "part_of_order";

        private const string WholeWrittenLineBasis = "W";
        private const string OrderWrittenLineBasis = "O";

        private const string PercentageWrittenLineIndicator = "P";

        public static ContractCoverage GetBiSubLimitCoverage(Placing source)
        {
            foreach (ContractCoverage contractCoverage in source.ContractSections.First().ContractCoverages)
            {
                if (contractCoverage.CoverageBasis != null && contractCoverage.CoverageBasis.ToUpper().StartsWith("BI"))
                {
                    return contractCoverage;
                }
            }

            return null;
        }

        public static string GetBiSubLimitCcy(Placing source)
        {
            return GetBiSubLimitCoverage(source)?.CoverageAmount.Amt.Ccy;
        }

        public static decimal GetBiSubLimit(Placing source)
        {
            return GetBiSubLimitCoverage(source)?.CoverageAmount.Amt.Value ?? 0;
        }

        public static string GetBiSubLimitBasis(Placing source)
        {
            return GetBiSubLimitCoverage(source)?.CoverageBasis;
        }

        public static ContractCoverage GetTopCoverage(Placing source)
        {
            foreach (ContractCoverage contractCoverage in source.ContractSections.First().ContractCoverages)
            {
                if (contractCoverage.BritAttributes.IsTopCoverage)
                {
                    return contractCoverage;
                }
            }

            return source.ContractSections.First().ContractCoverages.First();
        }

        public static decimal GetWrittenLineForPolicyLine(ContractMarket contractMarket)
        {
            var writtenLineInd = contractMarket.BritAttributes.InsurerWrittenLineIndicator;
            decimal insurerSharePercentage = 0;
            decimal insurerShareLimitAmount = 0;

            if (string.Equals(writtenLineInd, PercentageWrittenLineIndicator, StringComparison.InvariantCultureIgnoreCase))
            {
                if (contractMarket.InsurerSharePercentage?.Rate != null)
                {
                    insurerSharePercentage = contractMarket.InsurerSharePercentage.Rate.Value;
                }

                return insurerSharePercentage;
            }

            if (contractMarket.InsurerShareLimitAmount?.Amt != null)
            {
                insurerShareLimitAmount = contractMarket.InsurerShareLimitAmount.Amt.Value;
            }

            return insurerShareLimitAmount;
        }

        public static decimal GetInsurerSharePercentage(string writtenLineInd, decimal writtenLine)
        {
            const int maxDecimalPlaces = 2;

            if (string.Equals(writtenLineInd, PercentageWrittenLineIndicator, StringComparison.InvariantCultureIgnoreCase))
            {
                if (writtenLine > 0 && writtenLine.ToString().Split(".").Length == maxDecimalPlaces)
                {
                    if (writtenLine.ToString().Split(".")[1].Length < maxDecimalPlaces)
                    {
                        var s = string.Format("{0:0.00}", writtenLine);
                        return Convert.ToDecimal(s);
                    }
                    else if (writtenLine.ToString().Split(".")[1].Length > maxDecimalPlaces)
                    {
                        return decimal.Round(writtenLine, maxDecimalPlaces);
                    }
                    else
                    {
                        return writtenLine;
                    }
                }
                return writtenLine;
            }

            return 0;
        }

        public static decimal GetInsurerShareLimitAmount(string writtenLineInd, decimal writtenLine)
        {
            if (!string.Equals(writtenLineInd, PercentageWrittenLineIndicator, StringComparison.InvariantCultureIgnoreCase))
            {
                return writtenLine;
            }

            return 0;
        }

        public static string GetLinePercentageBasis(string linePercentageBasis)
        {
            if (string.Equals(linePercentageBasis, PartOfWholeLinePercentageBasis,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return WholeWrittenLineBasis;
            }

            if (string.Equals(linePercentageBasis, PartOfOrderLinePercentageBasis,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return OrderWrittenLineBasis;
            }
            return null;
        }


        public static string GetWholePartOrderFullName(string linePercentageBasis)
        {
            if (string.Equals(linePercentageBasis, WholeWrittenLineBasis ,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return PartOfWholeLinePercentageBasis;
            }

            if (string.Equals(linePercentageBasis, OrderWrittenLineBasis ,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return PartOfOrderLinePercentageBasis;
            }
            return null;
        }

        public static string GetPeriodType(string periodBasis)
        {
            if (string.Equals(periodBasis, DayPeriodTypeFullName,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return DayPeriodType;
            }

            if (string.Equals(periodBasis, WeekPeriodTypeFullName,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return WeekPeriodType;
            }

            if (string.Equals(periodBasis, MonthPeriodTypeFullName,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return MonthPeriodType;
            }

            if (string.Equals(periodBasis, YearPeriodTypeFullName,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return YearPeriodType;
            }

            if (string.Equals(periodBasis, QuarterPeriodTypeFullName,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return QuarterPeriodType;
            }

            return null;
        }

        public static string GetPeriodTypeFullName(string periodType)
        {
            if (string.Equals(periodType, DayPeriodType,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return DayPeriodTypeFullName;
            }

            if (string.Equals(periodType, WeekPeriodType,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return WeekPeriodTypeFullName;
            }

            if (string.Equals(periodType, MonthPeriodType,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return MonthPeriodTypeFullName;
            }

            if (string.Equals(periodType, YearPeriodType,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return YearPeriodTypeFullName;
            }

            if (string.Equals(periodType, QuarterPeriodType,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return QuarterPeriodTypeFullName;
            }

            return null;
        }
        public static DateTime GetEndDate(DateTime startDate, uint duration, string periodType)
        {
            if (string.Equals(periodType, DayPeriodType,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return startDate.AddDays(Convert.ToInt32(duration));
            }

            if (string.Equals(periodType, WeekPeriodType,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return startDate.AddDays(Convert.ToInt32(duration * 7));
            }

            if (string.Equals(periodType, MonthPeriodType,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return startDate.AddMonths(Convert.ToInt32(duration));
            }

            if(string.Equals(periodType, YearPeriodType,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return startDate.AddYears(Convert.ToInt32(duration));
            }

            if(string.Equals(periodType, QuarterPeriodType,
                StringComparison.InvariantCultureIgnoreCase))
            {
                return startDate.AddMonths(Convert.ToInt32(duration * 3));
            }

            throw new ApplicationException("Cannot calculate the End Date");
        }

        public static DateTime GetEndDate(Placing placing)
        {
            var contractPeriod = placing.ContractSections.First().ContractPeriod;
            var startDate = contractPeriod.StartDate;
            var duration = contractPeriod.TimeDuration==null ? 0 : contractPeriod.TimeDuration.Value;
            var periodType = GetPeriodType(contractPeriod?.TimeDuration?.PeriodType);

            return GetEndDate(startDate, duration, periodType);
        }

        public static decimal? GetBrokerage(ContractSection contractSection)
        {
            decimal? brokerage =null;
            if (contractSection?.Brokerages != null)
            {
                var brokerages = contractSection.Brokerages.First();
                if (brokerages.BrokerageAmount != null && brokerages.BrokerageAmount.First()?.Value != null)
                {
                    brokerage = brokerages.BrokerageAmount.First().Value;
                    return brokerage;
                }
                if (brokerages.BrokeragePercentage != null && brokerages.BrokeragePercentage.Rate?.Value != null)
                {
                    brokerage = brokerages.BrokeragePercentage.Rate.Value;
                    return brokerage;
                }
               

            }
            return brokerage;
        }
        public static string GetBrokerageCcy(ContractSection contractSection)
        {
            string brokerageCcy = null;
            if (contractSection?.Brokerages != null)
            {
                var brokerages = contractSection.Brokerages.First();
                if (brokerages.BrokerageAmount != null && brokerages.BrokerageAmount.First()?.Value != null && brokerages.BrokerageAmount.First()?.Ccy != null)
                {
                    brokerageCcy = brokerages.BrokerageAmount.First().Ccy;
                    return brokerageCcy;
                }
                if (brokerages.BrokeragePercentage != null && brokerages.BrokeragePercentage.Rate?.Value != null && brokerages.BrokeragePercentage.Rate?.RateUnit != null)
                {
                    brokerageCcy = brokerages.BrokeragePercentage.Rate.RateUnit;
                    return brokerageCcy;
                }
               

            }
            return brokerageCcy;
        }

        public static string GetBrokerageRateType(ContractSection contractSection)
        {
            string brokerageRateType = null;
            if (contractSection?.Brokerages != null)
            {
                var brokerages = contractSection.Brokerages.First();
                if (brokerages.BrokerageAmount != null && brokerages.BrokerageAmount.First()?.Value != null)
                {
                    brokerageRateType = "Amount";
                }
                else if (brokerages.BrokeragePercentage != null && brokerages.BrokeragePercentage.Rate?.Value != null )
                {
                    brokerageRateType = "Percentage";
                }
            }
            return brokerageRateType;
        }

        public static Brokerage MapBrokerage(PremiumRatingModel premiumRatingModel)
        {
            Brokerage brokerage = null;
            if(premiumRatingModel.Brokerage !=null && premiumRatingModel.Brokerage > 0)
            {
                brokerage = new Brokerage();
                if(!string.IsNullOrEmpty(premiumRatingModel.BrokerageRateType) && premiumRatingModel.BrokerageRateType.Equals("Amount",StringComparison.InvariantCultureIgnoreCase))
                {
                    brokerage.BrokerageAmount = new List<Amt> { new Amt { Value = Convert.ToDecimal(premiumRatingModel.Brokerage), Ccy = premiumRatingModel.BrokerageCcy } };
                }
                else if (!string.IsNullOrEmpty(premiumRatingModel.BrokerageRateType) && premiumRatingModel.BrokerageRateType.Equals("Percentage", StringComparison.InvariantCultureIgnoreCase))
                {
                    brokerage.BrokeragePercentage = new AnyRate { Rate = new Rate { RateUnit = premiumRatingModel.BrokerageCcy, Value = Convert.ToDecimal(premiumRatingModel.Brokerage) } };
                }
            }
            return brokerage;
        }


        public static double GetDateDiffInDays(DateTime? startDate, DateTime? endDate)
        {
            if (startDate == null || endDate == null)
            {
                return 0;
            }
            TimeSpan diff = endDate.Value - startDate.Value;
            return diff.TotalDays;
        }

        public static bool ComputeIfRiskEntryIsLocked(Placing placing)
        {
            bool isRiskEntrySheetLocked = false;
            if (placing.ContractSections?.First()?.ContractMarkets != null)
            {
                isRiskEntrySheetLocked = placing.ContractSections.First().ContractMarkets.Any(item => item.LineTransactionFunction.Equals("Signed", StringComparison.OrdinalIgnoreCase));
            }
            return isRiskEntrySheetLocked;
        }

    }
}