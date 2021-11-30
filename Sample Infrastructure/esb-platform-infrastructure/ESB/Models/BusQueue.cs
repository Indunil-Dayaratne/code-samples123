using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ESB.Models
{
    public class BusQueue : BusItem
    {
        public long MessageCount { get; set; }
    }
}
