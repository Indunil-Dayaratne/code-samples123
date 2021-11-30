using EntrySheet.WebApp.Helpers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.Options;

namespace EntrySheet.WebApp.Filters
{
    public class AuthenticationFilter : IActionFilter
    {
            private readonly IHttpRequestHelper _httpRequestHelper;
            private readonly Settings _configs;

            public AuthenticationFilter(IHttpRequestHelper httpRequestHelper, IOptions<Settings> configs)
            {
                _httpRequestHelper = httpRequestHelper;
                _configs = configs.Value;
            }

            public void OnActionExecuting(ActionExecutingContext context)
            {
                if (_configs.RootUrl.Contains("localhost"))
                {
                    return;
                }

                if (!_httpRequestHelper.AuthenticateRequestAsync(context.HttpContext.Request).Result)
                {
                    context.Result = new UnauthorizedResult();
                }
            }

            public void OnActionExecuted(ActionExecutedContext context)
            {
                // do nothing
            }
        }
}
