using ESB.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ESB.Repositories
{
    public interface IContainerCache
    {
        BusMessageContainers GetTopicContainers(string topicName);
        BusMessageContainers GetQueueContainers(string queueName);
    }
}
