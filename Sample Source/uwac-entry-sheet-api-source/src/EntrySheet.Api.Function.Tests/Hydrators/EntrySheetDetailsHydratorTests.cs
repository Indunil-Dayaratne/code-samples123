using AutoMapper;
using Brit.Risk.Entities;
using EntrySheet.Api.Function.Hydration;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using EntrySheet.Api.Function.Mappers;
using EntrySheet.Api.Function.Models;
using EntrySheet.Api.Function.Services;
using Moq;
using Xunit;

namespace EntrySheet.Api.Function.Tests.Hydrators
{
    public class EntrySheetDetailsHydratorTests
    {
        private Mock<ISyndicateDataRetriever> _mockSyndicateDataRetriever = new Mock<ISyndicateDataRetriever>();
        
        public EntrySheetDetailsHydratorTests()
        {
            _mockSyndicateDataRetriever.Setup(x => x.GetIncludedSyndicates()).Returns(new List<string> { "2987", "2988" });
        }

        [Fact]
        public async Task FindOrCreatePolicyRefModelInCollection_Given_AnExisting_Collection_Returns_ExistingObject()
        {
            var source = new List<ContractSectionModel>();
            source.Add(new ContractSectionModel
            {
                PolicyRef = "ABC123"
            });

            var contractSectionModel = EntrySheetDetailsHydrator.FindOrCreatePolicyRefModelInCollection(source, "ABC123");

            Assert.Single(source);
            Assert.Equal("ABC123", contractSectionModel.PolicyRef);
        }

        [Fact]
        public async Task FindOrCreatePolicyRefModelInCollection_Given_AnEmpty_Collection_Returns_NewObject()
        {
            var source = new List<ContractSectionModel>();

            var contractSectionModel = EntrySheetDetailsHydrator.FindOrCreatePolicyRefModelInCollection(source, "ABC123");

            Assert.Single(source);
            Assert.Null(contractSectionModel.PolicyRef);
        }

        [Fact]
        public async Task FindOrCreatePolicyRefModelInCollection_Given_AnEmpty_Collection_Returns_NewObject1()
        {
            var baseFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            var dataFilePath = Path.Combine(baseFolder, @".\Data\KE688B20A000", "KE688B20A000_Placing.json");
            var json = File.ReadAllText(dataFilePath);
            var placing = JsonConvert.DeserializeObject<Placing>(json);
            var source = new EntrySheetDetailsModel();
            var mapper = new MapperConfiguration(cfg => cfg.AddProfile<EntrySheetDetailsModelProfile>()).CreateMapper();

            var policyRiskDetailsHydrator = new EntrySheetDetailsHydrator(mapper, _mockSyndicateDataRetriever.Object);
            var policyRiskDetailsModel = policyRiskDetailsHydrator.Execute(source, placing, new List<Placing>{placing},null);

            Assert.Single(policyRiskDetailsModel.ContractSection);
        }

        [Fact]
        public async Task EnsureAdditionalDetailsGetPopulatedAsExpected()
        {
            var baseFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            var dataFilePath = Path.Combine(baseFolder, @".\Data\KE688B20A000", "KE688B20A000_Placing.json");
            var json = File.ReadAllText(dataFilePath);
            var placing = JsonConvert.DeserializeObject<Placing>(json);
            var policyRiskDetailsModel = new EntrySheetDetailsModel();
            var mapper = new MapperConfiguration(cfg => cfg.AddProfile<EntrySheetDetailsModelProfile>()).CreateMapper();
            var policyItems = new List<PolicyItem> {
                new PolicyItem(12347,"KE688B20A000","F","HULL","KE688B20"),
            };

            var entrySheetDetailsHydrator = new EntrySheetDetailsHydrator(mapper, _mockSyndicateDataRetriever.Object);
            var riskDetailsModel = entrySheetDetailsHydrator.Execute(policyRiskDetailsModel, placing, new List<Placing> { placing },policyItems);
            

            Assert.True(riskDetailsModel.AdditionalDetails.Count == 1);
            Assert.True(riskDetailsModel.AdditionalDetails[0].ContractCertain==true);
            Assert.True(riskDetailsModel.AdditionalDetails[0].ContractCertainCode ==null);
            Assert.True(riskDetailsModel.AdditionalDetails[0].ContractCertainDate == new DateTime(2020, 06, 15));
            Assert.True(riskDetailsModel.AdditionalDetails[0].InceptionDate == new DateTime(2020, 07, 01));
            Assert.True(riskDetailsModel.AdditionalDetails[0].InsuranceLevel == "P");
            Assert.True(riskDetailsModel.AdditionalDetails[0].PolicyAdditionalDetailId == "928597");
            Assert.True(riskDetailsModel.AdditionalDetails[0].PolicyRef == "KE688B20A000");
            Assert.True(riskDetailsModel.AdditionalDetails[0].RiskRating == "C");
            Assert.True(riskDetailsModel.AdditionalDetails[0].PlacingType == "F");
            Assert.True(riskDetailsModel.AdditionalDetails[0].GroupClass == "HULL");
        }

