using BritServices.BearerTokenHelper.Models;
using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;

namespace EntrySheet.Api.Function.Helpers
{
    public interface IHttpRequestHelper
    {
        Task<(bool, AADUserDetail)> AuthenticateRequestAsync(HttpRequest request);
    }
}
