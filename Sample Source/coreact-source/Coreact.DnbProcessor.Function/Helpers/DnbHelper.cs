using Coreact.Infrastructure.Base.Services;
using CoreHelpers.WindowsAzure.Storage.Table;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Linq;
using RestSharp;
using Microsoft.Azure.WebJobs;
using System.Threading;
using Microsoft.WindowsAzure.Storage;
using System.IO;
using Coreact.Entities;
using Microsoft.Azure.WebJobs.Extensions.SignalRService;
using Polly;

namespace Coreact.DnbProcessor.Function.Helpers
{
  public class DnbHelper
  {
    public static async Task CreateAndSendSignalRMessage(IAsyncCollector<SignalRMessage> signalRMessages,CoreactMessage message,string endPointName,string status)
    {
      var messageJson = new
        {
          status = status,
          processId = message.ProcessId,
          endpoint = endPointName
        };

      await signalRMessages.AddAsync(new SignalRMessage
      {
        Target = "coreact-dnb",
        Arguments = new[] { JsonConvert.SerializeObject(messageJson) }
      });
    }

    public static async Task<ProcessorEntity> CreateProcessorEntityAndSaveBlob(IKeyVaultHelper kvHelper,string tableName,CoreactMessage message,string data)
    {
      var version = (DateTime.MaxValue.Ticks - DateTime.UtcNow.Ticks).ToString("d20");
      var blobReference = message.Id + "_" + message.Type + "_" + version;

      var blobUri = await SaveItemToBlobStorage(kvHelper, tableName, blobReference, data);

      var entity = new ProcessorEntity
        {
          Id = message.Id,
          Version = version,
          ProcessId = message.ProcessId,
          Type = message.TypeTemplate,
          CreatedOn = DateTime.Now,
          Content = new ContentEntity { BlobDataUri = blobUri }
        };

      return entity;
    }


    public static async Task SaveDataToTable(IKeyVaultHelper kvHelper,string tableName,ProcessorEntity entity)
    {
       using (var storageContext = await DnbHelper.CreateStorageContext(kvHelper))
        {
          storageContext.AddAttributeMapper(typeof(ProcessorEntity), tableName);

          await storageContext.MergeOrInsertAsync<ProcessorEntity>(entity);
        }
    }


    public static async Task<string> GetDataFromTable(IKeyVaultHelper kvHelper,string tableName,string partitionKey)
    {
      using (var storageContext = await CreateStorageContext(kvHelper))
        {
          storageContext.AddAttributeMapper(typeof(ProcessorEntity), tableName);

          var query = await storageContext.QueryAsync<ProcessorEntity>(partitionKey);

          var result = query.OrderByDescending(x => x.CreatedOn).Take(1).ToList();

          var data = await GetItemFromBlobStorage(kvHelper, result.First().Content.BlobDataUri);

          return data;
        }
    }


    public static string GetStorageAccountName()
    {
      return Environment.GetEnvironmentVariable("STORAGE_ACCOUNT_NAME");
    }

    public static async Task<string> GetItemFromBlobStorage(IKeyVaultHelper kvHelper, string blobUri)
    {
      var storageAccountDetails = CloudStorageAccount.Parse(await GetStorageConnectionString(kvHelper));
      var blobClient = storageAccountDetails.CreateCloudBlobClient();
      var blob = await blobClient.GetBlobReferenceFromServerAsync(new Uri(blobUri));

      using (var sm = new MemoryStream())
      {
        await blob.DownloadToStreamAsync(sm);
        var blobByteData = sm.ToArray();
        var actualBlobData = Encoding.ASCII.GetString(blobByteData);

        return actualBlobData;
      }
    }

    public static async Task<string> SaveItemToBlobStorage(IKeyVaultHelper kvHelper,string blobContainerReference,string blobReference,string data)
    {
      var storageAccountDetails = CloudStorageAccount.Parse(await GetStorageConnectionString(kvHelper));
      var blobClient = storageAccountDetails.CreateCloudBlobClient();
      var blobContainer = blobClient.GetContainerReference(blobContainerReference);

      await blobContainer.CreateIfNotExistsAsync();

      var blockBlob = blobContainer.GetBlockBlobReference(blobReference);

      using (Stream stream = new MemoryStream(Encoding.ASCII.GetBytes(data)))
      {
        await blockBlob.UploadFromStreamAsync(stream);
      }

      return blockBlob.Uri.ToString();
    }

    public static string GetServiceBusName()
    {
      return Environment.GetEnvironmentVariable("SERVICE_BUS_NAME");
    }

    public static async Task<string> GetStorageConnectionString(IKeyVaultHelper kvHelper)
    {
      var kvKey = Environment.GetEnvironmentVariable("STORAGE_KV_CONNECTIONSTRING");
      var connectionString = await kvHelper.GetKeyVaultValue(kvKey);

      return connectionString;
    }

