using FunctionAppHelper.Models;
using FunctionAppHelper.Validators;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace MediaPersistence.UnitTests.Mock
{
    public class MockInvalidBearerTokenValidator : IBearerTokenValidator
    {
        public AADUserDetail ExtractUserDetailsFromJWT(HttpRequest req)
        {
            return null;
        }

        public Task<bool> ValidateRequest(HttpRequest req)
        {
            return Task.FromResult(false);
        }
    }
}
