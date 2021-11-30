using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;

namespace Coreact.CoreProcesser.Function.Services
{
    public interface IBearerTokenValidator
    {
        Task<bool> ValidateRequest(HttpRequest req);
    }
}