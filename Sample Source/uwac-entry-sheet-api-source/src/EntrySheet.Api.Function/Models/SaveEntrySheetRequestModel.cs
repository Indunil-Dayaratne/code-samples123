using System.Diagnostics.CodeAnalysis;

namespace EntrySheet.Api.Function.Models
{
    [ExcludeFromCodeCoverage]
    public class SaveEntrySheetRequestModel
    {
        public string SaveRequestApiUri { get; set; }
        public EntrySheetDetailsModel EntrySheetDetails { get; set; }
    }
}