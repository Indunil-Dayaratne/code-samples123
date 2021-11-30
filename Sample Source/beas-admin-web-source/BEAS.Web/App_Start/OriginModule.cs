using System;
using System.Configuration;
using System.Web;

namespace BEAS.Web.App_Start
{
    public class OriginModule : IHttpModule
    {
        public void Init(HttpApplication context)
        {
            context.PreSendRequestHeaders += OnPreSendRequestHeaders;
        }

        public void Dispose() { }

        void OnPreSendRequestHeaders(object sender, EventArgs e)
        {
            // For example - To add header only for JS files
            if (HttpContext.Current.Request.Url.ToString().Contains(".css") || HttpContext.Current.Request.Url.ToString().Contains(".js") || HttpContext.Current.Request.Url.ToString().Contains(".html"))
            {
                HttpContext.Current.Response.Headers.Add("Access-Control-Allow-Origin", ConfigurationManager.AppSettings["BladeUIHostURL"]);
                HttpContext.Current.Response.Headers.Add("Access-Control-Allow-Credentials", "true");
            }
        }
    }
}