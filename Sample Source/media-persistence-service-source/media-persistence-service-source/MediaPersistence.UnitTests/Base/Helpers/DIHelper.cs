using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Extensions.Logging;
using FunctionAppHelper.Services;
using FunctionAppHelper.Services.Interfaces;
using System.Diagnostics.CodeAnalysis;
using Autofac;
using Autofac.Extras.Moq;
using MediaPersistence.Functions.Repositories;
using MediaPersistence.Functions.Helpers;
using MediaPersistence.Functions.Helpers.Interfaces;
using MediaPersistence.UnitTests.Mock;
using FunctionAppHelper.Repository;
using FunctionAppHelper.Validators;

namespace MediaPersistence.UnitTests.Base.Helpers
{
    [ExcludeFromCodeCoverage]
    public class DIHelper
    { 
        public static void AddDependencies(AutoMock am)
        {
            am.Provide<IFunctionCache, FunctionCache>();
            am.Provide<ILogger>(new LoggerFactory().CreateLogger("Test"));
            am.Provide<IMSGraphHelper, MSGraphHelper>();
            am.Provide<IMediaRepository, MediaRepository>();
            am.Provide<IAuthenticationHelper, AuthenticationHelper>();
            am.Provide<IKeyVaultHelper, KeyVaultHelper>();
            am.Provide<IFunctionRepository, MockFunctionRepository>();
            am.Provide<IBearerTokenValidator, MockBearerTokenValidator>();
        }
    
    }
}
