using EntrySheet.Api.Function.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EntrySheet.Api.Function.Services
{
    public interface IIndustryCodeService
    {
        Task<IEnumerable<IndustryCodeModel>> GetIndustryCodesAsync();
    }
}
