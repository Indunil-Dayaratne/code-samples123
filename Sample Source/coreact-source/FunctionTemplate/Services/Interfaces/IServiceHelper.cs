using Microsoft.Azure.Services.AppAuthentication;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace Coreact.CoreProcesser.Function.Services
{
    public interface IServiceHelper
    {
        Task<string> GetServiceAccessTokenForResource(string resourceId);
    }
}
