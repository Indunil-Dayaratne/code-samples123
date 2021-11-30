using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using Brit.Risk.Entities;

namespace EntrySheet.Api.Function.Models
{
    [ExcludeFromCodeCoverage]
    public class RiskMapperModel
    {
        public string UserName { get; set; }
        public Guid CorelationId { get; set; }
        public Placing Placing { get; set; }
        public IDictionary<string, string> Metadata { get; set; } = new Dictionary<string, string>();
    }
}