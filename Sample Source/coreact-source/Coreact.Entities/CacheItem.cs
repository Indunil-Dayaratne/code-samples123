using System;
using System.Collections.Generic;
using System.Text;

namespace Coreact.Entities
{
    public class CacheItem<T>
    {
        public CacheItem(T value, TimeSpan expiresAfter)
        {
            Value = value;
            ExpiresAfter = expiresAfter;
            Created = DateTimeOffset.Now;
        }
        public T Value { get; }
        public DateTimeOffset Created { get; }
        public TimeSpan ExpiresAfter { get; }
    }

}
