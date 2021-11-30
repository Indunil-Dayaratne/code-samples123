using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;

namespace EntrySheet.WebApp.Helpers
{
    public interface IHttpRequestHelper
    {
        Task<bool> AuthenticateRequestAsync(HttpRequest request);
        Task<bool> CheckUserHasReadAccessAsync(HttpRequest request);
        Task<bool> CheckUserHasWriteAccessAsync(HttpRequest request);
    }
}