    public static async Task<StorageContext> CreateStorageContext(IKeyVaultHelper kvHelper)
    {
      var kvKey = Environment.GetEnvironmentVariable("STORAGE_KV_CONNECTIONSTRING");
      var connectionString = await kvHelper.GetKeyVaultValue(kvKey);

      return new StorageContext(connectionString);
    }

    public static string GetAppPrefix()
    {
      return Environment.GetEnvironmentVariable("APP_PREFIX");
    }

    public static async Task<string> GetToken(IFunctionCache cache,IKeyVaultHelper kvHelper)
    {
      var dnbToken = await cache.GetOrAdd<string>("DnbAccessToken",async () => {
        using (var client = new HttpClient())
        {
          client.DefaultRequestHeaders.Add("x-dnb-user", "P100000F2A9036FF29A4FD388DA78C5E");
          client.DefaultRequestHeaders.Add("x-dnb-pwd", "2Q@3MF%4T%6%Ci34wUr");

          var res = await client.PostAsync("https://direct.dnb.com/Authentication/V2.0/", new StringContent(""));

          var resContent = await res.Content.ReadAsStringAsync();

          var obj = JsonConvert.DeserializeObject<dynamic>(resContent);

          return obj.AuthenticationDetail.Token.ToString();
        }
      },TimeSpan.FromMinutes(30));

      return dnbToken;
    }

    private static async Task<string> CallDnbEndPoint(IFunctionCache cache,IKeyVaultHelper kvHelper,string url)
    {
      var policy = Policy
        .Handle<Exception>()
        .WaitAndRetryAsync(new[]
        {
          TimeSpan.FromSeconds(1),
          TimeSpan.FromSeconds(2),
          TimeSpan.FromSeconds(3)
        });

      var result = await policy.ExecuteAsync(async () =>
      {
        using (var client = new HttpClient())
        {
          var accessToken = await DnbHelper.GetToken(cache,kvHelper);

          client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue(accessToken);

          var res = await client.GetAsync(url);

          return await res.Content.ReadAsStringAsync();
        }
      });

      return result;
    }

    public static async Task<string> GetDetailedCompanyPrem(IFunctionCache cache, IKeyVaultHelper kvHelper, string dunsNumber)
    {
      var url = $"https://direct.dnb.com/V6.1/organizations/{dunsNumber}/products/DCP_PREM";
      return await CallDnbEndPoint(cache, kvHelper, url);
    }

    public static async Task<string> GetKYC(IFunctionCache cache, IKeyVaultHelper kvHelper, string dunsNumber)
    {
      var url = $"https://direct.dnb.com/V6.0/organizations/{dunsNumber}/products/KYC";
      return await CallDnbEndPoint(cache, kvHelper, url);
    }

    public static async Task<string> GetVerificationReport(IFunctionCache cache, IKeyVaultHelper kvHelper, string dunsNumber)
    {
      var url = $"https://direct.dnb.com/V6.0/organizations/{dunsNumber}/products/CMP_VRF_RPT";
      return await CallDnbEndPoint(cache, kvHelper, url);
    }

    public static async Task<string> GetOwnership(IFunctionCache cache, IKeyVaultHelper kvHelper, string dunsNumber)
    {
      var url = $"https://direct.dnb.com/V6.0/organizations/{dunsNumber}/products/SMPL_OWNSHP";
      return await CallDnbEndPoint(cache, kvHelper, url);
    }

    public static async Task<string> GetCreditRating(IFunctionCache cache, IKeyVaultHelper kvHelper, string dunsNumber)
    {
      var url = $"https://direct.dnb.com/V5.0/organizations/{dunsNumber}/products/RTNG_TRND";
      return await CallDnbEndPoint(cache, kvHelper, url);
    }

    public static async Task<string> GetPaymentRisk(IFunctionCache cache, IKeyVaultHelper kvHelper, string dunsNumber)
    {
      var url = $"https://direct.dnb.com/V5.0/organizations/{dunsNumber}/products/PBPR_ENH";
      return await CallDnbEndPoint(cache, kvHelper, url);
    }

    public static async Task<string> GetLegalSuits(IFunctionCache cache, IKeyVaultHelper kvHelper, string dunsNumber)
    {
      var url = $"https://direct.dnb.com/V3.0/organizations/{dunsNumber}/products/PUBREC_SUITS";
      return await CallDnbEndPoint(cache, kvHelper, url);
    }

    public static async Task<string> GetLegalJudgements(IFunctionCache cache, IKeyVaultHelper kvHelper, string dunsNumber)
    {
      var url = $"https://direct.dnb.com/V3.0/organizations/{dunsNumber}/products/PUBREC_JDG";
      return await CallDnbEndPoint(cache, kvHelper, url);
    }

    public static async Task<string> GetLegalBankruptcy(IFunctionCache cache, IKeyVaultHelper kvHelper, string dunsNumber)
    {
      var url = $"https://direct.dnb.com/V3.0/organizations/{dunsNumber}/products/PUBREC_DTLS";
      return await CallDnbEndPoint(cache, kvHelper, url);
    }