        [Fact]
        public async Task PopulateContractSectionDetails_Is_Successful()
        {
            var baseFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            var dataFilePath = Path.Combine(baseFolder, @".\Data\KE688B20A000", "KE688B20A000_Placing.json");
            var json = File.ReadAllText(dataFilePath);
            var placing = JsonConvert.DeserializeObject<Placing>(json);
            var policyRiskDetailsModel = new EntrySheetDetailsModel();
            var mapper = new MapperConfiguration(cfg => cfg.AddProfile<EntrySheetDetailsModelProfile>()).CreateMapper();
            var policyItems = new List<PolicyItem> {
                new PolicyItem(12347,"KE688B20A000","F","HULL","KE688B20"),
            };

            var entrySheetDetailsHydrator = new EntrySheetDetailsHydrator(mapper, _mockSyndicateDataRetriever.Object);
            var riskDetailsModel = entrySheetDetailsHydrator.Execute(policyRiskDetailsModel, placing, new List<Placing> { placing }, policyItems);

            Assert.True(riskDetailsModel.ContractSection.Count == 1);
            Assert.True(riskDetailsModel.ContractSection[0].SubClass.Equals("90409"));
            Assert.True(riskDetailsModel.ContractSection[0].MinorClass.Equals("DO"));
            Assert.True(riskDetailsModel.ContractSection[0].ClassType.Equals("P"));
            Assert.True(riskDetailsModel.ContractSection[0].ProducingTeam.Equals("K"));
            Assert.True(riskDetailsModel.ContractSection[0].GroupClass.Equals("HULL"));
            Assert.True(riskDetailsModel.ContractSection[0].BrokerCode.Equals("1667"));
            Assert.True(riskDetailsModel.ContractSection[0].BrokerName.Equals("Whitehall Court Insurance (London)"));
            Assert.True(riskDetailsModel.ContractSection[0].BrokerPseud.Equals("WHC"));
            Assert.True(riskDetailsModel.ContractSection[0].LloydsBrokerId.Equals("17501"));
            Assert.True(riskDetailsModel.ContractSection[0].ContactName.Equals("Broker Contact"));
            Assert.True(riskDetailsModel.ContractSection[0].BrokerContactId.Equals("12233"));
        }

        [Fact]
        public void PopulatePolicyLinesDoesNotAddLinesForExcludedSyndicates()
        {
            var baseFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            var dataFilePath = Path.Combine(baseFolder, @".\Data\KE688B20A000", "KE688B20A000_Placing.json");
            var json = File.ReadAllText(dataFilePath);
            var placing = JsonConvert.DeserializeObject<Placing>(json);
            var policyRiskDetailsModel = new EntrySheetDetailsModel();
            var mapper = new MapperConfiguration(cfg => cfg.AddProfile<EntrySheetDetailsModelProfile>()).CreateMapper();
            var policyItems = new List<PolicyItem> {
                new PolicyItem(12347,"KE688B20A000","F","HULL","KE688B20"),
            };

            placing.ContractSections.First().ContractMarkets.First(x => x.Insurer.Party.Id == "2987").Insurer.Party.Id =
                "1618";

            var entrySheetDetailsHydrator = new EntrySheetDetailsHydrator(mapper, _mockSyndicateDataRetriever.Object);
            var riskDetailsModel = entrySheetDetailsHydrator.Execute(policyRiskDetailsModel, placing, new List<Placing> { placing }, policyItems);

            Assert.True(riskDetailsModel.PolicyLines.Count == 0);
        }

        [Fact]
        public void PopulateQuoteFields_Is_Successful()
        {
            var baseFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            var dataFilePath = Path.Combine(baseFolder, @".\Data\KE688B20A000", "KE688B20A000_Placing.json");
            var json = File.ReadAllText(dataFilePath);
            var placing = JsonConvert.DeserializeObject<Placing>(json);
            var policyRiskDetailsModel = new EntrySheetDetailsModel();
            var mapper = new MapperConfiguration(cfg => cfg.AddProfile<EntrySheetDetailsModelProfile>()).CreateMapper();
            var policyItems = new List<PolicyItem> {
                new PolicyItem(12347,"KE688B20A000","F","HULL","KE688B20"),
            };

            var entrySheetDetailsHydrator = new EntrySheetDetailsHydrator(mapper, _mockSyndicateDataRetriever.Object);
            var riskDetailsModel = entrySheetDetailsHydrator.Execute(policyRiskDetailsModel, placing, new List<Placing> { placing }, policyItems);
            Assert.True(riskDetailsModel.PolicyLines.Count > 0);
            Assert.True(riskDetailsModel.PolicyLines[0].QuoteDate.Equals(new DateTime(2021, 1, 1)));
            Assert.True(riskDetailsModel.PolicyLines[0].QuoteEndDate.Equals(new DateTime(2021, 5, 5)));
            Assert.True(riskDetailsModel.PolicyLines[0].QuoteDays.Equals(124));

        }

    }
}
