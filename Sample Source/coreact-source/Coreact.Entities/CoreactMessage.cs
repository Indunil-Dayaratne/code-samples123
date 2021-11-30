using System;
using System.Collections.Generic;
using System.Text;

namespace Coreact.Entities
{
  public class CoreactMessage
  {
    public string Id { get; set; }

    public string ProcessId { get; set; }

    public string Type { get; set; }

    public string TargetProcessor { get; set; }

    public DateTime CreatedOn { get; set; }

    public TypeTemplateEntity TypeTemplate {get;set;}
  }
}
