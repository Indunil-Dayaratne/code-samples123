using BritServices.BearerTokenHelper.Models;
using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;

namespace BritServices.BearerTokenHelper.Services
{
    public interface IBearerTokenHelper
    {
        AADUserDetail ExtractUserDetailsFromJWT(HttpRequest req);
        Task<bool> ValidateBearerTokenAsync(string bearerToken);
    }
}