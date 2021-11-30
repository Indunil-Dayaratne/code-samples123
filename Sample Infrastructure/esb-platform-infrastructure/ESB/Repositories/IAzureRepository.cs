using ESB.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ESB.Repositories
{
    public interface IAzureRepository
    {
        Task<string> SendMessageWithBlobAsync(BusMessageContainers containers, string sourceSystem, string messageBody, string fromUser, string fromIpAddress);
        Task<string> SendMessageWithBlobAsync(BusMessageContainers containers, string sourceSystem, byte[] messageBody, string fromUser, string fromIpAddress,List<KeyValuePair<string,object>> metadata);
        Task<string> SendMessageWithFileAsync(BusMessageContainers containers, string sourceSystem, string filePath, string fromUser, string fromIpAddress);
        Task<string> SendMessageWithMetadataAsync(BusMessageContainers containers, string sourceSystem, BusMessage busMessage, string fromUser, string fromIpAddress);
    }
}
