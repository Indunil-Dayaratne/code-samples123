using CoreHelpers.WindowsAzure.Storage.Table.Attributes;
using System;
using System.Collections.Generic;
using System.Text;

namespace Coreact.Entities
{
  [Storable()]
  public class ErrorEntity
  {
    public ErrorEntity()
    {
      this.Errors = new List<string>();
    }

    public bool HasError
    {
      get
      {
        return (Errors != null && Errors.Count > 0);
      }
    }
    [StoreAsJsonObject]
    public List<string> Errors { get; set; }
  }
}
