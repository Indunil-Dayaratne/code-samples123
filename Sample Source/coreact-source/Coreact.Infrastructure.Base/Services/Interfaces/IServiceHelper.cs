using Microsoft.Azure.Services.AppAuthentication;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace Coreact.Infrastructure.Base.Services
{
    public interface IServiceHelper
    {
        Task<string> GetServiceAccessTokenForResource(string resourceId);
    }
}
