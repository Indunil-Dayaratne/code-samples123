using CoreHelpers.WindowsAzure.Storage.Table.Attributes;
using System;
using System.Collections.Generic;
using System.Text;

namespace Coreact.Entities
{
  [Storable()]
  public class EndPointEntity
  {
    public string Name { get; set; }

    public string UrlFragment { get; set; }

    public string Type { get; set; }

    public string TopicName { get; set; }
  }
}
