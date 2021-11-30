using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ESB.Models
{
    public class BusItem
    {
        public string Name { get; set; }
        public bool HasBlobContainer { get; set; } = false;
    }
}
