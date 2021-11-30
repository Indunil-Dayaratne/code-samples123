using FunctionAppHelper.Repository;
using FunctionAppHelper.Services.Interfaces;
using FunctionAppHelper.Validators;
using MediaPersistence.UnitTests.Base.Helpers;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Text;

namespace MediaPersistence.UnitTests.Mock
{
    public class MockFunctionRepository : IFunctionRepository
    {
        public IBearerTokenValidator BearerTokenValidator
        {
            get
            {
                return new MockBearerTokenValidator();
            }
        }

        public IFunctionCache FunctionCache => throw new NotImplementedException();

        public ILogger Logger
        {
            get
            {
                return new TestLoggerProvider().CreateLogger("Test");
            }
        }

        public IServiceHelper ServiceHelper => throw new NotImplementedException();
    }
}
