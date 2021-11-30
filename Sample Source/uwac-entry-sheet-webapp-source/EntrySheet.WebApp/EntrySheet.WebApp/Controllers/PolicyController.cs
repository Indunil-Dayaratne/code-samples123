using EntrySheet.WebApp.Filters;
using EntrySheet.WebApp.Helpers;
using EntrySheet.WebApp.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

namespace EntrySheet.WebApp.Controllers
{
    [ServiceFilter(typeof(AuthenticationFilter))]
    public class PolicyController : Controller
    {
        private readonly IHttpRequestHelper _httpRequestHelper;
        private readonly Settings _configs;

        public PolicyController(IHttpRequestHelper httpRequestHelper, IOptions<Settings> configs)
        {
            _httpRequestHelper = httpRequestHelper;
            _configs = configs.Value;
        }
        public IActionResult RiskEntrySheet(int britPolicyId,string policyReference)
        {
            string role = "";
            if(_httpRequestHelper.CheckUserHasWriteAccessAsync(HttpContext.Request).Result)
            {
                role = "Write";
            }
            else if(_httpRequestHelper.CheckUserHasReadAccessAsync(HttpContext.Request).Result)
            {
                role = "ReadOnly";
            }

            var model = new EntrySheetDataViewModel
            {
                BritPolicyId = britPolicyId,
                PolicyReference = policyReference,
                Role = role
            };
            return View(model);
        }

        
    }
}
