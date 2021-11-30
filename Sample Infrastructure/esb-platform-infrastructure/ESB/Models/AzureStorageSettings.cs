using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ESB.Models
{
    public class AzureStorageSettings
    {
        public string ConnectionString { get; set; }
        public TimeSpan SASTokenDuration { get; set; }
        public TimeSpan SASTokenRefreshDuration { get; set; }
        public TimeSpan BlobCleanupStartTime { get; set; }
    }
}
