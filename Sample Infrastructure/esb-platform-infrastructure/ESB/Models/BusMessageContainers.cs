using Microsoft.Azure.ServiceBus.Core;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ESB.Models
{
    public class BusMessageContainers
    {
        public CloudBlobContainer CloudBlobContainer { get; set; }
        public ISenderClient SenderClient { get; set; }

    }
}
