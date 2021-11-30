using System.Collections.Generic;
using System.Threading.Tasks;
using EntrySheet.Api.Function.Models;

namespace EntrySheet.Api.Function.Repositories
{
    public interface IEntrySheetDetailsRepository
    {
        Task<EntrySheetDetailsModel> GetLatestEntrySheetDetailsAsync(int britPolicyId);
        Task<EntrySheetDetailsModel> SaveAsync(EntrySheetDetailsModel entrySheetDetailsModel);
        Task<List<EntrySheetDetailsModel>> GetLatestEntrySheetsAsync(int[] britPolicyIds);
    }
}