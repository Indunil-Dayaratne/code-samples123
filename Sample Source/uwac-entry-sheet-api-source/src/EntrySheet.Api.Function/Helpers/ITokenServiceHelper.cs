using System.Threading.Tasks;

namespace EntrySheet.Api.Function.Helpers
{
    public interface ITokenServiceHelper
    {
        Task<string> GetAzureAccessTokenAsync(string applicationId, string connectionString);
    }
}
