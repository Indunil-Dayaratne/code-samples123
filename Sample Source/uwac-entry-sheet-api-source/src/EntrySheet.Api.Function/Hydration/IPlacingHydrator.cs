using System.Collections.Generic;
using Brit.Risk.Entities;
using EntrySheet.Api.Function.Models;

namespace EntrySheet.Api.Function.Hydration
{
    public interface IPlacingHydrator
    {
        List<Placing> Execute(EntrySheetDetailsModel entrySheetDetailsModel, string saveRequestApiUri);
    }
}