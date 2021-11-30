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
    public class AuthenticationHelperTests
    {
        private ILogger _logger;
        private AutoMock _autoMock;
        private IAuthenticationHelper _authenticationHelper;

        [TestInitialize]
        public void Setup()
        {
            _logger = new LoggerFactory().CreateLogger("Test");
            _autoMock = AutoMock.GetLoose();
            _authenticationHelper = new AuthenticationHelper(_logger, new MockKeyVaultHelper());
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
        public void TestGetAccessToken()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<AuthenticationHelper>(mock);
                var result = _authenticationHelper.GetAccessTokenAsync().Result;

                result.Should().NotBeNull();
                result.Should().BeAssignableTo<string>();
            }
        }

        [TestMethod]
        public void TestGetAccessTokenForMediaDB()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<AuthenticationHelper>(mock);
                var result = _authenticationHelper.GetMediaDBAccessTokenAsync().Result;

                result.Should().NotBeNull();
                result.Should().BeAssignableTo<string>();
            }
        }

        [TestMethod]
        public void TestGetInvalidAccessTokenForMediaDB()
        {
            using (var mock = _autoMock)
            {
                AddExtraDIEntities<AuthenticationHelper>(mock);
                var result = _authenticationHelper.GetMediaDBAccessTokenAsync().Result;

                result.Should().NotBeNull();
                result.Should().BeAssignableTo<string>();
            }
        }

        [TestMethod]
        [Ignore]
        public void TestUserHasAccessToAssignedRole()
        {
            using (var mock = _autoMock)
            {
                Environment.SetEnvironmentVariable("BEASBaseUrl", "https://beas-func-dev.azurewebsites.net/api");
                AddExtraDIEntities<AuthenticationHelper>(mock);
                var accessToken = _authenticationHelper.GetAccessTokenAsync().Result;
                UserRoleCommand command = new UserRoleCommand { ApplicationName = "BritFlow", ApplicationAreaName = "Query", RoleName = "Read", UserPrincipalName = "thomas.mathew@britinsurance.com" };

                var result = _authenticationHelper.UserHasAccessAsync(accessToken, command).Result;

                result.Should().Be(true);
            }
        }

        [TestMethod]
        public void TestUserDoesNotHaveAccessToUnassignedRole()
        {
            using (var mock = _autoMock)
            {
                Environment.SetEnvironmentVariable("BEASBaseUrl", "https://beas-func-dev.azurewebsites.net/api");
                AddExtraDIEntities<AuthenticationHelper>(mock);
                var accessToken = _authenticationHelper.GetAccessTokenAsync().Result;
                UserRoleCommand command = new UserRoleCommand { ApplicationName = "ABCDEFGHIJ", ApplicationAreaName = "KLMNOPQRS", RoleName = "XYZ", UserPrincipalName = "thomas.mathew@britinsurance.com" };

                var result = _authenticationHelper.UserHasAccessAsync(accessToken, command).Result;

                result.Should().Be(false);
            }
        }
    }
}
