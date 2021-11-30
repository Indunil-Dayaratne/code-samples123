using FunctionAppHelper.Models;
using FunctionAppHelper.Validators;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace MediaPersistence.UnitTests.Mock
{
    public class MockBearerTokenValidator : IBearerTokenValidator
    {
        public AADUserDetail ExtractUserDetailsFromJWT(HttpRequest req)
        {
            return new AADUserDetail { UPN = "Test.User@britinsurance.com", FamilyName = "User", GivenName = "Test", Name = "Test User", UniqueName = "Test.User@britinsurance.com" };
        }

        public Task<bool> ValidateRequest(HttpRequest req)
        {
            return Task.FromResult(true);
        }
    }
}
