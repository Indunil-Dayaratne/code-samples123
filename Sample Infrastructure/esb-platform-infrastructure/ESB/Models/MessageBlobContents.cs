using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ESB.Models
{
    public class MessageBlobContents
    {
        public byte[] Document { get; set; }
        public List<KeyValuePair<string,object>> Metadata { get; set; }
    }

    public class KeyValuePairMetadata
    {
        public string Key { get; set; }
        public string Value { get; set; }
    }
}
