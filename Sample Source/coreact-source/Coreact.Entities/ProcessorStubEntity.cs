using CoreHelpers.WindowsAzure.Storage.Table.Attributes;
using System;
using System.Collections.Generic;
using System.Text;

namespace Coreact.Entities
{
  [Storable()]
  public class ProcessorStubEntity
  {
    public ProcessorStubEntity()
    {
    }

    [StoreAsJsonObject]
    public TypeTemplateEntity Type { get; set; }

    [PartitionKey]
    public string Id { get; set; }

    public string ProcessId { get; set; }

    [RowKey]
    public string Version { get; set; }

    public DateTime CreatedOn { get; set; }
  }
}
