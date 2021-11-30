using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ESB.Models
{
    public class AzureBusSettings
    {
        public string ConnectionString { get; set; }
        public TimeSpan TimeToLive { get; set; }
        public TimeSpan SASTokenDuration { get; set; }
        public TimeSpan TokenProviderCacheDuration { get; set; }
        public TimeSpan SASTokenTimeout { get; set; }

        public string AppId { get; set; }
        public string SecretKey { get; set; }
        public string TenantId { get; set; }
        public string SubscriptionId { get; set; }
        public string ResourceGroupName { get; set; }
    }
}
