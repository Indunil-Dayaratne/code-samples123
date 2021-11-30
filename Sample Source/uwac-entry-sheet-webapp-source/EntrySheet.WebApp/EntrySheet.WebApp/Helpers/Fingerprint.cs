using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Options;
using System.IO;

namespace EntrySheet.WebApp.Helpers
{
    public class Fingerprint :IFingerprint
    {
        private readonly IMemoryCache _cache;
        private readonly Settings _configs;
        private readonly IWebHostEnvironment _hostingEnvironment;

        public Fingerprint(IMemoryCache cache, IOptions<Settings> configs, IWebHostEnvironment hostingEnvironment)
        {
            _cache = cache;
            _configs = configs.Value;
            _hostingEnvironment = hostingEnvironment;
        }

        public string Tag(string relativePath)
        {
            var fingerprintPath = _cache.Get(relativePath) as string;

            if (string.IsNullOrEmpty(fingerprintPath))
            {
                var absolute = $"{_hostingEnvironment.WebRootPath}{ relativePath}";
                var date = File.GetLastWriteTimeUtc(absolute);
                fingerprintPath = $"{_configs.RootUrl}{relativePath}?v={date.Ticks}";
                _cache.Set(relativePath, fingerprintPath);
            }

            return fingerprintPath;
        }
    }
}
