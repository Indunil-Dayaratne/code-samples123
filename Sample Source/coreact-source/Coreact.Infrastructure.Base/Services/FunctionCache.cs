

using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace Coreact.Infrastructure.Base.Services
{
    public class FunctionCache : IFunctionCache
    {
        private static MemoryCache _cache;

        public FunctionCache()
        {
          _cache = new MemoryCache(new MemoryCacheOptions { ExpirationScanFrequency = TimeSpan.FromMinutes(10) });
        }

        public async Task<T> GetOrAdd<T>(string key, Func<Task<T>> createCacheObject, TimeSpan expiresAfter)
        {
            var cachedValue = Get<T>(key);

            if (cachedValue == null)
            {
                try
                {
                    cachedValue = await createCacheObject.Invoke();
                }
                catch(Exception ex)
                {
                    throw new Exception($"Cannot create cache object when invoking {createCacheObject.ToString()} key:{key}",ex);
                }
               
                if (Store(key, cachedValue, expiresAfter) == null)
                    throw new Exception($"Failed to store {key} in FunctionCache");
            }

            return cachedValue;
        }

        /// <summary>
        /// Add Item to Cache
        /// </summary>
        /// <param name="key"></param>
        /// <param name="value"></param>
        /// <param name="expiresAfter"></param>
        public T Store<T>(string key, T value, TimeSpan expiresAfter)
        {
            return _cache.Set<T>(key, value, DateTimeOffset.UtcNow.Add(expiresAfter));
        }

        public void Remove(string key)
        {
            _cache.Remove(key);
        }

        /// <summary>
        /// Get Item from Cache
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public T Get<T>(string key)
        {
            if (key == null || _cache.Get(key) == null)
                return default(T);

            var cached = _cache.Get<T>(key);

            return cached;
        }
    }
}
