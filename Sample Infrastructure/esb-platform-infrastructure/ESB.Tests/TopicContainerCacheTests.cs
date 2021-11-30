using ESB.Models;
using ESB.Repositories;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Text;
using Xunit;

namespace ESB.Tests
{
    public class TopicContainerCacheTests
    {


        [Fact]
        public void GetContainers_ValidTopic()
        {
            ContainerCache cache = QueueControllerTests.GetContainerCache();

            // not in dictionary
            var containers = cache.GetTopicContainers("test");

            // already exists in dictionary
            containers = cache.GetTopicContainers("test");
        }

        [Fact]
        public void GetContainers_InvalidTopic()
        {
            ContainerCache cache = QueueControllerTests.GetContainerCache();

            // not in dictionary
            var containers = cache.GetTopicContainers("zzz");

            // does not error until you try to send message
        }
    }
}
