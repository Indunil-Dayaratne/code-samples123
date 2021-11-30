using Brit.Risk.Entities;
using System.Collections.Generic;
using EntrySheet.Api.Function.Models;

namespace EntrySheet.Api.Function.Hydration
{
    public interface IEntrySheetDetailsHydrator
    {
        EntrySheetDetailsModel Execute(EntrySheetDetailsModel entrySheetDetailsModel, Placing placingForMainSection, IEnumerable<Placing> placingList,List<PolicyItem> policyItems);
    }
}