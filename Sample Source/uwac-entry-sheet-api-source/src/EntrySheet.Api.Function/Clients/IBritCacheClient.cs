using System.Collections.Generic;
using System.Threading.Tasks;
using Brit.BritCacheEntities.Models.Eclipse;

namespace EntrySheet.Api.Function.Clients
{
    public interface IBritCacheClient
    {
        Task<IEnumerable<Policy>> GetEclipsePoliciesAsync(int[] britPolicyIds);
    }
}
