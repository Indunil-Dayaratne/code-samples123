using CoreHelpers.WindowsAzure.Storage.Table.Attributes;
using System;
using System.Collections.Generic;
using System.Text;

namespace Coreact.Entities
{
  [Storable()]
  public class TypeTemplateEntity
  {
    public TypeTemplateEntity()
    {
      Endpoints = new List<EndPointEntity>();
    }

    public string Type { get; set; }
    public string Id { get; set; }

    public string Name { get; set; }

    [StoreAsJsonObject]

    public List<EndPointEntity> Endpoints { get; set; }
  }
}
