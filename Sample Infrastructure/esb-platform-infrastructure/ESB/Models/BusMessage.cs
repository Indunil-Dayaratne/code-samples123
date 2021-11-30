using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ESB.Models
{
    public class BusMessage
    {
        public string Content { get; set; }
        public IEnumerable<KeyValuePair<string, object>> Metadata { get; set; } = Enumerable.Empty<KeyValuePair<string, object>>();
        public IEnumerable<KeyValuePair<string, string>> BlobReferenceMetadata { get; set; } = Enumerable.Empty<KeyValuePair<string, string>>();

        public override string ToString()
        {
            return $@"Content={Content}
Metadata={string.Join(", ", Metadata)}
BlobReferenceMetadata={string.Join(", ", BlobReferenceMetadata)}";
        }
    }
}
