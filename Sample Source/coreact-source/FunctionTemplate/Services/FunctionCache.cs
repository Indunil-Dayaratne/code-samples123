
using Coreact.Entities;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace Coreact.CoreProcesser.Function.Services
{
    public class FunctionCache : IFunctionCache
    {
        private ConcurrentDictionary<string, Lazy<CacheItem<object>>> _cache;

        public FunctionCache()
        {
            _cache = new ConcurrentDictionary<string, Lazy<CacheItem<object>>>();
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
               
                if (!Store(key, cachedValue, expiresAfter))
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
        public bool Store<T>(string key, T value, TimeSpan expiresAfter)
        {
            return _cache.TryAdd(key,new Lazy<CacheItem<object>>(() => new CacheItem<object>(value, expiresAfter)));
        }

        public bool Remove(string key)
        {
            var removedObject = new Lazy<CacheItem<object>>();

           return _cache.TryRemove(key,out removedObject);
        }

        /// <summary>
        /// Get Item from Cache
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public T Get<T>(string key)
        {
            if (key == null || !_cache.ContainsKey(key))
                return default(T);

            var cached = _cache[key];

            if((DateTimeOffset.Now - cached.Value.Created) >= cached.Value.ExpiresAfter)
            {
                Lazy<CacheItem<object>> value = null;

                if (_cache.TryRemove(key, out value))
                    return default(T);
                else
                    throw new ArgumentException($"Could not remove {key} from cache");
            } 

            return (T)cached.Value.Value;
        }
    }
}
