using ESB.Models;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace ESB.Services
{
    public class BlobCleanup : IHostedService
    {
        protected ILogger _logger;
        private AzureStorageSettings _settings;
        private Timer _timer;
        private CancellationTokenSource _stopTokenSource;

        public BlobCleanup(ILogger<BlobCleanup> logger, IOptions<AzureStorageSettings> storageSettings)
        {
            _settings = storageSettings.Value;
            _logger = logger;
            _stopTokenSource = new CancellationTokenSource();
        }

        public Task StartAsync(CancellationToken cancellationToken)
        {
            _logger.LogDebug("BlobCleanup Service is starting");
            _stopTokenSource = new CancellationTokenSource();

            SetTimer();
            return Task.CompletedTask;
        }

        public Task StopAsync(CancellationToken cancellationToken)
        {
            _logger.LogInformation("BlobCleanup Service is stopping, cancelling timer");
            _timer?.Change(Timeout.Infinite, 0);
            _stopTokenSource.Cancel();

            return Task.CompletedTask;
        }

        public void SetTimer()
        {
            try
            {
                DateTimeOffset startTime = DateTimeOffset.Now.Date + _settings.BlobCleanupStartTime;

                if (startTime < DateTimeOffset.Now)
                {
                    // start tomorrow
                    startTime = startTime.AddDays(1);
                }

                TimeSpan delay = startTime - DateTimeOffset.Now;
                _logger.LogInformation($"Starting BlobCleanup timer startTime={startTime}, delay={delay}");
                _timer = new Timer(RemoveExpiredBlobsAsync, null, delay, TimeSpan.FromMilliseconds(-1));

            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"SetTimer Error: {ex.Message}");
                throw;
            }

        }

        public async void RemoveExpiredBlobsAsync(object state)
        {
            try
            {
                await RemoveExpiredBlobsAsync();
            }
            finally
            {
                if (!_stopTokenSource.IsCancellationRequested)
                {
                    SetTimer();
                }
            }
        }

        public async Task RemoveExpiredBlobsAsync()
        {
            try
            {
                _logger.LogInformation("RemoveExpiredBlobs - started");

                BlobRequestOptions defaultOptions = new BlobRequestOptions();
                OperationContext defaultContent = new OperationContext();
                AccessCondition defaultAccessCondition = new AccessCondition();

                CloudStorageAccount storageAccount = CloudStorageAccount.Parse(_settings.ConnectionString);
                CloudBlobClient blobClient = storageAccount.CreateCloudBlobClient();

                BlobContinuationToken containersContinuationToken = null;
                do
                {
                    ContainerResultSegment containersSegment = await blobClient.ListContainersSegmentedAsync(null, ContainerListingDetails.None, null, containersContinuationToken, defaultOptions, defaultContent, _stopTokenSource.Token);
                    _stopTokenSource.Token.ThrowIfCancellationRequested();

                    containersContinuationToken = containersSegment.ContinuationToken;

                    foreach (CloudBlobContainer container in containersSegment.Results)
                    {
                        _logger.LogDebug($"Processing container: {container.Name}");

                        BlobContinuationToken blobsContinuationToken = null;
                        do
                        {
                            BlobResultSegment blobsSegment = await container.ListBlobsSegmentedAsync(null, false, BlobListingDetails.Metadata, null, blobsContinuationToken, defaultOptions, defaultContent, _stopTokenSource.Token);
                            _stopTokenSource.Token.ThrowIfCancellationRequested();

                            blobsContinuationToken = blobsSegment.ContinuationToken;

                            foreach (CloudBlockBlob blob in blobsSegment.Results)
                            {
                                if (blob.Metadata.TryGetValue("TTL", out string tTL))
                                {
                                    if (DateTimeOffset.TryParse(tTL, out DateTimeOffset expiryDate) && expiryDate < DateTimeOffset.Now)
                                    {
                                        _logger.LogInformation($"Deleting expired blob container={container.Name}, name={blob.Name}, TTL={tTL}");
                                        await blob.DeleteAsync(DeleteSnapshotsOption.IncludeSnapshots, defaultAccessCondition, defaultOptions, defaultContent, _stopTokenSource.Token);
                                        _stopTokenSource.Token.ThrowIfCancellationRequested();
                                    }
                                }
                            }
                        } while (blobsContinuationToken != null);
                    }
                } while (containersContinuationToken != null);
            }
            catch (OperationCanceledException ex)
            {
                _logger.LogInformation(ex, $"RemoveExpiredBlobsAsync - Cancelled operation");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"RemoveExpiredBlobs Error: {ex.Message}");
            }
        }
    }
}
