using System.Threading.Tasks;

namespace EntrySheet.Api.Function.Helpers
{
    public interface IAuthenticationHelper
    {
        Task<string> GetAccessTokenAsync();
        Task<bool> UserHasAccessAsync(string accessToken, string userPrincipalName);
    }
}
