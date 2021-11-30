using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ESB.Models
{
    public class BusTopic : BusItem
    {
        public List<Subscription> Subscriptions { get; set; } = new List<Subscription>();
    }
}
