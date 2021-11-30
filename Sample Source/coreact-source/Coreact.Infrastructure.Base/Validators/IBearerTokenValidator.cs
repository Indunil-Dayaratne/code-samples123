using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;

namespace Coreact.Infrastructure.Base.Services
{
    public interface IBearerTokenValidator
    {
        Task<bool> ValidateRequest(HttpRequest req);
    }
}
