using ESB.Controllers;
using Microsoft.Azure.ServiceBus;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.AspNetCore.Http;
using Moq;
using System;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Xunit;
using Microsoft.AspNetCore.Mvc;
using System.Net;
using Microsoft.WindowsAzure.Storage;
using ESB.Repositories;
using System.Globalization;

namespace ESB.Tests
{
    public class TopicControllerTests
    {
        const string RemoteIPAddress = "1.2.3.4";
        const string UserName = @"wren\gjest";
        private static ContainerCache _containerCache = QueueControllerTests.GetContainerCache();

        public static TopicController GetTopicController()
        {
            var logger = LoggerUtils.LoggerMock<TopicController>();
            var httpContextAccessor = new Mock<IHttpContextAccessor>();
            httpContextAccessor.Setup(t => t.HttpContext.Connection.RemoteIpAddress).Returns(IPAddress.Parse(RemoteIPAddress));
            var httpContext = new Mock<HttpContext>();
            httpContext.SetupGet(c => c.User.Identity.Name).Returns(UserName);
            var azureRepository = AzureRepositoryTests.GetAzureRepository();

            TopicController controller = new TopicController(logger.Object, azureRepository, _containerCache, httpContextAccessor.Object)
            {
                ControllerContext = new ControllerContext
                {
                    HttpContext = httpContext.Object
                }
            };

            return controller;
        }

        [Fact]
        public async void PostMessage_ValidTopic()
        {
            var controller = GetTopicController();
            var topic = "eclipse-policy-out";
            var subscription = "signalR";
            var messageBody = $"messageBody now={DateTime.Now.ToString("o")}";

            var messageId = await controller.PostMessageAsync(topic, "UnitTest", messageBody);

            var subscriptionClient = new SubscriptionClient(AzureRepositoryTests.BusConnectionString, topic, subscription);

            // Register subscription message handler and receive messages in a loop
            // Configure the message handler options in terms of exception handling, number of concurrent messages to deliver, etc.
            var messageHandlerOptions = new MessageHandlerOptions((e) => {
                return Task.CompletedTask;
            })
            {
                MaxConcurrentCalls = 1,
                AutoComplete = false,
            };

            bool foundMessage = false;

            var waitOnMessage = new CancellationTokenSource();
            Task t = Task.Run(() => {
                // Register the function that processes messages.
                subscriptionClient.RegisterMessageHandler(async (message, token) =>
                {
                    if (message.MessageId == messageId)
                    {
                        foundMessage = true;

                        // download blob content
                        var containers = _containerCache.GetTopicContainers(topic);
                        var newBlob = containers.CloudBlobContainer.GetBlockBlobReference(messageId);
                        var content = await newBlob.DownloadTextAsync();

                        Assert.Equal(content, messageBody);

                        await subscriptionClient.CompleteAsync(message.SystemProperties.LockToken);
                        waitOnMessage.Cancel();
                    }

                }, messageHandlerOptions);
                Thread.Sleep(20000);
            }, waitOnMessage.Token);

            t.Wait();

            await subscriptionClient.CloseAsync();

            Assert.True(foundMessage);
        }


        [Fact]
        public async void PostMessage_InvalidTopic()
        {
            var controller = GetTopicController();
            await Assert.ThrowsAsync<StorageException>(async () =>
            {
                await controller.PostMessageAsync("zzzz123", "UnitTest", $"messageBody Invalid now={DateTime.Now.ToString("o", CultureInfo.InvariantCulture)}");
            });
        }
    }
}
