using System;
using System.IO;
using System.Web;
using System.Web.Caching;
using System.Web.Hosting;

namespace BEAS.Web.Helpers
{
    public class FingerPrintHelper
    {
        static readonly DateTime _baseDate = new DateTime(2017, 1, 1);

        public static string Tag(string rootRelativePath)
        {
            string fingerprintPath = HttpRuntime.Cache[rootRelativePath] as string;

            if (fingerprintPath == null)
            {
                var absolute = HostingEnvironment.MapPath("~" + rootRelativePath);
                DateTime date = File.GetLastWriteTime(absolute);
                var index = rootRelativePath.LastIndexOf('/');
                long period = (long)(date - _baseDate).TotalSeconds;
                if (period < 0)
                    period = 0;

                string name = Path.GetFileNameWithoutExtension(rootRelativePath);
                fingerprintPath = HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) + HttpRuntime.AppDomainAppVirtualPath + rootRelativePath.Insert(index, $"/{name}-v{period}").TrimStart('/');
                HttpRuntime.Cache.Insert(rootRelativePath, fingerprintPath, new CacheDependency(absolute));
            }

            return fingerprintPath;
        }
    }
}