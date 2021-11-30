using System.Threading.Tasks;
using EntrySheet.Api.Function.Models;

namespace EntrySheet.Api.Function.Services
{
    public interface IEntrySheetService
    {
        Task<EntrySheetDetailsModel> GetEntrySheetDetailsAsync(int britPolicyId);

        Task<SaveEntrySheetResponseModel> SaveEntrySheetDetailsAsync(
            SaveEntrySheetRequestModel saveEntrySheetRequest);
    }
}
