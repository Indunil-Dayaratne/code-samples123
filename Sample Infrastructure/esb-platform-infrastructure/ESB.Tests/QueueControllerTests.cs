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

namespace ESB.Tests
{
    public class QueueControllerTests
    {
        const string RemoteIPAddress = "1.2.3.4";
        const string UserName = @"wren\gjest";
        private static ContainerCache _containerCache = GetContainerCache();


        public static ContainerCache GetContainerCache()
        {
            var logger = LoggerUtils.LoggerMock<ContainerCache>();
            var storageSettings = AzureRepositoryTests.GetAzureStorageSettings();
            var busSettings = AzureRepositoryTests.GetAzureBusSettings();
            var containerCache = new ContainerCache(logger.Object, storageSettings, busSettings);
            return containerCache;
        }

        public static QueueController GetQueueController()
        {
            var logger = LoggerUtils.LoggerMock<QueueController>();
            var httpContextAccessor = new Mock<IHttpContextAccessor>();
            httpContextAccessor.Setup(t => t.HttpContext.Connection.RemoteIpAddress).Returns(IPAddress.Parse(RemoteIPAddress));
            var httpContext = new Mock<HttpContext>();
            httpContext.SetupGet(c => c.User.Identity.Name).Returns(UserName);
            var azureRepository = AzureRepositoryTests.GetAzureRepository();

            QueueController controller = new QueueController(logger.Object, azureRepository, _containerCache, httpContextAccessor.Object)
            {
                ControllerContext = new ControllerContext
                {
                    HttpContext = httpContext.Object
                }
            };

            return controller;
        }

        [Fact]
        public async void PostMessage_ValidQueue()
        {
            var controller = GetQueueController();
            var queue = "eclipse-policy-in";

            var messageId = await controller.PostMessage(queue, "UnitTest", $"messageBody now={DateTime.Now.ToString("o")}");

            var queueClient = new QueueClient(AzureRepositoryTests.BusConnectionString, queue);

            // Register subscription message handler and receive messages in a loop
            // Configure the message handler options in terms of exception handling, number of concurrent messages to deliver, etc.
            var messageHandlerOptions = new MessageHandlerOptions((e) => {
                return Task.CompletedTask;
            })
            {
                MaxConcurrentCalls = 1,
                AutoComplete = false,
            };

            var waitOnMessage = new CancellationTokenSource();
            Task t = Task.Run(() => {
                // Register the function that processes messages.
                queueClient.RegisterMessageHandler(async (message, token) =>
                {
                    if (message.MessageId == messageId)
                    {
                        await queueClient.CompleteAsync(message.SystemProperties.LockToken);
                        waitOnMessage.Cancel();
                    }

                }, messageHandlerOptions);
                Thread.Sleep(20000);
            }, waitOnMessage.Token);

            t.Wait();

            await queueClient.CloseAsync();
        }


        [Fact]
        public async void PostMessage_InvalidTopic()
        {
            var controller = GetQueueController();
            await Assert.ThrowsAsync<StorageException>(async () =>
            {
                await controller.PostMessage("zzzz123", "UnitTest", $"messageBody Invalid now={DateTime.Now.ToString("o")}");
            });
        }
    }
}
