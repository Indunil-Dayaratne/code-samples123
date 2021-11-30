
using Coreact.CoreProcesser.Function.Services;
using Microsoft.Extensions.Logging;

namespace Coreact.CoreProcesser.Function.Repository
{
    public interface IFunctionRepository
    {
        IBearerTokenValidator BearerTokenValidator { get; }
        IFunctionCache FunctionCache { get; }
        ILogger Logger { get; }
        IServiceHelper ServiceHelper { get; }
    }
}
