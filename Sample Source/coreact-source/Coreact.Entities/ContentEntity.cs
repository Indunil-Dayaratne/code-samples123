using CoreHelpers.WindowsAzure.Storage.Table.Attributes;
using System;
using System.Collections.Generic;
using System.Text;

namespace Coreact.Entities
{
  [Storable()]
  public class ContentEntity
  {
    public ContentEntity()
    {
      Error = new ErrorEntity();
    }

    [StoreAsJsonObject]
    public ErrorEntity Error {get;set;}

    [StoreAsJsonObject]
    public string Data { get; set; }

    [StoreAsJsonObject]
    public string BlobDataUri { get; set; }
  }
}