    public static async Task<string> GetMedia(IFunctionCache cache, IKeyVaultHelper kvHelper, string dunsNumber)
    {
      var url = $"https://direct.dnb.com/V3.0/organizations/{dunsNumber}/products/NEWS_MDA";
      return await CallDnbEndPoint(cache,kvHelper, url);
    }

    public static async Task<string> GetMinorityLinkage(IFunctionCache cache, IKeyVaultHelper kvHelper, string dunsNumber)
    {
      var url = $"https://direct.dnb.com/V4.0/organizations/{dunsNumber}/products/LNK_FF_MNRT";

      var accessToken = await DnbHelper.GetToken(cache,kvHelper);

      var policy = Policy
        .Handle<Exception>()
        .WaitAndRetryAsync(new[]
        {
          TimeSpan.FromSeconds(1),
          TimeSpan.FromSeconds(2),
          TimeSpan.FromSeconds(3)
        });

      var result = await policy.ExecuteAsync(async () =>
      {
        var client = new RestClient(url);
        client.Timeout = 1000000;
        var request = new RestRequest();
        request.AddHeader("Authorization", accessToken);
        var cancellationTokenSource = new CancellationTokenSource();

        var restResponse = await client.ExecuteTaskAsync(request, cancellationTokenSource.Token);

        return restResponse.Content;
      });

      return result;
    }

    public static async Task<string> GetCorporateLinkage(IFunctionCache cache, IKeyVaultHelper kvHelper, string dunsNumber)
    {
      var url = $"https://direct.dnb.com/V4.0/organizations/{dunsNumber}/products/LNK_FF?AttachCompressedProductIndicator=true";
      return await CallDnbEndPoint(cache,kvHelper, url);
    }

    public static async Task<string> GetDunsCorporateIdentity(IFunctionCache cache, IKeyVaultHelper kvHelper, string subjectName,string countryCode,bool activeOnly)
    {
      var url = $"https://direct.dnb.com/V6.0/organizations?subjectName={subjectName}&CountryISOAlpha2Code={countryCode}&match=true&cleansematch=true";

      if (activeOnly)
        url += "&ExclusionCriteria-1=Exclude Out of Business";

      var policy = Policy
        .Handle<Exception>()
        .WaitAndRetryAsync(new[]
        {
          TimeSpan.FromSeconds(1),
          TimeSpan.FromSeconds(2),
          TimeSpan.FromSeconds(3)
        });

      var result = await policy.ExecuteAsync(async () =>
      {
        using (var client = new HttpClient())
        {
          var accessToken = await DnbHelper.GetToken(cache,kvHelper);

          client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue(accessToken);

          var res = await client.GetAsync(url);

          return await res.Content.ReadAsStringAsync();
        }
      });

      return result;
    }

    public static async Task<string> GetDunsCompanies(IFunctionCache cache,IKeyVaultHelper kvHelper, string keyword,int pageNo,int pageSize,List<string> otherParameters = null)
    {
      var url = $"https://direct.dnb.com/V6.4/organizations?KeywordText={keyword}&SearchModeDescription=Advanced&findcompany=true&InclusionDataDescription=IncludeNonMarketable&CandidatePerPageMaximumQuantity={pageSize}&CandidateDisplayStartSequenceNumber={pageNo}";

      // add other parameters
      if(otherParameters != null)
      {
        otherParameters.ForEach(item =>
        {
          url += "&" + item;
        });
      }

      var policy = Policy
        .Handle<Exception>()
        .WaitAndRetryAsync(new[]
        {
          TimeSpan.FromSeconds(1),
          TimeSpan.FromSeconds(2),
          TimeSpan.FromSeconds(3)
        });

      var result = await policy.ExecuteAsync(async () =>
      {
        using (var client = new HttpClient())
        {
          var accessToken = await DnbHelper.GetToken(cache,kvHelper);

          client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue(accessToken);

          var res = await client.GetAsync(url);

          return await res.Content.ReadAsStringAsync();
        }
      });

      return result;
    }

    public static async Task<string> GetComprehensiveReport(IFunctionCache cache,IKeyVaultHelper kvHelper, string dunsNumber, string format = "13204")
    {
      var url = $"https://direct.dnb.com/V3.2/organizations/{dunsNumber}/products/COMPR?ProductFormatPreferenceCode={format}";

      var accessToken = await DnbHelper.GetToken(cache,kvHelper);

      var policy = Policy
        .Handle<Exception>()
        .WaitAndRetryAsync(new[]
        {
          TimeSpan.FromSeconds(1),
          TimeSpan.FromSeconds(2),
          TimeSpan.FromSeconds(3)
        });

      var result = await policy.ExecuteAsync(async () =>
      {
        var client = new RestClient(url);
        client.Timeout = 1000000;
        var request = new RestRequest();
        request.AddHeader("Authorization", accessToken);
        var cancellationTokenSource = new CancellationTokenSource();

        var restResponse = await client.ExecuteTaskAsync(request, cancellationTokenSource.Token);

        return restResponse.Content;
      });

      return result;
    }
  }
}
