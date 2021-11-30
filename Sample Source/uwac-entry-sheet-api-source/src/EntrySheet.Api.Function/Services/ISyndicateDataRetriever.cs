using System.Collections.Generic;

namespace EntrySheet.Api.Function.Services
{
    public interface ISyndicateDataRetriever
    {
        List<string> GetIncludedSyndicates();
    }
}