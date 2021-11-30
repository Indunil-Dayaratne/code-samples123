using System.Diagnostics.CodeAnalysis;
using System.Text.Json;

namespace EntrySheet.Api.Function.Helpers
{
    [ExcludeFromCodeCoverage]
    public static class JsonOptions
    {
        public static readonly JsonSerializerOptions JsonSerializerOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        };

    }
}
