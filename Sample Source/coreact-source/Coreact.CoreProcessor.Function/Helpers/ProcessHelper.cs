using Coreact.Infrastructure.Base.Services;
using CoreHelpers.WindowsAzure.Storage.Table;
using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using System.Threading.Tasks;

namespace Coreact.CoreProcessor.Function.Helpers
{
  public class ProcessHelper
  {
    public static string GetStorageAccountName()
    {
      return Environment.GetEnvironmentVariable("STORAGE_ACCOUNT_NAME");
    }

    public static string GetServiceBusName()
    {
      return Environment.GetEnvironmentVariable("SERVICE_BUS_NAME");
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
  }
}
