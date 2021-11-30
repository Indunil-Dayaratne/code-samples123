using System.Threading.Tasks;
using Brit.Risk.Entities;
using EntrySheet.Api.Function.Models;

namespace EntrySheet.Api.Function.Clients
{
    public interface IEclipseRiskApiClient
    {
        Task<Placing> GetEclipseRiskGpmDetailsAsync(string policyReference);
        Task<CreateRiskResponseModel> SubmitCreateRiskRequestAsync(RiskMapperModel riskMapperModel, string policyReference);
    }
}
