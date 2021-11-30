using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace ESB.Authorisation
{
    public class HasBEASAccess : AuthorizationHandler<AccessRequirement>
    {
        private readonly ILogger _logger;

        public HasBEASAccess(ILogger<HasBEASAccess> logger)
        {
            _logger = logger;
        }

        protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, AccessRequirement requirement)
        {
            try
            {
                string adminClaim = $"{Startup.BEASApplication}_Admin";
                string permissionclaim = $"{Startup.BEASApplication}_{requirement.AccessRequired}";

                IEnumerable<Claim> bEASClaims = context.User.Claims.Where(c => c.Type == "BEAS");

                if (bEASClaims.Any(c => c.Value == adminClaim || c.Value == permissionclaim))
                {
                    context.Succeed(requirement);
                }
                else if (context.Resource is AuthorizationFilterContext mvc)
                {
                    // check if authorized for specific topic or queue for required access
                    // try to find "[topicName/queueName]-[Read/Write]" claim
                    var url = mvc.HttpContext.Request;
                    object name;
                    if (mvc.RouteData.Values.TryGetValue("topicName", out name) ||
                        mvc.RouteData.Values.TryGetValue("queueName", out name))
                    {
                        string claim = $"{Startup.BEASApplication}_{name}_{requirement.AccessRequired}";

                        if (bEASClaims.Any(c => c.Value == claim))
                        {
                            context.Succeed(requirement);
                        }
                        else
                        {
                            _logger.LogWarning($"HandleRequirementAsync no claims found for topic/queue={name}, requirement={requirement.AccessRequired}, user={context.User.Identity.Name}");
                        }
                    }
                }

                return Task.CompletedTask;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"HandleRequirementAsync, requirement={requirement.AccessRequired}, user={context.User.Identity.Name}, error:{ex.Message}");
                throw;
            }

        }
    }
}
