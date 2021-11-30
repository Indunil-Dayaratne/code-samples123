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
    public class MockKeyVaultHelper : IKeyVaultHelper
    {
        public string ResourceId
        {
            get
            {
                return "https://media-persistence-kv-dev.vault.azure.net/secrets/";
            }
        }

        public Task<string> GetKeyVaultValueAsync(string key)
        {
            return Task.FromResult("2f4637b3-f7c9-4f6f-b950-228ce8ea7be6");
        }

    }

    
}
