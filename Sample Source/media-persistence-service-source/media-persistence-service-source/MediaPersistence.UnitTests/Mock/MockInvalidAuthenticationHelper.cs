using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json;
using MediaPersistence.Functions.Helpers.Interfaces;
using MediaPersistence.Functions.Commands;

namespace MediaPersistence.UnitTests.Mock
{
    [ExcludeFromCodeCoverage]
    public class MockInvalidAuthenticationHelper : IAuthenticationHelper
    {
        public Task<string> GetAccessTokenAsync()
        {
            return Task.FromResult("MockAccessToken");
        }
        public Task<string> GetMediaDBAccessTokenAsync()
        {
            return Task.FromResult("dlYnU8c6qHhWT8GrsCkwYNK3q2Cep348A6kOb8mha99dV3INt6ZdH3BQCYVVwDSDeDlGlhwIfKirVDF1OVwISA==");
        }

        public Task<bool> UserHasAccessAsync(string accessToken, UserRoleCommand command)
        {
            return Task.FromResult(false);
        }
    }

    
}
