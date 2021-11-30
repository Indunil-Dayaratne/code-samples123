using System.Collections.Generic;
using System.Threading.Tasks;

namespace EntrySheet.Api.Function.Services
{
    public interface IRiskRatingService
    {
        List<string> GetRiskRatings();
    }
}