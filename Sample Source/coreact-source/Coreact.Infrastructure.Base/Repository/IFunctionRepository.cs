
using Coreact.Infrastructure.Base.Services;
using Microsoft.Extensions.Logging;

namespace Coreact.Infrastructure.Base.Repository
{
    public interface IFunctionRepository
    {
        IBearerTokenValidator BearerTokenValidator { get; }
        IFunctionCache FunctionCache { get; }
        ILogger Logger { get; }
        IServiceHelper ServiceHelper { get; }
    }
}
