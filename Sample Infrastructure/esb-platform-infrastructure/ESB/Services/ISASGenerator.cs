using ESB.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ESB.Services
{
    public interface ISASGenerator
    {
        Task<TokenDetails> GetBlobContainerSASTokenAsync(string containerName);
        Task<ESBInformation> GetBusInformationAsync();
        Task<string> GetContainerLastUpdatedAsync(string containerName);
        Task SetContainerLastUpdatedAsync(string containerName, string lastUpdated);
    }
}
