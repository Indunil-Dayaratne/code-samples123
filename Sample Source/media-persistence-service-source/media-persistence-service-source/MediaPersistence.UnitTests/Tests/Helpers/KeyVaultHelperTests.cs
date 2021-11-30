using Autofac.Extras.Moq;
using FluentAssertions;
using FunctionAppHelper.Repository;
using FunctionAppHelper.Validators;
using MediaPersistence.Functions.Commands;
using MediaPersistence.Functions.Helpers;
using MediaPersistence.Functions.Helpers.Interfaces;
using MediaPersistence.Functions.Repositories;
using MediaPersistence.UnitTests.Base.Helpers;
using MediaPersistence.UnitTests.Mock;
using Microsoft.Extensions.Logging;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Diagnostics.CodeAnalysis;

namespace MediaPersistence.UnitTests.Tests
{
    [TestClass]
    [ExcludeFromCodeCoverage]
    public class KeyVaultHelperTests
    {
        private ILogger _logger;
        private AutoMock _autoMock;
        private IKeyVaultHelper _keyVaultHelper;

        [TestInitialize]
        public void Setup()
        {
            _logger = new LoggerFactory().CreateLogger("Test");
            _autoMock = AutoMock.GetLoose();
            _keyVaultHelper = new KeyVaultHelper(_logger);
            // add DI graph
            DIHelper.AddDependencies(_autoMock);
        }

        private void AddExtraDIEntities<T>(AutoMock am) where T : IAuthenticationHelper
        {
            am.Provide<IAuthenticationHelper, T>();
            am.Provide<IFunctionRepository, FunctionRepository>();
            am.Provide<IMediaRepository, MediaRepository>();
            am.Provide<IKeyVaultHelper, MockKeyVaultHelper>();
            am.Provide<IFunctionRepository, MockFunctionRepository>();
            am.Provide<IBearerTokenValidator, MockBearerTokenValidator>();
        }

        [TestMethod]
        [Ignore]
        public void TestGetValidSecret()
        {
            using (var mock = _autoMock)
            {
                Environment.SetEnvironmentVariable("KEYVAULT_RESOURCEID", "https://media-persistence-kv-dev.vault.azure.net/secrets/");
                AddExtraDIEntities<MockAuthenticationHelper>(mock);

                var result = _keyVaultHelper.GetKeyVaultValueAsync("beas-client-id").Result;

                result.Should().NotBeNullOrEmpty();
                result.Should().Be("2f4637b3-f7c9-4f6f-b950-228ce8ea7be6");
            }
        }

        [TestMethod]
        public void TestGetInvalidSecret()
        {
            using (var mock = _autoMock)
            {
                Environment.SetEnvironmentVariable("KEYVAULT_RESOURCEID", "https://media-persistence-kv-dev.vault.azure.net/secrets/");
                AddExtraDIEntities<MockAuthenticationHelper>(mock);
                var result = _keyVaultHelper.GetKeyVaultValueAsync("ASDFHASFDOGQHRGBSDFKV").Result;

                result.Should().BeNull();
            }
        }
    }
}
