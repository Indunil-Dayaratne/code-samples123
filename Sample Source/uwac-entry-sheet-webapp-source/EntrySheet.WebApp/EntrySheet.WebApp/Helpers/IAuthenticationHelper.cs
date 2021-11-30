using System.Threading.Tasks;

namespace EntrySheet.WebApp.Helpers
{
    public interface IAuthenticationHelper
    {
        Task<bool> UserHasAccessAsync(string userPrincipalName);
        Task<bool> UserHasWriteAccessAsync(string userPrincipalName);
        Task<bool> UserHasReadAccessAsync(string userPrincipalName);
    }
}
