using System.Web.Mvc;
using System.Web;

namespace BEAS.Web
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
        }

        public class AllowCrossSiteJsonAttribute : ActionFilterAttribute
        {
            public override void OnActionExecuting(ActionExecutingContext filterContext)
            {
                string bladeHost = System.Configuration.ConfigurationManager.AppSettings["BladeUIHostURL"];
                filterContext.HttpContext.Response.Headers.Add("Access-Control-Allow-Origin", bladeHost);
                filterContext.HttpContext.Response.Headers.Add("Access-Control-Allow-Credentials", "true");
                base.OnActionExecuting(filterContext);
            }
        }
    }
}
