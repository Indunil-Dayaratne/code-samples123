using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace Coreact.Infrastructure.Base.Services
{
    public interface IFunctionCache
    {
        T Store<T>(string key, T value, TimeSpan expiresAfter);

        T Get<T>(string key);

        Task<T> GetOrAdd<T>(string key, Func<Task<T>> createCacheObject, TimeSpan expiresAfter);

        void Remove(string key);
    }
}
