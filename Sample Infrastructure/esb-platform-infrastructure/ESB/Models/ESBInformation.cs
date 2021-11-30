using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ESB.Models
{
    public class ESBInformation
    {
        public List<BusTopic> Topics { get; set; } = new List<BusTopic>();
        public List<BusQueue> Queues { get; set; } = new List<BusQueue>();

        public string BusLocation { get; set; }
        public string StorageLocation { get; set; }
        public TimeSpan BusSASTokenDuration { get; set; }
        public TimeSpan BusTokenProviderCacheDuration { get; set; }
        public TimeSpan BlobSASTokenDuration { get; set; }
        public TimeSpan BlobSASTokenRefreshDuration { get; set; }
    }
}
