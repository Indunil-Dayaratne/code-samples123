using System.Threading.Tasks;
using Brit.Risk.Entities;
using EntrySheet.Api.Function.Models;

namespace EntrySheet.Api.Function.Clients
{
    public interface IEclipseRiskValidationApiClient
    {
        Task<RiskValidationModel> ValidateGpmDetailsAsync(Placing placing, string policyReference);
    }
}